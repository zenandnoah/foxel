package foxel
import "core:fmt"
import "core:os"
import rl "vendor:raylib"
CHUNK_X :: 16
CHUNK_Y :: 128
CHUNK_Z :: 16
Chunk :: struct {
	blocks:   [CHUNK_X * CHUNK_Y * CHUNK_Z]BlockID,
	position: ChunkPos,
	dirty:    bool,
}
ChunkPos :: struct {
	x: i32,
	z: i32,
}
index_to_coordinate :: proc(index: int) -> rl.Vector3 {
	coordinate: rl.Vector3
	coordinate[0] = f32(index % CHUNK_X)
	coordinate[1] = f32((index / CHUNK_X) % CHUNK_Z)
	coordinate[2] = f32(index / (CHUNK_X * CHUNK_Z))
	return coordinate
}

coordinate_to_index :: proc(coordinate: rl.Vector3) -> int {
	return(
		int(coordinate[1]) * CHUNK_X * CHUNK_Z +
		int(coordinate[2]) * CHUNK_X +
		int(coordinate[0]) \
	)
}

save_chunk :: proc(chunk: ^Chunk, world: string) {
	file, err := os.open(
		fmt.tprintf("worlds/%s/%i_%i.cnk", world, chunk.position.x, chunk.position.z),
		os.O_CREATE | os.O_WRONLY | os.O_TRUNC,
	)
	defer os.close(file)
	if err != nil {
		fmt.println("can't save chunk")
		fmt.println(err)
	}
	os.write_ptr(file, &chunk.blocks, size_of(chunk.blocks))

}

load_chunk :: proc(chunk: ^Chunk, position: ChunkPos, world: string) {
	chunk.position = position
	fmt.println(position.x, position.z)
	file, err := os.open(fmt.tprintf("worlds/%s/%i_%i.cnk", world, position.x, position.z))
	if err != nil {
		fmt.println("here")
		return
	}

	data, err_data := os.read_entire_file_from_file(file, context.temp_allocator)
	if (err_data != nil) {
		fmt.println("there")
		return
	}
	for byte, index in data {
		if (index == 32768) do break
		chunk.blocks[index] = BlockID(byte)
	}
}
