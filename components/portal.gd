extends Node2D
class_name Portal

@export
var portal_name: String = "portal"
@export
var target_location: String = ""
@export
var target_map: String = ""

func enter_direction():
	var r = self.global_rotation
	if r > PI * -0.25 and r < PI * 0.25:
		return SIDE_TOP
	elif r > PI * -0.75 and r < PI * -0.25:
		return SIDE_LEFT
	elif r > PI * 0.25 and r < PI * 0.75:
		return SIDE_RIGHT
	else:
		return SIDE_BOTTOM

func _load_target(map):
	var target_scene = Globals.scene_manager.map_cache.get(map)
	if target_scene == null:
		target_scene = ResourceLoader.load("res://scenes/world/" + map + ".tscn", "", ResourceLoader.CACHE_MODE_REUSE)
		if target_scene == null:
			print_debug("Unable to load scene: " + map)
			return
		Globals.scene_manager.map_cache[map] = target_scene

func _ready():
	# Preload target scene
	_load_target(target_map)

var inside: Player = null
func _on_enter(body):
	if body is Player:
		inside = body
func _on_leave(body):
	if body is Player:
		inside = null

func _physics_process(delta):
	if inside == null:
		return
	var player_direction = inside.last_direction
	if player_direction == enter_direction():
		Globals.scene_manager.enter_map(target_map, target_location)

func get_location_name():
	return portal_name
