package foxel

import "core:fmt"
import rl "vendor:raylib"
mono: rl.Font
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
}
load_fonts :: proc() {
	mono = rl.LoadFont("assets/fonts/ticketing.regular.ttf")

}
unload_fonts :: proc() {
	rl.UnloadFont(mono)
}
