@tool
extends StaticBody2D
class_name TileBounds

@export
var fill_outer_bounds = false
@export
var collide_filled = false
@export
var debug_color = Color("0099b3", 0.45);

# TODO: Corners get filled in when fill_outer_bounds is false
# append_outer_borders strategy should be used instead to allow the area to
# be traversible

var parent: TileMap

func _get_configuration_warnings():
	return null

func append_outer_fills(visited: Array[Vector2i] = []) -> Array[Vector2i]:
	var bounds = parent.get_used_rect()
	bounds.position *= parent.tile_set.tile_size
	bounds.size *= parent.tile_set.tile_size
	
	var top = CollisionShape2D.new()
	top.shape = WorldBoundaryShape2D.new()
	top.shape.normal = Vector2(0, 1)
	top.position = Vector2(0, bounds.position.y)
	top.debug_color = debug_color
	self.add_child(top)
	
	var left = CollisionShape2D.new()
	left.shape = WorldBoundaryShape2D.new()
	left.shape.normal = Vector2(1, 0)
	left.position = Vector2(bounds.position.x, 0)
	left.debug_color = debug_color
	self.add_child(left)
	
	var bottom = CollisionShape2D.new()
	bottom.shape = WorldBoundaryShape2D.new()
	bottom.shape.normal = Vector2(0, -1)
	bottom.position = Vector2(0, bounds.end.y)
	bottom.debug_color = debug_color
	self.add_child(bottom)
	
	var right = CollisionShape2D.new()
	right.shape = WorldBoundaryShape2D.new()
	right.shape.normal = Vector2(-1, 0)
	right.position = Vector2(bounds.end.x, 0)
	right.debug_color = debug_color
	self.add_child(right)
	
	return []

func is_tile_empty(pos: Vector2i):
	for layer in range(0, parent.get_layers_count()):
		if parent.get_cell_tile_data(layer, pos) != null:
			return collide_filled
	return !collide_filled

func append_outer_borders(visited: Array[Vector2i] = []) -> Array[Vector2i]:
	var bounds = parent.get_used_rect()
	var ts = parent.tile_set.tile_size
	var bound_coods = parent.get_used_rect()
	bound_coods.position *= ts
	bound_coods.size *= ts
	
	var c = null
	for x in range(bounds.position.x, bounds.end.x):
		if !is_tile_empty(Vector2i(x, bounds.position.y)):
			if c == null:
				c = CollisionShape2D.new()
				c.shape = SegmentShape2D.new()
				c.shape.a = Vector2(x * ts.x, bound_coods.position.y)
				c.shape.b = Vector2((x + 1) * ts.x, bound_coods.position.y)
				c.debug_color = debug_color
			else:
				c.shape.b.x += ts.x
		elif c != null:
			self.add_child(c)
			c = null
	if c != null:
		self.add_child(c)
		c = null
	
	for x in range(bounds.position.x, bounds.end.x):
		if !is_tile_empty(Vector2i(x, bounds.end.y - 1)):
			if c == null:
				c = CollisionShape2D.new()
				c.shape = SegmentShape2D.new()
				c.shape.a = Vector2(x * ts.x, bound_coods.end.y)
				c.shape.b = Vector2((x + 1) * ts.x, bound_coods.end.y)
				c.debug_color = debug_color
			else:
				c.shape.b.x += ts.x
		elif c != null:
			self.add_child(c)
			c = null
	if c != null:
		self.add_child(c)
		c = null
	
	for y in range(bounds.position.y, bounds.end.y):
		if !is_tile_empty(Vector2i(bounds.position.x, y)):
			if c == null:
				c = CollisionShape2D.new()
				c.shape = SegmentShape2D.new()
				c.shape.a = Vector2(bound_coods.position.x, y * ts.y)
				c.shape.b = Vector2(bound_coods.position.x, (y + 1) * ts.y)
				c.debug_color = debug_color
			else:
				c.shape.b.y += ts.y
		elif c != null:
			self.add_child(c)
			c = null
	if c != null:
		self.add_child(c)
		c = null
	
	for y in range(bounds.position.y, bounds.end.y):
		if !is_tile_empty(Vector2i(bounds.end.x - 1, y)):
			if c == null:
				c = CollisionShape2D.new()
				c.shape = SegmentShape2D.new()
				c.shape.a = Vector2(bound_coods.end.x, y * ts.y)
				c.shape.b = Vector2(bound_coods.end.x, (y + 1) * ts.y)
				c.debug_color = debug_color
			else:
				c.shape.b.y += ts.y
		elif c != null:
			self.add_child(c)
			c = null
	if c != null:
		self.add_child(c)
		c = null
	
	return []

# 2D greedy meshing
func append_edge_bounds(visited: Array[Vector2i] = []):
	var bounds = parent.get_used_rect()
	var ts = parent.tile_set.tile_size
	
	var y = bounds.position.y
	var x = bounds.position.x
	while y < bounds.end.y:
		while x < bounds.end.x:
			var pos = Vector2i(x, y)
			if is_tile_empty(pos):
				if visited.has(pos):
					x += 1
					continue
				visited.append(pos)
				
				var top = CollisionShape2D.new()
				top.shape = RectangleShape2D.new()
				top.shape.size = ts
				top.position = Vector2(x * ts.x, y * ts.y)
				top.debug_color = debug_color
				
				# See how much we can extend collision box horizontally
				var xi = x + 1
				while xi < bounds.end.x:
					pos = Vector2i(xi, y)
					if is_tile_empty(pos) and !visited.has(pos):
						top.shape.size.x += ts.x
						visited.append(pos)
					else:
						break
					xi += 1
				
				# See how much we can extend collision box vertically
				var yi = y + 1
				while yi < bounds.end.y:
					var matches = true
					# Check row below is same size
					for xj in range(x, xi):
						pos = Vector2i(xj, yi)
						if !is_tile_empty(pos) and !visited.has(pos):
							matches = false
							break
					if matches:
						top.shape.size.y += ts.y
						# Mark all joined from below visited
						for xj in range(x, xi):
							visited.append(Vector2i(xj, yi))
						yi += 1
					else:
						break
				
				# Move for half size because rects are centered around position
				top.position += Vector2((xi - x) * ts.x / 2, (yi - y) * ts.y / 2)
				# Skip all visited in same row
				x = xi
				
				self.add_child(top)
			x += 1
		x = bounds.position.x
		y += 1

func rebuild_mesh():
	for n in self.get_children():
		self.remove_child(n)
		n.queue_free() 
	var visited: Array[Vector2i] = []
	if !collide_filled:
		if fill_outer_bounds:
			visited = append_outer_fills(visited)
		else:
			visited = append_outer_borders(visited)
	append_edge_bounds(visited)

func _ready():
	parent = get_parent()
	if Engine.is_editor_hint():
		parent.changed.connect(rebuild_mesh)
		parent.property_list_changed.connect(rebuild_mesh)
		self.visibility_changed.connect(rebuild_mesh)
		self.script_changed.connect(rebuild_mesh)
		self.property_list_changed.connect(rebuild_mesh)
	rebuild_mesh()
