package foxel
import "core:encoding/endian"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strings"
import rl "vendor:raylib"
CHUNK_X :: 16
CHUNK_Y :: 128
CHUNK_Z :: 16
CHUNK_MAGIC_NUMBER :: u32(98734)
CHUNK_VERSION :: u8(1)
Chunk :: struct {
	blocks:           [CHUNK_X * CHUNK_Y * CHUNK_Z]u16,
	position:         ChunkPos,
	dirty:            bool,
	should_be_loaded: bool,
	mesh:             rl.Mesh,
}
ChunkPos :: struct {
	x: i32,
	z: i32,
}
RLEPair :: struct #packed {
	block:  u8,
	length: u16,
}

RLEPairLong :: struct {
	block:  u16,
	length: u16,
}
ChunkHeader :: struct {
	magic_number:    u32,
	version:         u8,
	palette_len:     u16,
	palette_is_long: bool,
}
chunks: map[ChunkPos]^Chunk
generate_chunk :: proc(position: ChunkPos) {
	chunk := new(Chunk)
	chunk.position = position
	stone_id := blocks["stone"].temp_id
	for &block, index in chunk.blocks {
		if (index == 256) do break
		block = stone_id
	}
	chunks[position] = chunk
	update_chunk_mesh(position)
}
index_to_coordinate :: proc(index: int) -> rl.Vector3 {
	coordinate: rl.Vector3
	coordinate[0] = f32(index % CHUNK_X)
	coordinate[1] = f32(index / (CHUNK_X * CHUNK_Z))
	coordinate[2] = f32((index / CHUNK_X) % CHUNK_Z)
	return coordinate
}

coordinate_to_index :: proc(coordinate: rl.Vector3) -> int {
	return(
		int(coordinate[1]) * CHUNK_X * CHUNK_Z +
		int(coordinate[2]) * CHUNK_X +
		int(coordinate[0]) \
	)
}
save_chunk :: proc(position: ChunkPos, world: string) {
	header := ChunkHeader {
		magic_number    = CHUNK_MAGIC_NUMBER,
		version         = CHUNK_VERSION,
		palette_is_long = false,
	}
	palette: [dynamic]u8
	reverse_palette := make(map[string]u8)
	blocks := make([dynamic]RLEPair)
	index: u8
	rle_run: u16
	rle_block: u8
	first_time := true
	for block in chunks[position].blocks {
		name := block_ids[block]
		id_to_write, ok := reverse_palette[name]
		if !ok {
			if index == 255 {
				// TODO: rebuild using RLEPairLong
				break
			}
			id_to_write = index
			reverse_palette[name] = index
			append(&palette, u8(len(name)))
			append_elems(&palette, ..transmute([]u8)name)
			index += 1
			fmt.println("Added block to palette: ", name, index)
			first_time = false
		}

		if rle_block == id_to_write || first_time do rle_run += 1
		else {
			append(&blocks, RLEPair{block = rle_block, length = rle_run})
			rle_block = id_to_write
			rle_run = 1
		}

	}
	append(&blocks, RLEPair{block = rle_block, length = rle_run})
	blocks_bytes := slice.reinterpret([]u8, blocks[:])
	header.palette_len = u16(index)
	buf: [dynamic]u8
	append_elems(&buf, ..mem.any_to_bytes(header))
	append_elems(&buf, ..palette[:])
	append_elems(&buf, ..blocks_bytes)
	err := os.write_entire_file(
		fmt.tprintf("worlds/%s/%i_%i.cnk", world, position.x, position.z),
		buf[:],
	)
	if err != nil do return
	free(&palette)
	free(chunks[position])
	delete_key(&chunks, position)

}

load_chunk :: proc(position: ChunkPos, world: string) {
	file, err := os.open(fmt.tprintf("worlds/%s/%i_%i.cnk", world, position.x, position.z))
	if err != nil {
		generate_chunk(position)
		return
	}

	data, err_data := os.read_entire_file_from_file(file, context.temp_allocator)
	if (err_data != nil) {
		generate_chunk(position)
		return
	}
	chunk := new(Chunk)
	chunk.position = position
	header := (^ChunkHeader)(raw_data(data))^
	if header.magic_number != CHUNK_MAGIC_NUMBER do return
	block_index: u16
	offset := size_of(ChunkHeader)
	palette := make([dynamic]string)
	fmt.println(header)
	for i := u16(0); i < header.palette_len; i += 1 {
		string_len := int(data[offset])
		fmt.println(string_len)
		start := offset + 1
		append(&palette, strings.clone(string(data[start:start + string_len])))
		fmt.println(palette[i])
		offset += string_len + 1
		fmt.println(offset)
	}
	rle_entries := slice.reinterpret([]RLEPair, data[offset:])
	fmt.println(rle_entries)
	block: u16
	for entry, index in rle_entries {
		for i := u16(0); i < entry.length; i += 1 {
			block_name := palette[entry.block]
			chunk.blocks[block] = blocks[block_name].temp_id
			block += 1
		}
	}
	chunks[position] = chunk
	update_chunk_mesh(position)
}
