package foxel

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

	tex := rl.LoadTexture("assets/textures/awesome_stone.png")
	defer rl.UnloadTexture(tex)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		render_face(.front, tex, rl.Vector3{0, 0, 0})
		render_face(.left, tex, rl.Vector3{0, 0, 0})
		render_face(.right, tex, rl.Vector3{0, 0, 0})
		render_face(.back, tex, rl.Vector3{0, 0, 0})
		render_face(.top, tex, rl.Vector3{0, 0, 0})
		render_face(.bottom, tex, rl.Vector3{0, 0, 0})

		rl.DrawGrid(50, 1)
		rl.EndMode3D()
		rl.DrawFPS(10, 40)
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}

}
