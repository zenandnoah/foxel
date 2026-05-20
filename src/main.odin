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
BlockTextures :: struct {
	front:  ^rl.Texture2D,
	back:   ^rl.Texture2D,
	left:   ^rl.Texture2D,
	right:  ^rl.Texture2D,
	top:    ^rl.Texture2D,
	bottom: ^rl.Texture2D,
}
Block :: struct {
	name:     string,
	textures: BlockTextures,
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
	test_tex := rl.LoadTexture("assets/textures/test.png")
	defer rl.UnloadTexture(tex)
	stone := Block {
		name = "stone",
		textures = BlockTextures {
			front = &tex,
			back = &tex,
			left = &tex,
			right = &tex,
			top = &test_tex,
			bottom = &tex,
		},
	}
	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground(rl.BLUE)
		rl.BeginMode3D(camera)
		render_block(&stone, rl.Vector3{0, 0, 0})
		rl.DrawGrid(50, 1)
		rl.EndMode3D()
		rl.DrawFPS(10, 40)
		rl.UpdateCamera(&camera, .FREE)
		rl.DisableCursor()
	}

}
