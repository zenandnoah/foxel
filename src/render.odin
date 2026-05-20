package foxel

import "core:math"
import rl "vendor:raylib"

render_face :: proc(side: Side, texture: rl.Texture2D, coordinate: rl.Vector3) {
	mesh := rl.GenMeshPlane(1, 1, 1, 1)
	model := rl.LoadModelFromMesh(mesh)
	defer rl.UnloadModel(model)
	rl.SetMaterialTexture(&model.materials[0], .ALBEDO, texture)
	#partial switch (side) {
	case .front:
		model.transform = rl.MatrixRotateX(math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, .5, 0}, 1, rl.WHITE)
	case .back:
		model.transform = rl.MatrixRotateX(-math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, .5, -1}, 1, rl.WHITE)
	case .left:
		model.transform = rl.MatrixRotateZ(-math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{1, .5, -.5}, 1, rl.WHITE)
	case .right:
		model.transform = rl.MatrixRotateZ(math.PI / 2)
		rl.DrawModel(model, coordinate + rl.Vector3{0, .5, -.5}, 1, rl.WHITE)
	case .top:
		rl.DrawModel(model, coordinate + rl.Vector3{.5, 1, -.5}, 1, rl.WHITE)
	case .bottom:
		model.transform = rl.MatrixRotateZ(math.PI)
		rl.DrawModel(model, coordinate + rl.Vector3{.5, 0, -.5}, 1, rl.WHITE)
	}
}
