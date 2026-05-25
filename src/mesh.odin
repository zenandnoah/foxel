package foxel

import "core:fmt"
import "core:sync"
import rl "vendor:raylib"
MeshBuilder :: struct {
	vertices:   [dynamic]f32,
	texcoords:  [dynamic]f32,
	normals:    [dynamic]f32,
	indices:    [dynamic]u16,
	face_count: u16,
}
MAX_FACES :: 1000
update_chunk_mesh :: proc(position: ChunkPos) {
	// free previous mesh if it exists
	sync.mutex_lock(&chunks_mutex)
	if chunks[position].mesh != nil && chunks[position].mesh.vertexCount > 0 {
		mesh := chunks[position].mesh
		mesh.vertices = nil
		mesh.texcoords = nil
		mesh.normals = nil
		mesh.indices = nil
		chunks[position].mesh = mesh
		rl.UnloadMesh(chunks[position].mesh^)
		free(chunks[position].mesh)
	}
	sync.mutex_unlock(&chunks_mutex)
	mesh_builder := new(MeshBuilder)
	for block, index in chunks[position].blocks {
		if (block == 0) {continue}
		coordinate := index_to_coordinate(index)
		coordinate[0] += f32(position.x) * CHUNK_X
		coordinate[2] += f32(position.z) * CHUNK_Z
		add_block(mesh_builder, block, coordinate)
	}
	fmt.println(chunks[position])
	sync.mutex_lock(&chunks_mutex)
	chunks[position].mesh = build_mesh(mesh_builder)
	chunks[position].dirty = false
	sync.mutex_unlock(&chunks_mutex)
	delete(mesh_builder.vertices)
	delete(mesh_builder.texcoords)
	delete(mesh_builder.normals)
	delete(mesh_builder.indices)
	free(mesh_builder)
}
render_chunk :: proc(position: ChunkPos) {
	if (chunks[position].mesh == nil) do return
	rl.DrawMesh(chunks[position].mesh^, material, rl.Matrix(1))
	sync.mutex_lock(&chunks_mutex)
	chunks[position].should_be_loaded = false
	sync.mutex_unlock(&chunks_mutex)
}
build_mesh :: proc(mesh_builder: ^MeshBuilder) -> ^rl.Mesh {
	mesh := new(rl.Mesh)
	mesh.vertexCount = i32(mesh_builder.face_count * 4)
	mesh.triangleCount = i32(mesh_builder.face_count * 2)

	mesh.vertices = raw_data(mesh_builder.vertices)
	mesh.texcoords = raw_data(mesh_builder.texcoords)
	mesh.normals = raw_data(mesh_builder.normals)
	mesh.indices = raw_data(mesh_builder.indices)

	rl.UploadMesh(mesh, false)
	return mesh
}
add_block :: proc(mesh_builder: ^MeshBuilder, block: u16, coordinate: rl.Vector3) {
	block_string := block_ids[block]
	x := coordinate[0]
	y := coordinate[1]
	z := coordinate[2]
	add_face(
		mesh_builder,
		{x, y + 1, z},
		{x, y + 1, z + 1},
		{x + 1, y + 1, z + 1},
		{x + 1, y + 1, z},
		block_string,
		.top,
	)
	add_face(
		mesh_builder,
		{x, y, z + 1},
		{x, y, z},
		{x + 1, y, z},
		{x + 1, y, z + 1},
		block_string,
		.bottom,
	)
	add_face(
		mesh_builder,
		{x, y, z + 1},
		{x + 1, y, z + 1},
		{x + 1, y + 1, z + 1},
		{x, y + 1, z + 1},
		block_string,
		.front,
	)
	add_face(
		mesh_builder,
		{x + 1, y, z},
		{x, y, z},
		{x, y + 1, z},
		{x + 1, y + 1, z},
		block_string,
		.back,
	)
	add_face(
		mesh_builder,
		{x + 1, y, z + 1},
		{x + 1, y, z},
		{x + 1, y + 1, z},
		{x + 1, y + 1, z + 1},
		block_string,
		.right,
	)
	add_face(
		mesh_builder,
		{x, y, z},
		{x, y, z + 1},
		{x, y + 1, z + 1},
		{x, y + 1, z},
		block_string,
		.left,
	)
}
// p0..p3: quad corners in counter-clockwise order
add_face :: proc(
	mesh_builder: ^MeshBuilder,
	p0, p1, p2, p3: rl.Vector3,
	block: string,
	side: Side,
) {
	normal := normals[side]
	base := u16(mesh_builder.face_count * 4)

	// vertices (4 corners × 3 floats)
	verts := [4]rl.Vector3{p0, p1, p2, p3}
	for v in verts {
		append(&mesh_builder.vertices, v.x, v.y, v.z)
	}
	// UVs from atlas tile
	uvs := blocks[block].atlas_uv_per_face[side]
	if uvs[0] == {0, 0} {
		// use default texture since one hasn't been set
		uvs = blocks[block].atlas_uv_per_face[6]
	}
	for uv in uvs {
		append(&mesh_builder.texcoords, uv[0], uv[1])
	}

	// normals (same for all 4 verts on a flat face)
	for _ in 0 ..< 4 {
		append(&mesh_builder.normals, normal.x, normal.y, normal.z)
	}

	// two triangles: 0-1-2 and 0-2-3
	append(&mesh_builder.indices, base + 0, base + 1, base + 2, base + 0, base + 2, base + 3)

	mesh_builder.face_count += 1
}
