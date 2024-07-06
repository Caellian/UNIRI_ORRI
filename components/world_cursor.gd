extends Sprite2D
class_name WorldCursor

var player: Player

@onready
var animator: AnimationPlayer = %SelectionAnimator

func _ready():
	player = get_parent()

var last_position = null

var cached_priority = {}
func _remote_priority(a: Node2D, b: Node2D):
	var a_priority = cached_priority.get(a, null)
	if a_priority == null:
		if a.has_method("get_select_priority"):
			a_priority = a.get_selection_priority()
			cached_priority[a] = a_priority
		else:
			return false
	var b_priority = cached_priority.get(b, null)
	if b_priority == null:
		if b.has_method("get_select_priority"):
			b_priority = b.get_selection_priority()
			cached_priority[b] = b_priority
		else:
			return true
	return a_priority < b_priority
	
func _priority_sort(many: Array):
	many.sort_custom(_remote_priority)
	cached_priority.clear()
	return many

func query_area_at_pos(pos: Vector2):
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = false
	return get_world_2d().direct_space_state.intersect_point(query)

func _update_selection(global_pos: Vector2):
	var last_selection = player.selection
	var intersecting_areas = query_area_at_pos(global_pos)

	var interact_areas = []
	for result in intersecting_areas:
		if result.collider.is_in_group("interactable"):
			interact_areas.append(result.collider)
	# _priority_sort(interact_areas) # enable if multiple actionable tiles can overlap
	
	player.selection = null
	
	for it in interact_areas:
		if it.has_method("get_selection_kind"):
			player.selection = TileAction.new(it, it.get_selection_kind(global_pos), global_pos)
			break
	
	self.visible = player.selection != null
	if player.selection == null:
		if last_selection != null:
			player.selection_changed.emit(null)
			last_selection.free()
		return
	
	if last_selection != player.selection:
		player.selection.update_cursor(self)
		player.selection_changed.emit(player.selection)
	
	if last_selection != null:
		last_selection.free()

func _update_position():
	var player_position = player.global_position
	var global_tile_offset = player_position.posmod(Utils.TILE_SIZE) - Vector2(Utils.HALF_TILE, Utils.HALF_TILE)
	self.position = player.direction_vec() * Utils.TILE_SIZE - global_tile_offset
	if last_position != self.position:
		_update_selection(player_position + self.position)
	last_position = self.position

func _physics_process(_delta):
	_update_position()
