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
}
main :: proc() {
	width := i32(1920)
	height := i32(1080)
	rl.InitWindow(width, height, "foxel")
	defer rl.CloseWindow()

	rl.SetTargetFPS(180)

	camera := rl.Camera3D {
		position   = {0, 10, 10},
		target     = {0, 0, 0},
		up         = {0, 1, 0},
		fovy       = 45,
		projection = .PERSPECTIVE,
	}

	blocks := make(map[string]Block)
	load_textures(&blocks)
	defer unload_textures(&blocks)
	mono := rl.LoadFont("assets/fonts/ticketing.regular.ttf")
	defer rl.UnloadFont(mono)
	chunks := make(map[ChunkPos]^Chunk)
	chunk_one := new(Chunk)
	load_chunk(chunk_one, ChunkPos{}, "test")
	// chunk_one.blocks[0] = .stone
	chunks[ChunkPos{}] = chunk_one
	for !rl.WindowShouldClose() {
		ray := rl.Ray{
			position = camera.position,
			direction = rl.Vector3Normalize(camera.target - camera.position)
		}

		hit, block_pos, normal := get_voxel_hit(ray, &chunks)

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		for chunk in chunks {
			render_chunk(chunks[chunk], &blocks)
		}
		if hit {
			rl.DrawCubeWires(block_pos + rl.Vector3{0.5,0.5,0.5}, 1, 1, 1, rl.PURPLE)
		}
		rl.DrawGrid(50, 1)
		rl.EndMode3D()
		rl.DrawFPS(10, 40)
		rl.DrawTextEx(
			mono,
			fmt.ctprintf(
				"Pos (%.2f, %.2f, %.2f)",
				camera.position[0],
				camera.position[1],
				camera.position[2],
			),
			rl.Vector2{10, 80},
			20,
			5,
			rl.WHITE,
		)
		rl.DrawTextEx(
			mono,
			fmt.ctprintf(
				"Hit %v Sel (%.2f, %.2f, %.2f)",
				hit,
				block_pos[0],
				block_pos[1],
				block_pos[2],
			),
			rl.Vector2{10, 120},
			20,
			5,
			rl.WHITE,
		)
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}
	for chunk in chunks {
		save_chunk(chunks[chunk], "test")
	}

}
