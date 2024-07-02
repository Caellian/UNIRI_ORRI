@tool
extends Area2D

@onready
var surface: CollisionShape2D = $Surface

@export
var size: Vector2i = Vector2i(1, 1):
	set(value):
		size = value
		align_area()

func align_area():
	if surface == null:
		return
	surface.shape.size = size * Utils.TILE_SIZE
	surface.position = Utils.round_to_tile(self.global_position) - self.global_position
	surface.position += Vector2(size * Utils.HALF_TILE)

func _ready():
	align_area()
	var player_selection = get_node("/root/Game/%Player")
	player_selection.interact.connect(_on_interact)

func position_cell(pos):
	var val = pos
	if val is TileAction:
		val = pos.global_position
	else:
		val = Vector2(pos)
	return Vector2i(Utils.to_grid(val - surface.global_position) + (Vector2(size) / 2.0).floor())

var last_pos = self.position
func _physics_process(delta):
	if Engine.is_editor_hint():
		if self.position != last_pos:
			align_area()
			last_pos = self.position

func _on_interact(selection: TileAction):
	var tile = position_cell(selection.global_position)
	print(tile)

func tile_action(location):
	pass

func get_selection_kind(global_pos: Vector2):
	return TileAction.Kind.ACTIVE

func round_to_tile_rect(rect: Rect2):
	pass

