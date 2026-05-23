package foxel

import "core:fmt"
import rl "vendor:raylib"

Side :: enum {
	left,
	right,
	front,
	back,
	top,
	bottom,
	all,
}
hit: bool
block_pos: rl.Vector3
normal: rl.Vector3
camera: rl.Camera3D
main :: proc() {

	init()
	defer deinit()
	load_chunk(ChunkPos{}, "test")
	// chunk_one.blocks[0] = .stone
	// chunk_one.blocks[0] = .stone
	// chunks[ChunkPos{0,0}].blocks[coordinate_to_index(rl.Vector3{3,0,0})] = .stone_cobble
	for !rl.WindowShouldClose() {
		hit, block_pos, normal = get_voxel_hit()
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		for chunk in chunks {
			if chunks[chunk].dirty {
				update_chunk(chunk)
			}
			render_chunk(chunk)
		}
		if hit {
			rl.DrawCubeWires(block_pos + rl.Vector3{0.5, 0.5, 0.5}, 1, 1, 1, rl.PURPLE)
		}
		rl.DrawGrid(50, 1)
		rl.EndMode3D()
		draw_gui(&camera)
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}
	for chunk in chunks {
		save_chunk(chunk, "test")

	}

}
