package foxel
import rl "vendor:raylib"
CHUNK_X :: 16
CHUNK_Y :: 128
CHUNK_Z :: 16
Chunk :: struct {
	blocks:   [CHUNK_X * CHUNK_Y * CHUNK_Z]BlockID,
	position: rl.Vector2,
	dirty:    bool,
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
