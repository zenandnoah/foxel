package foxel

import "core:math"
import rl "vendor:raylib"

get_voxel_hit :: proc() -> (hit: bool, block_pos: rl.Vector3, normal: rl.Vector3) {
	ray := rl.Ray {
		position  = camera.position,
		direction = rl.Vector3Normalize(camera.target - camera.position),
	}
	max_distance := f32(32.0)
	step := f32(0.1)

	pos := ray.position

	for t := f32(0); t < max_distance; t += step {
		pos = ray.position + ray.direction * t

		bx := i32(math.floor(pos.x))
		by := i32(math.floor(pos.y))
		bz := i32(math.floor(pos.z))

		chunk_pos := ChunkPos {
			x = bx / CHUNK_X,
			z = bz / CHUNK_Z,
		}

		chunk := chunks[chunk_pos]
		if chunk == nil do continue

		lx := bx - chunk_pos.x * CHUNK_X
		lz := bz - chunk_pos.z * CHUNK_Z

		if lx < 0 || lx >= CHUNK_X || by < 0 || by >= CHUNK_Y || lz < 0 || lz >= CHUNK_Z {
			continue
		}

		idx := coordinate_to_index(rl.Vector3{f32(lx), f32(by), f32(lz)})


		if chunk.blocks[idx] != 0 {
			return true, rl.Vector3{f32(bx), f32(by), f32(bz)}, normal
		}
	}

	return false, rl.Vector3{}, rl.Vector3{}
}
