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

	tex := rl.LoadTexture("assets/textures/awesome_stone.png")
	defer rl.UnloadTexture(tex)
	mesh := rl.GenMeshPlane(1, 1, 1, 1)
	model := rl.LoadModelFromMesh(mesh)
	rl.SetMaterialTexture(&model.materials[0], .ALBEDO, tex)
	// model.transform = rl.MatrixRotateX(1)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)

		rl.DrawModel(model, rl.Vector3{1, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{2, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{3, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{4, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{5, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{6, 0, 1}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{1, 0, 0}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{2, 0, 0}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{3, 0, 0}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{4, 0, 0}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{5, 0, 0}, 1, rl.WHITE)
		rl.DrawModel(model, rl.Vector3{6, 0, 0}, 1, rl.WHITE)
		rl.EndMode3D()
		rl.DrawFPS(10, 40)
		rl.UpdateCamera(&camera, .FIRST_PERSON)
		rl.DisableCursor()
	}

}
