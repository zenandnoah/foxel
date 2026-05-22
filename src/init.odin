package foxel
import rl "vendor:raylib"
init :: proc() {
	width := i32(1920)
	height := i32(1080)
	rl.InitWindow(width, height, "foxel")

	rl.SetTargetFPS(180)

	camera = rl.Camera3D {
		position   = {0, 10, 10},
		target     = {0, 0, 0},
		up         = {0, 1, 0},
		fovy       = 45,
		projection = .PERSPECTIVE,
	}
	load_textures()
	load_fonts()

	chunks = make(map[ChunkPos]^Chunk)
}
deinit :: proc() {
	unload_fonts()
	unload_textures()
	rl.CloseWindow()
}
