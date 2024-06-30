extends Node
class_name GameGlobals

signal map_change(new_map: Node2D)

@onready
var game: Node = get_node("/root/Game")
@onready
var world: Node = get_node("/root/Game/World")
@onready
var player: CharacterBody2D = game.get_node("%Player")

var map_cache = {}

func clear_children(node: Node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free() 

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
	clear_children(world)
	map_cache.clear()
	world.add_child(scene_instance)
	player.teleport_to_location(location)
	map_change.emit(scene_instance)
