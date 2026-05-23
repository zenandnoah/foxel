package foxel
import "core:fmt"
import "core:os"
import rl "vendor:raylib"
CHUNK_X :: 16
CHUNK_Y :: 128
CHUNK_Z :: 16
Chunk :: struct {
	blocks:           [CHUNK_X * CHUNK_Y * CHUNK_Z]BlockID,
	position:         ChunkPos,
	dirty:            bool,
	should_be_loaded: bool,
	mesh:             rl.Mesh,
}
ChunkPos :: struct {
	x: i32,
	z: i32,
}
chunks: map[ChunkPos]^Chunk
generate_chunk :: proc(position: ChunkPos) {
	chunk := new(Chunk)
	chunk.position = position
	for &block, index in chunk.blocks {
		if (index == 256) do break
		block = .stone
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
	file, err := os.open(
		fmt.tprintf("worlds/%s/%i_%i.cnk", world, position.x, position.z),
		os.O_CREATE | os.O_WRONLY | os.O_TRUNC,
	)
	defer os.close(file)
	if err != nil {
		fmt.println("can't save chunk")
		fmt.println(err)
	}
	_, write_err := os.write_ptr(file, &chunks[position].blocks, size_of(chunks[position].blocks))
	if write_err != nil do return
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
	first_byte: byte
	for byte, index in data {
		if (index % 2 == 0) {
			first_byte = byte
			continue
		}
		if (index == 32768 * 2 - 1) do break
		chunk.blocks[(index - 1) / 2] = BlockID(first_byte + byte)
	}
	chunks[position] = chunk
	update_chunk_mesh(position)
}
