package foxel
import "core:fmt"
import "core:strconv"
import "core:strings"
import rl "vendor:raylib"
handle_command :: proc(command: string) -> bool {
	parts := strings.split(strings.to_lower(strings.trim_prefix(command, "/")), " ")
	switch parts[0] {
	case "fill":
		if len(parts) != 8 {
			// TODO: handle error
			return false
		}
		block := blocks[parts[1]].temp_id
		x1 := strconv.parse_i64(parts[2]) or_return
		y1 := strconv.parse_i64(parts[3]) or_return
		z1 := strconv.parse_i64(parts[4]) or_return
		x2 := strconv.parse_i64(parts[5]) or_return
		y2 := strconv.parse_i64(parts[6]) or_return
		z2 := strconv.parse_i64(parts[7]) or_return
		for x in x1 ..= x2 {
			for y in y1 ..= y2 {
				for z in z1 ..= z2 {
					chunk := chunks[ChunkPos{i32(x) / CHUNK_X, i32(z) / CHUNK_Z}]
					index := coordinate_to_index(rl.Vector3{f32(x), f32(y), f32(z)})
					chunk.blocks[index] = block
					chunk.dirty = true
				}
			}
		}
	}
	return true
}
