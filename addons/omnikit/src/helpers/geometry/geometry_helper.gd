class_name OmniKitGeometryHelper


## Calculates the arrangement of a specified MeshInstance3D within a BoxShape3D.
## It determines how many meshes fit horizontally and vertically, and returns
## a dictionary containing the total count and the precise world positions (slots)
## for each potential mesh instance.
static func calculate_mesh_arrangement_on_box_shape(box: BoxShape3D, mesh_instance: MeshInstance3D, spacing: Vector3 = Vector3.ZERO, stack_horizontal: bool = true, stack_vertical: bool = false) -> Dictionary:
	assert(mesh_instance.mesh != null, "OmniKitGeometryHelper->calculate_mesh_arrangement_on_box_shape: The MeshInstance3D does not have a mesh assigned")
		
	var slots: Array = [] ## Array[Array[Vector3]] # Positions per row
	var mesh_size: Vector3 = (mesh_instance.get_aabb().size * mesh_instance.scale) + spacing

	var meshes_per_row: int = floori(box.shape.size.x / mesh_size.z)
	var rows: int = floori(box.shape.size.z / mesh_size.x)
	var initial_row_position: Vector3 = Vector3.LEFT * (box.shape.size.x / 2.0 - mesh_size.z / 2.0) 
	
	for row in rows:
		slots.append([])

		for mesh_index: int in meshes_per_row:
			var mesh_position: Vector3 = Vector3.ZERO + initial_row_position + Vector3.RIGHT * mesh_size.z * mesh_index
			
			if stack_horizontal:
				mesh_position.z += mesh_size.x * row
			
			if stack_vertical:
				mesh_position.y += mesh_size.y * row
			
			slots[row].append(mesh_position)

	return {
		"meshes_per_row": meshes_per_row,
		"rows": rows,
		"total": meshes_per_row * rows,
		"slots": slots
		}


static func get_random_mesh_surface_position(target: MeshInstance3D) -> Vector3:
	if target.mesh:
		var target_mesh_faces = target.mesh.get_faces()
		var random_face: Vector3 = target_mesh_faces[randi() % target_mesh_faces.size()] * target.scale
		
		random_face = Vector3(abs(random_face.x), abs(random_face.y), abs(random_face.z))
		
		return Vector3(
			randf_range(-random_face.x, random_face.x),
		 	randf_range(-random_face.y, random_face.y), 
			randf_range(-random_face.z, random_face.z)
		)
		
	return Vector3.ZERO


static func random_inside_unit_circle(position: Vector2, radius: float = 1.0) -> Vector2:
	var angle: float = randf() * 2.0 * PI
	return position + Vector2(cos(angle), sin(angle)) * radius


static func random_on_unit_circle(position: Vector2) -> Vector2:
	var angle: float = randf() * 2.0 * PI
	var radius: float = randf()
	
	return position + radius * Vector2(cos(angle), sin(angle))


static func random_point_in_rect(rect: Rect2) -> Vector2:
	randomize()
	
	var x: float = randf()
	var y: float = randf()
	
	return Vector2(rect.size.x * x, rect.size.y * y)

## Two concentric circles (donut basically)
static func random_point_in_annulus(center, radius_small, radius_large) -> Vector2:
	var square: Rect2 = Rect2(center - Vector2(radius_large, radius_large), Vector2(radius_large * 2, radius_large * 2))
	var point: Vector2 = Vector2.INF
	
	while not point:
		var test_point = random_point_in_rect(square)
		var distance = test_point.distance_to(center)
		
		if radius_small < distance and distance < radius_large:
			point = test_point
			
	return point

	
static func polygon_bounding_box(polygon: PackedVector2Array) -> Rect2:
	var min_vec: Vector2 = Vector2.INF
	var max_vec: Vector2 = -Vector2.INF
	
	for vec: Vector2 in polygon:
		min_vec = Vector2(min(min_vec.x, vec.x), min(min_vec.y, vec.y))
		max_vec =  Vector2(max(max_vec.x, vec.x), max(max_vec.y, vec.y))
		
	return Rect2(min_vec, max_vec - min_vec)


