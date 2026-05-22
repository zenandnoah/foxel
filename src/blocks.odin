package foxel

import "core:fmt"
import "core:os"
import "core:strings"
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

BlockID :: enum u16 {
	empty        = 0,
	stone        = 1,
	stone_cobble = 2,
	stone_brick  = 3,
	oak_planks   = 4,
}
textures: map[string]rl.Texture2D
blocks: map[string]Block
load_textures :: proc() {
	textures = make(map[string]rl.Texture2D)
	texture_dir, err := os.open("assets/textures")
	if (err != 0) {
		fmt.println("Could not open textures directory")
		return
	}
	defer os.close(texture_dir)
	file_infos, read_err := os.read_all_directory(texture_dir, context.allocator)
	if (read_err != 0) {
		fmt.println("Couldn't read textures directory")
		return
	}
	for file in file_infos {
		name := strings.trim_suffix(file.name, ".png")
		textures[name] = rl.LoadTexture(fmt.ctprintf("assets/textures/%s", file.name))
	}
	blocks["stone"] = Block {
		display_name = "Stone",
		textures = BlockTextures {
			front = &textures["stone"],
			back = &textures["stone"],
			left = &textures["stone"],
			right = &textures["stone"],
			top = &textures["stone"],
			bottom = &textures["stone"],
		},
	}
	blocks["stone_cobble"] = Block {
		display_name = "Stone Cobble",
		textures = BlockTextures {
			front = &textures["stone_cobble"],
			back = &textures["stone_cobble"],
			left = &textures["stone_cobble"],
			right = &textures["stone_cobble"],
			top = &textures["stone_cobble"],
			bottom = &textures["stone_cobble"],
		},
	}
	blocks["stone_brick"] = Block {
		display_name = "Stone Brick",
		textures = BlockTextures {
			front = &textures["stone_brick"],
			back = &textures["stone_brick"],
			left = &textures["stone_brick"],
			right = &textures["stone_brick"],
			top = &textures["stone_brick"],
			bottom = &textures["stone_brick"],
		},
	}
	blocks["oak_planks"] = Block {
		display_name = "Oak Planks",
		textures = BlockTextures {
			front = &textures["oak_planks"],
			back = &textures["oak_planks"],
			left = &textures["oak_planks"],
			right = &textures["oak_planks"],
			top = &textures["oak_planks"],
			bottom = &textures["oak_planks"],
		},
	}
}
unload_textures :: proc() {
	for key in textures {
		rl.UnloadTexture(textures[key])
	}
}
