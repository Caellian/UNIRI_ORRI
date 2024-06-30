extends Area2D

var parent: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent()
	var player_selection = get_node("/root/Game/%Player")
	player_selection.interact.connect(_on_interact)

func _on_interact(selection: PlayerSelection):
	print("interact with ", selection.global_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tile_action(location):
	pass

func get_selection_kind(global_pos: Vector2):
	return PlayerSelection.Kind.ACTIVE
