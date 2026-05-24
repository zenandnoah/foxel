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
chunk_pattern_to_render: [dynamic]ChunkPos
update_render_distance :: proc(render_distance: i32) {
	chunk_pattern_to_render = make([dynamic]ChunkPos)
	for x: i32 = render_distance; x > -render_distance; x -= 1 {
		for z: i32 = render_distance; z > -render_distance; z -= 1 {
			if x * x + z * z < render_distance * render_distance {
				append(&chunk_pattern_to_render, ChunkPos{x, z})
			}
		}
	}
}
main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track)
		context.allocator = mem.tracking_allocator(track)
		defer {
			if len(track.allocation_map > 0) {
				fmt.print("didn't free: ", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.printfln("%v bytes at %v", entry.size, entry.location)
				}
			}

		}
	}
	init()
	defer deinit()
	update_render_distance(1)
	// chunk_one.blocks[0] = .stone
	// chunk_one.blocks[0] = .stone
	// chunks[ChunkPos{0,0}].blocks[coordinate_to_index(rl.Vector3{3,0,0})] = .stone_cobble
	for !rl.WindowShouldClose() {
		for chunk in chunk_pattern_to_render {
			chunk_pos := ChunkPos {
				chunk.x + i32(camera.position.x / CHUNK_X),
				chunk.z + i32(camera.position.z / CHUNK_Z),
			}
			_, loaded := &chunks[chunk_pos]
			if !loaded do load_chunk(chunk_pos, "test")

			chunks[chunk_pos].should_be_loaded = true
		}

		hit, block_pos, normal = get_voxel_hit()
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		for chunk in chunks {

			if !chunks[chunk].should_be_loaded {
				save_chunk(chunk, "test")
				continue
			}
			if chunks[chunk].dirty {
				update_chunk_mesh(chunk)
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
