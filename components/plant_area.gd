@tool
extends Area2D

@onready
var surface: CollisionShape2D = $Surface
@onready
var display: TileMap = $Display

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
	display.position = surface.position

func _ready():
	align_area()
	Globals.player.interact.connect(_on_interact)

func position_cell(pos) -> Vector2i:
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
	#Globals.player.inventory.active

func tile_action(location):
	pass

func get_selection_kind(global_pos: Vector2):
	return TileAction.Kind.ACTIVE

func round_to_tile_rect(rect: Rect2):
	pass

