extends Object
class_name Utils

const TILE_SIZE = 16
const HALF_TILE = TILE_SIZE / 2
const TILE_VEC = Vector2(TILE_SIZE, TILE_SIZE)
const TILE_VECI = Vector2i(TILE_SIZE, TILE_SIZE)

static func round_to_tile_int(value: int, low: bool = true) -> int:
	if low:
		if value < 0:
			return value - (TILE_SIZE - posmod(value, TILE_SIZE))
		else:
			return value - posmod(value, TILE_SIZE)
	else:
		if value < 0:
			return value + posmod(value, TILE_SIZE)
		else:
			return value + (TILE_SIZE - posmod(value, TILE_SIZE))

static func rount_to_tile_float(value: float, low: bool = true) -> float:
	if low:
		if value < 0:
			return value - (TILE_SIZE - fposmod(value, TILE_SIZE))
		else:
			return value - fposmod(value, TILE_SIZE)
	else:
		if value < 0:
			return value + fposmod(value, TILE_SIZE)
		else:
			return value + (TILE_SIZE - fposmod(value, TILE_SIZE))

static func rount_to_tile_vec(vec: Vector2, low: bool = true) -> Vector2:
	if low:
		return Vector2(rount_to_tile_float(vec.x, true), rount_to_tile_float(vec.y, true))
	else:
		return Vector2(rount_to_tile_float(vec.x, false), rount_to_tile_float(vec.y, false))

static func rount_to_tile_veci(vec: Vector2i, low: bool = true) -> Vector2i:
	if low:
		return Vector2i(round_to_tile_int(vec.x, true), round_to_tile_int(vec.y, true))
	else:
		return Vector2i(round_to_tile_int(vec.x, false), round_to_tile_int(vec.y, false))

static func round_to_tile_rect(rect: Rect2, low: bool = true) -> Rect2:
	var result = rect
	if low:
		result.position = rount_to_tile_vec(result.position, false)
		result.end = rount_to_tile_vec(result.end, true)
	else:
		result.position = rount_to_tile_vec(result.position, true)
		result.end = rount_to_tile_vec(result.end, false)
	return result

static func round_to_tile_recti(rect: Rect2i, low: bool = true) -> Rect2i:
	var result = rect
	if low:
		result.position = rount_to_tile_veci(result.position, false)
		result.end = rount_to_tile_veci(result.end, true)
	else:
		result.position = rount_to_tile_veci(result.position, true)
		result.end = rount_to_tile_veci(result.end, false)
	return result

static func round_to_tile(value, low: bool = true):
	if value is int:
		return round_to_tile_int(value, low)
	if value is float:
		return rount_to_tile_float(value, low)
	if value is Vector2:
		return rount_to_tile_vec(value, low)
	if value is Vector2i:
		return rount_to_tile_veci(value, low)
	if value is Rect2:
		return round_to_tile_rect(value, low)
	if value is Rect2i:
		return round_to_tile_recti(value, low)
	push_error("can't align " +  type_string(value) + " type to tiles")
	return null

static func to_grid(pos):
	var rounded = round_to_tile(pos)
	if pos is Vector2:
		return rounded / TILE_VEC
	if pos is Vector2i:
		return rounded / TILE_VEC
	if pos is Rect2:
		return Rect2(rounded.position / TILE_VEC, rounded.size / TILE_VEC)
	if pos is Rect2i:
		return Rect2i(rounded.position / TILE_VECI, rounded.size / TILE_VECI)
	push_error("can't convert " +  type_string(pos) + " to grid coordinates")
	return null

static func clear_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free() 

class ResourceFileIterator:
	var path: String
	var dir: DirAccess
	var file_name: String = ""

	func _init(path: String):
		self.path = path
		self.dir = DirAccess.open(path)

	func should_continue():
		return self.file_name != ""

	func _iter_init(arg):
		if !dir:
			push_error("unable to open resource path: " + self.path)
			return false
		self.dir.list_dir_begin()
		self.file_name = dir.get_next()
		while self.file_name != "" and !self.file_name.ends_with(".tres"):
			self.file_name = self.dir.get_next()
		return self.file_name != ""

	func _iter_next(arg):
		self.file_name = self.dir.get_next()
		while self.file_name != "" and !self.file_name.ends_with(".tres"):
			self.file_name = self.dir.get_next()
		return self.file_name != ""

	func _iter_get(arg):
		return self.file_name
