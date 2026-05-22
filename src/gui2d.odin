package foxel

import "core:fmt"
import rl "vendor:raylib"
mono: rl.Font
MIDDLE_X :: RESOLUTION_WIDTH / 2
MIDDLE_Y :: RESOLUTION_HEIGHT / 2
CURSOR_LEN :: 20
CURSOR_THICK :: 2
draw_gui :: proc(camera: ^rl.Camera3D) {
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
	rl.DrawLineEx(
		rl.Vector2{MIDDLE_X, MIDDLE_Y - CURSOR_LEN},
		rl.Vector2{MIDDLE_X, MIDDLE_Y + CURSOR_LEN},
		CURSOR_THICK,
		rl.WHITE,
	)
	rl.DrawLineEx(
		rl.Vector2{MIDDLE_X - CURSOR_LEN, MIDDLE_Y},
		rl.Vector2{MIDDLE_X + CURSOR_LEN, MIDDLE_Y},
		CURSOR_THICK,
		rl.WHITE,
	)
}
load_fonts :: proc() {
	mono = rl.LoadFont("assets/fonts/ticketing.regular.ttf")

}
unload_fonts :: proc() {
	rl.UnloadFont(mono)
}
