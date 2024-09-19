@tool
extends Area2D

@onready
var surface: CollisionShape2D = $Surface

@onready
var soil: TileMapLayer = %Soil
@onready
var soil_effect: TileMapLayer = %SoilEffect
@onready
var plants: TileMapLayer = %Plants

var demo_plant = preload("res://components/plants/demo_plant.tscn")

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
	var soil_cell = soil.get_cell_tile_data(tile)
	if soil_cell == null:
		var cells = [
			tile + Vector2i(-2, -1), tile + Vector2i(-1, -1), tile + Vector2i(0, -1),
			tile + Vector2i(-2, 0), tile + Vector2i(-1, 0), tile + Vector2i(0, 0),
			tile + Vector2i(-2, 1), tile + Vector2i(-1, -1), tile + Vector2i(0, 1),
		]
		soil.set_cells_terrain_connect(cells, 0, 2)
		Globals.player.player_sound.play_sound(PlayerSound.Sound.DIG)
		return
	var found_any = false
	for child in get_children():
		if child is DemoPlant:
			var pos: Vector2 = selection.global_position
			if pos.distance_to(child.global_position) < Utils.TILE_SIZE:
				print_debug("Grown child")
				child.grow()
				found_any = true
				break
	if !found_any:
		var new_plant: DemoPlant = demo_plant.instantiate()
		new_plant.grown.connect(func():
			remove_child(new_plant)
		)
		add_child(new_plant)
		new_plant.global_position = selection.global_position
		print_debug("Spawned child")
	#Globals.player.inventory.active

func tile_action(location):
	pass

func get_selection_kind(global_pos: Vector2):
	return TileAction.Kind.ACTIVE

func round_to_tile_rect(rect: Rect2):
	pass