static func create_box_mesh(size: Vector3 = Vector3.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh.mesh = box
	
	return mesh
	

static func create_plane_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = size
	mesh.mesh = plane
	
	return mesh
	
	
static func create_quad_mesh(size: Vector2 = Vector2.ONE) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var quad = QuadMesh.new()
	quad.size = size
	mesh.mesh = quad
	
	return mesh


static func create_prism_mesh(size: Vector3 = Vector3.ONE, left_to_right: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = size
	prism.left_to_right = clampf(left_to_right, -2, 2)
	mesh.mesh = prism
	
	return mesh
	
	
static func create_cilinder_mesh(height: float = 2.0, top_radius: float = 0.5, bottom_radius: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = clampf(height, 0.001, 100.0)
	cylinder.top_radius = clampf(top_radius, 0, 100.0)
	cylinder.bottom_radius = clampf(bottom_radius, 0, 100.0)
	mesh.mesh = cylinder
	
	return mesh
	

static func create_sphere_mesh(height: float = 2.0, radius: float = 0.5, is_hemisphere: bool = false) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var cylinder = SphereMesh.new()
	cylinder.height = clampf(height, 0.001, 100.0)
	cylinder.radius = clampf(radius, 0, 100.0)
	cylinder.is_hemisphere = is_hemisphere
	mesh.mesh = cylinder
	
	return mesh
	
	
static func create_capsule_mesh(height: float = 2.0, radius: float = 0.5) -> MeshInstance3D:
	var mesh = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.height = clampf(height, 0.001, 100.0)
	capsule.radius = clampf(radius, 0, 100.0)
	mesh.mesh = capsule
	
	return mesh


static func volume_of_sphere(radius: float) -> float:
	return (4.0 / 3.0) * PI * pow(radius, 3)
	

static func volume_of_hollow_sphere(outer_radius: float, inner_radius: float) -> float:
	return (4.0 / 3.0) * PI *  (pow(outer_radius, 3) - pow(inner_radius, 3))
	

static func area_of_circle(radius: float) -> float:
	return PI * pow(radius, 2) 


static func area_of_triangle(base: float, perpendicular_height: float) -> float:
	return (base * perpendicular_height) / 2.0



# Time complexity O(n^2), the more complex method is faster, but is harder to write
static func is_valid_polygon(points: PackedVector2Array) -> bool:
	if points.size() < 3:
		return false  # A polygon must have at least 3 points

	for i in points.size():
		var start1: Vector2 = points[i]
		var end1: Vector2 = points[(i + 1) % points.size()]  # Wrap around to the first point
		
		for j in range(i + 1, points.size()):
			var start2: Vector2 = points[j]
			var end2: Vector2 = points[(j + 1) % points.size()]  # Wrap around to the first point
			
			# Skip adjacent edges or edges sharing a vertex
			if start1 == end2 or start2 == end1:
				continue
				
			if Geometry2D.segment_intersects_segment(start1, end1, start2, end2):
				return false  # Found an intersection, invalid polygon
	
	return true  # No intersections found


static func calculate_polygon_area(polygon: PackedVector2Array) -> float:
	if polygon.size() < 3:
		return 0.0
	
	var area: float = 0.0
	
	for i in polygon.size():
		var current: Vector2 = polygon[i]
		var next: Vector2 = polygon[(i + 1) % polygon.size()]
		
		area += current.x * next.y - current.y * next.x
		
	return absf(area) / 2.0


static func fracture_polygons_triangles(polygon: PackedVector2Array) -> Array:
	var fractured_polygons: Array = []
	var trianglies: Array = Geometry2D.triangulate_polygon(polygon)
	var chunks: Array
	
	for i in range(0, trianglies.size(), 3):
		chunks.append(trianglies.slice(i, i + 3))

	for n: Array in chunks:
		var triangle_points: PackedVector2Array
		
		for point in n:
			triangle_points.append(polygon[point])
			
		fractured_polygons.append(triangle_points)
	
	return fractured_polygons


# https://stackoverflow.com/questions/1073336/circle-line-segment-collision-detection-algorithm
static func segment_circle_intersects(start, end, center, radius) -> Array:
	var d = end - start
	var f = start - center
	
	var a = d.dot(d)
	var b = 2 * f.dot(d)
	var c = f.dot(f) - radius * radius
	var disc = b * b - 4 * a * c
	
	if disc < 0:
		return []
	
	disc = sqrt(disc)
	var candidates = [(-b - disc) / (2 * a), (-b + disc) / (2 * a)]
	
	var intersects = []
	
	for t in candidates:
		if t >= 0.0 and t <= 1.0:
			intersects.append((1 - t) * start + t * end)
		
	return intersects
				
# Returns intersection point(s) of a segment from 'a' to 'b' with a given rect, in order of increasing distance from 'a'
static func segment_rect_intersects(a, b, rect) -> Array:
	var points := []
	var corners := [rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]
	
	for i in range(4):
		var intersect = Geometry2D.segment_intersects_segment(a, b, corners[i - 1], corners[i])
		
		if intersect:
			if not points.is_empty() and intersect.distance_squared_to(a) < points[0].distance_squared_to(a):
				points.push_front(intersect)
			else:
				points.append(intersect)
				
			if points.size() == 2:
				break
				
	return points
	
#https://en.wikibooks.org/wiki/Algorithm_Implementation/Geometry/Rectangle_difference	
static func rect_difference(r1: Rect2, r2: Rect2) -> Array:
	var result = []
	var top_height = r2.position.y - r1.position.y
	
	if top_height > 0:
		result.append(Rect2(r1.position.x, r1.position.y, r1.size.x, top_height))
		
	var bottom_y = r2.position.y + r2.size.y
	var bottom_height = r1.size.y - (bottom_y - r1.position.y)
	
	if bottom_height > 0 and bottom_y < r1.position.y + r1.size.y:
		result.append(Rect2(r1.position.x, bottom_y, r1.size.x, bottom_height))
		
	var y1 = max(r1.position.y, r2.position.y)
	var y2 = min(bottom_y, (r1.position.y + r1.size.y))
	var lr_height = y2 - y1
	
	var left_width = r2.position.x - r1.position.x
	
	if left_width > 0 and lr_height > 0:
		result.append(Rect2(r1.position.x, y1, left_width, lr_height))
		
	var right_x = r2.position.x + r2.size.x
	var right_width = r1.size.x - (right_x - r1.position.x)
	
	if right_width > 0 and lr_height > 0:
		result.append(Rect2(right_x, y1, right_width, lr_height))
	
	return result
