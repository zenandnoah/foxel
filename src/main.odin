package foxel

import "core:fmt"
import "core:mem"
import "core:strings"
import "core:sync"
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
world: string
update_render_distance :: proc(render_distance: i32) {
	delete(chunk_pattern_to_render)
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
	world = "test"
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				builder: strings.Builder
				count: int
				strings.builder_init_none(&builder)
				for _, entry in track.allocation_map {
					if strings.contains(fmt.tprint(entry.location), "/core/") do continue
					count += 1

					strings.write_string(
						&builder,
						fmt.tprintfln("%v bytes at %v", entry.size, entry.location),
					)
				}

				fmt.println("didn't free: ", count)

				fmt.println(strings.to_string(builder))
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
			x := i32(camera.position.x) / CHUNK_X
			z := i32(camera.position.z) / CHUNK_Z
			// for negatives we should round up, otherwise the chunk we're in isnt the center
			if camera.position.x < 0 do x -= 1
			if camera.position.z < 0 do z -= 1
			chunk_pos := ChunkPos{chunk.x + x, chunk.z + z}
			_, loaded := &chunks[chunk_pos]
			if !loaded {
				sync.mutex_lock(&chunks_mutex)
				chunks[chunk_pos] = new(Chunk)
				sync.mutex_unlock(&chunks_mutex)
				queue_chunk_load(chunk_pos)
				continue
			}
			sync.mutex_lock(&chunks_mutex)
			chunks[chunk_pos].should_be_loaded = true
			sync.mutex_unlock(&chunks_mutex)
		}

		hit, block_pos, normal = get_voxel_hit()
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		// this also runs in the last loop
		for chunk in chunks {
			if !chunks[chunk].should_be_loaded && chunks[chunk].done_with_init {
				fmt.println(chunks[chunk].should_be_loaded)
				fmt.println("saving in main")
				queue_chunk_save(chunk)
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

}
