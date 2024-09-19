extends Node
class_name SceneManager

signal map_change(new_map: Node2D)
signal screen_open(new_screen: Control)

@onready
var game: Node = get_node("/root/Game")
@onready
var world: Node2D = get_node("/root/Game/World")
@onready
var player: Player = game.get_node("%Player")
@onready
var bg_music: AudioStreamPlayer = game.get_node("%BackgroundMusic")
@onready
var time: GameTime = %Time
@onready
var hud: CanvasLayer = %HUD
@onready
var ui: Control = %UI

var main_menu = preload("res://scenes/ui/main_menu.tscn").instantiate()

var current_map = null
var current_map_name = "farm"
var screen_stack = []

var map_cache = {}

func _make_world_spin(value: bool):
	world.visible = value
	hud.visible = value
	if value:
		world.process_mode = Node.PROCESS_MODE_PAUSABLE
		%BackgroundMusic.play()
	else:
		world.process_mode = Node.PROCESS_MODE_DISABLED
		%BackgroundMusic.stop()

func _clear_screen():
	_make_world_spin(false)
	if current_map != null:
		world.remove_child(current_map)
	current_map = null
	current_map_name = "farm"

func is_in_world():
	return world.visible

func enter_map(map: String, location = "default_location"):
	var scene_node = map_cache.get(map)
	# Load if not already loaded by portal.
	if scene_node == null:
		scene_node = ResourceLoader.load("res://scenes/world/" + map + ".tscn", "", ResourceLoader.CACHE_MODE_REUSE)
		if scene_node == null:
			print_debug("Can't enter map: " + map + "; location: " + location)
			return
		map_cache[map] = scene_node
	var scene_instance = scene_node.instantiate()
	_clear_screen()
	while !screen_stack.is_empty():
		ui.remove_child(screen_stack.pop_back())
	world.add_child(scene_instance)
	world.move_child(scene_instance, 0)
	player.teleport_to_location(location)
	current_map = scene_instance
	current_map_name = map
	_make_world_spin(true)
	map_change.emit(scene_instance)
	Globals.game_save.save_game()

func open_ui(screen):
	var screen_instance = screen;
	if typeof(screen) == TYPE_STRING:
		var scene_node = map_cache.get(screen)
		# Load if not already loaded by portal.
		if scene_node == null:
			scene_node = ResourceLoader.load("res://scenes/ui/" + screen + ".tscn", "", ResourceLoader.CACHE_MODE_REUSE)
			if scene_node == null:
				print_debug("Can't open screen: " + screen)
				return
			map_cache[name] = scene_node
		screen_instance = scene_node.instantiate()
	_clear_screen()
	screen_stack.push_back(screen_instance)
	ui.add_child(screen_instance)
	screen_open.emit(screen_instance)

func close_screen():
	var last_screen = screen_stack.pop_back()
	if last_screen != null:
		ui.remove_child(last_screen)
	if !screen_stack.is_empty():
		ui.add_child(screen_stack.back())

func _ready():
	open_ui(main_menu)
