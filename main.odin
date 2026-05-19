package main

import rl "vendor:raylib"

main :: proc() {
	width := i32(1920)
	height := i32(1080)
	rl.InitWindow(width, height, "box2d-raylib")
	defer rl.CloseWindow()

	rl.SetTargetFPS(180)

	camera := rl.Camera {
		position   = {0, 10, 10},
		target     = {0, 0, 0},
		up         = {0, 1, 0},
		fovy       = 45,
		projection = .PERSPECTIVE,
	}

	tex := rl.LoadTexture("test.png")
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.BeginMode3D(camera)

		rl.DrawCube(rl.Vector3{0, 0, 0}, 1, 1, 1, rl.ORANGE)
		rl.DrawCubeWires(rl.Vector3{0, 0, 0}, 1, 1, 1, rl.BLACK)
		rl.DrawBillboard(camera, tex, rl.Vector3{5, 5, 5}, 1, rl.WHITE)
		rl.DrawModel()
		rl.EndMode3D()
		rl.DrawFPS(10, 40)
		rl.UpdateCamera(&camera, .FIRST_PERSON)
		rl.DisableCursor()
	}

}
