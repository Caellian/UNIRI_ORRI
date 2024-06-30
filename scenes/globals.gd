extends Node
class_name GameGlobals

@onready
var game: Node = get_node("/root/Game")
@onready
var scene: Node2D = get_node("/root/Game/Map")
@onready
var player: CharacterBody2D = game.get_node("%Player")

var map_cache = {}

func enter_map(map: String, location: String):
	var prev_scene = scene
	var scene_node = map_cache.get(map)
	# Should've been loaded by portal, but load again if not...
	if scene_node == null:
		scene_node = ResourceLoader.load("res://scenes/world/" + map + ".tscn", "", ResourceLoader.CACHE_MODE_REUSE)
		if scene_node == null:
			print_debug("Can't enter map: " + map + "; location: " + location)
			return
		map_cache[map] = scene_node
	var scene_instance = scene_node.instantiate()
	game.remove_child(scene)
	game.add_child(scene_instance)
	game.move_child(scene_instance, 0)
	scene = scene_instance
	
	player.teleport_to_location(location)
