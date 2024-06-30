extends Node2D

@export
var portal_name: String = "portal"
@export
var target_portal: String = ""
@export
var target_location: String = ""

func get_exit_direction() -> Player.Direction:
	return Player.Direction.FORWARD

func _ready():
	# Preload target scene
	var target_scene = Globals.map_cache.get(target_location)
	if target_scene == null:
		Globals.map_cache[target_location] = load("res://scenes/world/" + target_location + ".tscn")

func _on_enter(body):
	if body.name != "Player":
		return
	print(portal_name + " entered")
	Globals.enter_map(target_location, target_portal)
