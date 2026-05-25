package foxel
import "core:encoding/endian"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strings"
import "core:sync"
import "core:thread"
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
	done_with_init:   bool,
	mesh:             ^rl.Mesh,
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
chunks_mutex: sync.Mutex
chunk_pool: thread.Pool
init_chunk_workers :: proc() {
	thread.pool_init(&chunk_pool, context.allocator, 4)
	thread.pool_start(&chunk_pool)
}
queue_chunk_load :: proc(position: ChunkPos) {
	fmt.println("queued: ", position)
	task_data := new(ChunkPos)
	task_data^ = position
	thread.pool_add_task(&chunk_pool, context.allocator, chunk_load_worker, task_data)
}
queue_chunk_save :: proc(position: ChunkPos) {
	fmt.println("queued: ", position)
	task_data := new(ChunkPos)
	task_data^ = position
	thread.pool_add_task(&chunk_pool, context.allocator, chunk_save_worker, task_data)
}
generate_chunk :: proc(position: ChunkPos) {
	chunk := new(Chunk)
	chunk.position = position
	stone_id := blocks["stone"].temp_id
	for &block, index in chunk.blocks {
		if (index == 256) do break
		block = stone_id
	}
	sync.mutex_lock(&chunks_mutex)
	chunks[position] = chunk
	sync.mutex_unlock(&chunks_mutex)
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

chunk_save_worker :: proc(task: thread.Task) {
	position := (cast(^ChunkPos)task.data)^
	if !(position in chunks) {
		fmt.println("very very very very bad")
		return
	}
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
	delete(buf)
	delete(palette)
	delete(reverse_palette)
	delete(blocks)
	if err != nil do return
	sync.mutex_lock(&chunks_mutex)
	if chunks[position] != nil do free(chunks[position].mesh)
	free(chunks[position])
	delete_key(&chunks, position)
	sync.mutex_unlock(&chunks_mutex)
	free(task.data)


}

chunk_load_worker :: proc(task: thread.Task) {
	position := (cast(^ChunkPos)task.data)^
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
	chunk.should_be_loaded = true
	chunk.done_with_init = true
	chunk.dirty = true
	header := (^ChunkHeader)(raw_data(data))^
	if header.magic_number != CHUNK_MAGIC_NUMBER do return
	block_index: u16
	offset := size_of(ChunkHeader)
	palette := make([dynamic]string)
	for i := u16(0); i < header.palette_len; i += 1 {
		string_len := int(data[offset])
		start := offset + 1
		string := strings.clone(string(data[start:start + string_len]))
		append(&palette, string)
		offset += string_len + 1
	}
	rle_entries := slice.reinterpret([]RLEPair, data[offset:])
	block: u16
	for entry, index in rle_entries {
		block_name := palette[entry.block]
		for i := u16(0); i < entry.length; i += 1 {
			chunk.blocks[block] = blocks[block_name].temp_id
			block += 1
		}
	}
	sync.mutex_lock(&chunks_mutex)
	free(chunks[position])
	chunks[position] = chunk
	sync.mutex_unlock(&chunks_mutex)
	for &string in palette {
		delete(string)
	}
	free(task.data)
	delete(palette)

}
