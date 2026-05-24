package foxel

import "core:fmt"
import "core:math"
import "core:os"
import "core:reflect"
import "core:strings"
import rl "vendor:raylib"
MAX_TILE_SIZE :: 60
Block :: struct {
	name:              string,
	temp_id:           u16,
	atlas_uv_per_face: [7][4][2]f32,
}

blocks: map[string]Block
block_ids: [dynamic]string
make_atlas :: proc() -> rl.Texture {
	append(&block_ids, "empty")
	blocks = make(map[string]Block)
	texture_dir, err := os.open("assets/textures")
	if (err != 0) {
		fmt.println("Could not open textures directory")
		return rl.LoadTexture("")
	}
	defer os.close(texture_dir)
	file_infos, read_err := os.read_all_directory(texture_dir, context.allocator)
	if (read_err != 0) {
		fmt.println("Couldn't read textures directory")
		return rl.LoadTexture("")
	}

	cols := i32(math.sqrt_f16(f16(len(file_infos) + 1)))
	rows: i32 = cols
	if i32(len(file_infos) + 1) % cols != 0 do rows += 1
	current_row: i32
	current_col: i32
	canvas := rl.GenImageColor(cols * MAX_TILE_SIZE, rows * MAX_TILE_SIZE, rl.BLANK)
	blocks["empty"] = Block{}
	for file in file_infos {
		name := strings.trim_suffix(file.name, ".png")
		name_split := strings.split(name, "-") or_continue
		block := name_split[0]
		if current_col == cols - 1 {
			current_col = 0
			current_row += 1
		} else {
			current_col += 1
		}
		old, exists := blocks[block]
		if !exists {
			old = new(Block)^

			output, _ := strings.replace_all(strings.to_ada_case(name_split[0]), "_", " ")
			old.name = output
			append(&block_ids, block)
			old.temp_id = u16(len(block_ids) - 1)
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
		side_str := "all"
		if (len(name_split) > 1) {
			side_str = name_split[1]
		}
		side := reflect.enum_from_name(Side, side_str) or_else Side.all
		u0 := f32(current_col) / f32(cols)
		v0 := f32(current_row) / f32(rows)
		old.atlas_uv_per_face[side] = {
			{u0, v0},
			{u0 + 1 / f32(cols), v0},
			{u0 + 1 / f32(cols), v0 + 1 / f32(rows)},
			{u0, v0 + 1 / f32(rows)},
		}
		blocks[block] = old

	}
	fmt.println(blocks)
	fmt.println(block_ids)

	rl.ExportImage(canvas, "assets/atlas.png")
	texture := rl.LoadTextureFromImage(canvas)
	rl.SetTextureFilter(texture, .POINT)
	return texture

}
