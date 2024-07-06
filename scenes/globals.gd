extends Node
class_name GameGlobals

signal map_change(new_map: Node2D)

@onready
var game: Node = get_node("/root/Game")
@onready
var world: Node = get_node("/root/Game/World")
@onready
var player: Player = game.get_node("%Player")
@onready
var time: GameTime = game.get_node("%Time")

var map_cache = {}

func enter_map(map: String, location: String):
	var scene_node = map_cache.get(map)
	# Load if not already loaded by portal.
	if scene_node == null:
		scene_node = ResourceLoader.load("res://scenes/world/" + map + ".tscn", "", ResourceLoader.CACHE_MODE_REUSE)
		if scene_node == null:
			print_debug("Can't enter map: " + map + "; location: " + location)
			return
		map_cache[map] = scene_node
	var scene_instance = scene_node.instantiate()
	Utils.clear_children(world)
	map_cache.clear()
	world.add_child(scene_instance)
	player.teleport_to_location(location)
	map_change.emit(scene_instance)
