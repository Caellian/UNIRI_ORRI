extends Node
class_name GameGlobals

@onready
var game: Node = get_node("/root/Game")
@onready
var scene: Node2D = get_node("/root/Game/Map")
@onready
var player: CharacterBody2D = %Player

var map_cache = {}

func enter_map(map: String, location: String):
	print(game.get_children())
	var prev_scene = scene
	var scene_node = map_cache.get(map)
	if scene_node == null:
		scene_node = load("res://scenes/world/" + map + ".tscn")
		map_cache[map] = scene_node
	var scene_instance = scene_node.instantiate()
	game.remove_child(scene)
	game.add_child(scene_instance)
	game.move_child(scene_instance, 0)
	scene = scene_instance
	# TODO: Clear non-adjacent from cache
	# TODO: Load adjacent to cache
	# TODO: Position player
