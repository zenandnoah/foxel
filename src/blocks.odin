package foxel

import rl "vendor:raylib"

BlockTextures :: struct {
	front:  ^rl.Texture2D,
	back:   ^rl.Texture2D,
	left:   ^rl.Texture2D,
	right:  ^rl.Texture2D,
	top:    ^rl.Texture2D,
	bottom: ^rl.Texture2D,
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
stone: rl.Texture2D
stone_cobble: rl.Texture2D
stone_brick: rl.Texture2D
load_textures :: proc(blocks: ^map[string]Block) {
	stone = rl.LoadTexture("assets/textures/stone.png")
	blocks["stone"] = Block {
		display_name = "Stone",
		textures = BlockTextures {
			front = &stone,
			back = &stone,
			left = &stone,
			right = &stone,
			top = &stone,
			bottom = &stone,
		},
	}
	stone_cobble = rl.LoadTexture("assets/textures/stone_cobble.png")
	blocks["stone_cobble"] = Block {
		display_name = "Stone Cobble",
		textures = BlockTextures {
			front = &stone_cobble,
			back = &stone_cobble,
			left = &stone_cobble,
			right = &stone_cobble,
			top = &stone_cobble,
			bottom = &stone_cobble,
		},
	}
	stone_brick = rl.LoadTexture("assets/textures/stone_brick.png")
	blocks["stone_brick"] = Block {
		display_name = "Stone Brick",
		textures = BlockTextures {
			front = &stone_brick,
			back = &stone_brick,
			left = &stone_brick,
			right = &stone_brick,
			top = &stone_brick,
			bottom = &stone_brick,
		},
	}
}
unload_textures :: proc(blocks: ^map[string]Block) {
	for block in blocks {
		t := blocks[block].textures
		rl.UnloadTexture(t.front^)
		rl.UnloadTexture(t.back^)
		rl.UnloadTexture(t.left^)
		rl.UnloadTexture(t.right^)
		rl.UnloadTexture(t.top^)
		rl.UnloadTexture(t.bottom^)
	}
}
