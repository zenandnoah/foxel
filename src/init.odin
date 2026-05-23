package foxel
import "core:fmt"
import rl "vendor:raylib"
RESOLUTION_WIDTH :: 1920
RESOLUTION_HEIGHT :: 1080
normals: [6]rl.Vector3
material: rl.Material
atlas: rl.Texture
init :: proc() {
	width := i32(RESOLUTION_WIDTH)
	height := i32(RESOLUTION_HEIGHT)
	rl.InitWindow(width, height, "foxel")

	rl.SetTargetFPS(180)

	camera = rl.Camera3D {
		position   = {0, 10, 10},
		target     = {0, 0, 0},
		up         = {0, 1, 0},
		fovy       = 45,
		projection = .PERSPECTIVE,
	}
	load_fonts()

	chunks = make(map[ChunkPos]^Chunk)
	normals[Side.left] = rl.Vector3{1, 0, 0}
	normals[Side.right] = rl.Vector3{-1, 0, 0}
	normals[Side.front] = rl.Vector3{0, 0, 1}
	normals[Side.back] = rl.Vector3{0, 0, -1}
	normals[Side.top] = rl.Vector3{0, 1, 0}
	normals[Side.bottom] = rl.Vector3{0, -1, 0}
	atlas = make_atlas()
	material = rl.LoadMaterialDefault()
	rl.SetMaterialTexture(&material, .ALBEDO, atlas)
}
deinit :: proc() {
	unload_fonts()
	rl.UnloadTexture(atlas)
	rl.CloseWindow()
}
