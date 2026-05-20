package main

import "core:math"
import rl "vendor:raylib"

Side :: enum {
	left,
	right,
	front,
	back,
	top,
	bottom,
}
render_face :: proc(side: Side, texture: rl.Texture2D, coordinate: rl.Vector3) {
	mesh := rl.GenMeshPlane(1, 1, 1, 1)
	model := rl.LoadModelFromMesh(mesh)
	rl.SetMaterialTexture(&model.materials[0], .ALBEDO, texture)
	#partial switch (side) {
	case .front:
		model.transform = rl.MatrixRotateX(math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, .5, 0}, 1, rl.WHITE)
	case .back:
		model.transform = rl.MatrixRotateX(-math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, .5, -1}, 1, rl.WHITE)
	case .left:
		model.transform = rl.MatrixRotateZ(-math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{1, .5, -.5}, 1, rl.WHITE)
	case .right:
		model.transform = rl.MatrixRotateZ(math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{0, .5, -.5}, 1, rl.WHITE)
	case .top:
		rl.DrawModel(model, coordinate + rl.Vector3{.5, 1, -.5}, 1, rl.WHITE)
	case .bottom:
		model.transform = rl.MatrixRotateZ(math.PI)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, 0, -.5}, 1, rl.WHITE)
	}
}
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

	tex := rl.LoadTexture("assets/textures/awesome_stone.png")
	defer rl.UnloadTexture(tex)

	for !rl.WindowShouldClose() {
		vertical_move_amount: f32 = .1
		if (rl.IsKeyDown(.LEFT_SHIFT)) {
			camera.position[1] -= vertical_move_amount
			camera.target[1] -= vertical_move_amount
		}
		if (rl.IsKeyDown(.SPACE)) {
			camera.position[1] += vertical_move_amount
			camera.target[1] += vertical_move_amount
		}
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
		rl.UpdateCamera(&camera, .FIRST_PERSON)
		rl.DisableCursor()
	}

}
