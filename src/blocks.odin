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

BlockID :: enum {
	empty = 0,
	stone,
	stone_cobble,
	stone_brick,
}
load_textures :: proc(blocks: ^map[string]Block) {
	blocks["stone"] = Block {
		display_name = "Stone",
		textures = BlockTextures {
			front = rl.LoadTexture("assets/textures/stone.png"),
			back = rl.LoadTexture("assets/textures/stone.png"),
			left = rl.LoadTexture("assets/textures/stone.png"),
			right = rl.LoadTexture("assets/textures/stone.png"),
			top = rl.LoadTexture("assets/textures/stone.png"),
			bottom = rl.LoadTexture("assets/textures/stone.png"),
		},
	}
	blocks["stone_cobble"] = Block {
		display_name = "Stone Cobble",
		textures = BlockTextures {
			front = rl.LoadTexture("assets/textures/stone_cobble.png"),
			back = rl.LoadTexture("assets/textures/stone_cobble.png"),
			left = rl.LoadTexture("assets/textures/stone_cobble.png"),
			right = rl.LoadTexture("assets/textures/stone_cobble.png"),
			top = rl.LoadTexture("assets/textures/stone_cobble.png"),
			bottom = rl.LoadTexture("assets/textures/stone_cobble.png"),
		},
	}
	blocks["stone_brick"] = Block {
		display_name = "Stone Brick",
		textures = BlockTextures {
			front = rl.LoadTexture("assets/textures/stone_brick.png"),
			back = rl.LoadTexture("assets/textures/stone_brick.png"),
			left = rl.LoadTexture("assets/textures/stone_brick.png"),
			right = rl.LoadTexture("assets/textures/stone_brick.png"),
			top = rl.LoadTexture("assets/textures/stone_brick.png"),
			bottom = rl.LoadTexture("assets/textures/stone_brick.png"),
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
