package foxel

import rl "vendor:raylib"
import "core:fmt"	

Side :: enum {
	left,
	right,
	front,
	back,
	top,
	bottom,
}
main :: proc() {
	width := i32(640)
	height := i32(480)
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
	mono := rl.LoadFont("assets/fonts/ticketing.regular.ttf")
	defer rl.UnloadFont(mono)

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
		rl.DrawTextEx(mono, fmt.ctprintf("Pos (%.2f, %.2f, %.2f)", camera.position[0], camera.position[1], camera.position[2]), rl.Vector2{10, 80}, 20, 5, rl.WHITE)
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}

}
