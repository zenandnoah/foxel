package foxel

import "core:fmt"
import "core:math"
import "core:os"
import "core:reflect"
import "core:strings"
import rl "vendor:raylib"
MAX_TILE_SIZE :: 60
BlockSide :: struct {
	block: BlockID,
	side:  Side,
}
BlockNew :: struct {
	name:     string,
	textures: [7][2]i32,
}
blocks_new: map[BlockID]BlockNew
make_atlas :: proc() {
	blocks_new := make(map[BlockID]BlockNew)
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

	cols := i32(math.sqrt_f16(f16(len(file_infos) + 1)))
	rows: i32 = cols
	if i32(len(file_infos) + 1) % cols != 0 do rows += 1
	current_row: i32
	current_col: i32
	canvas := rl.GenImageColor(cols * MAX_TILE_SIZE, rows * MAX_TILE_SIZE, rl.BLANK)
	for file in file_infos {
		name := strings.trim_suffix(file.name, ".png")
		name_split := strings.split(name, "-") or_continue
		block := reflect.enum_from_name(BlockID, name_split[0]) or_continue
		if current_col == cols - 1 {
			current_col = 0
			current_row += 1
		} else {
			current_col += 1
		}
		old, exists := blocks_new[block]
		if !exists {
			old = new(BlockNew)^

			output, _ := strings.replace_all(strings.to_ada_case(name_split[0]), "_", " ")
			old.name = output
		}
		image := rl.LoadImage(fmt.ctprintf("assets/textures/%s", file.name))
		dst := rl.Rectangle {
			x      = f32(current_col * MAX_TILE_SIZE),
			y      = f32(current_row * MAX_TILE_SIZE),
			width  = MAX_TILE_SIZE,
			height = MAX_TILE_SIZE,
		}

		// Source rect — full image
		src := rl.Rectangle {
			x      = 0,
			y      = 0,
			width  = f32(image.width),
			height = f32(image.height),
		}

		// Blit tile onto canvas
		rl.ImageDraw(&canvas, image, src, dst, rl.WHITE)
		fmt.println(block, current_col * MAX_TILE_SIZE, current_row * MAX_TILE_SIZE)
		if (len(name_split) < 2) {
			old.textures[6] = [2]i32{current_col, current_row}
			blocks_new[block] = old
			continue
		}
		side := reflect.enum_from_name(Side, name_split[1]) or_continue
		old.textures[side] = [2]i32{current_col, current_row}
		blocks_new[block] = old

	}
	rl.ExportImage(canvas, "assets/atlas.png")
	for block in blocks_new {
	}

}
