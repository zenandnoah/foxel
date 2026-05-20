package foxel

import rl "vendor:raylib"

BlockTextures :: struct {
	front:  rl.Texture2D,
	back:   rl.Texture2D,
	left:   rl.Texture2D,
	right:  rl.Texture2D,
	top:    rl.Texture2D,
	bottom: rl.Texture2D,
}
Block :: struct {
	display_name: string,
	textures:     BlockTextures,
}
load_textures :: proc(blocks: ^map[string]Block) {
	blocks["stone"] = Block {
		display_name = "Stone",
		textures = BlockTextures {
			front = rl.LoadTexture("assets/textures/awesome_stone.png"),
			back = rl.LoadTexture("assets/textures/awesome_stone.png"),
			left = rl.LoadTexture("assets/textures/awesome_stone.png"),
			right = rl.LoadTexture("assets/textures/awesome_stone.png"),
			top = rl.LoadTexture("assets/textures/awesome_stone.png"),
			bottom = rl.LoadTexture("assets/textures/awesome_stone.png"),
		},
	}
}
unload_textures :: proc(blocks: ^map[string]Block) {
	for block in blocks {
		t := blocks[block].textures
		rl.UnloadTexture(t.front)
		rl.UnloadTexture(t.back)
		rl.UnloadTexture(t.left)
		rl.UnloadTexture(t.right)
		rl.UnloadTexture(t.top)
		rl.UnloadTexture(t.bottom)
	}
}
