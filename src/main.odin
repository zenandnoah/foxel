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
	width := i32(1366)
	height := i32(768)
	rl.InitWindow(width, height, "box2d-raylib")
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
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		render_block(&blocks["stone"], rl.Vector3{0, 0, 0})
		render_block(&blocks["stone"], rl.Vector3{1, 0, 0})
		render_block(&blocks["stone"], rl.Vector3{2, 0, 0})
		render_block(&blocks["stone_cobble"], rl.Vector3{0, 0, 1})
		render_block(&blocks["stone_cobble"], rl.Vector3{1, 0, 1})
		render_block(&blocks["stone_cobble"], rl.Vector3{2, 0, 1})
		render_block(&blocks["stone_brick"], rl.Vector3{0, 0, 2})
		render_block(&blocks["stone_brick"], rl.Vector3{1, 0, 2})
		render_block(&blocks["stone_brick"], rl.Vector3{2, 0, 2})
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
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}

}
