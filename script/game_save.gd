extends Resource
class_name GameSave

static var saved_games = {}
const SAVE_DIR = "user://saves/"

static func _load_saves():
	for i in range(1, 5):
		saved_games[i] = load_info(i)

static func _static_init():
	_load_saves()

var save_slot: int
var last_play: int = 0

static func load_info(save_slot: int) -> GameSave:
	var result = GameSave.new()
	result.save_slot = save_slot
	
	var file_name = SAVE_DIR + "save_" + str(save_slot) + ".info.json"
	if !FileAccess.file_exists(file_name):
		return result
	var json_file = FileAccess.open(file_name, FileAccess.READ)
	var json_text = json_file.get_as_text()
	var value = JSON.parse_string(json_text)
	
	result.last_play = value.get("save_time")
	return result

func load_game():
	var file_name = SAVE_DIR + "save_" + str(save_slot) + ".json"
	var save = {}
	if FileAccess.file_exists(file_name):
		var json_file = FileAccess.open(file_name, FileAccess.READ)
		var json_text = json_file.get_as_text()
		save = JSON.parse_string(json_text)
	if save.has("game_time"):
		Globals.time.current = GameTime.TimeInfo.from_dict(save.get("game_time"))
	var map = "farm"
	if save.has("map"):
		map = save.get("map")
	var location = "default_location"
	if save.has("location"):
		location = dict_to_vec2(save.get("location"))
	if save.has("rotation"):
		Globals.player.last_direction = int(save.get("rotation"))
	if save.has("inventory"):
		Globals.player.inventory.load_items(save.get("inventory"))
	Globals.game_save = self
	Globals.scene_manager.enter_map(map, location)

func save_info():
	var file_name = SAVE_DIR + "save_" + str(save_slot) + ".info.json"
	var json_text = JSON.stringify({
		"save_time": Time.get_unix_time_from_system()
	})
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	var json_file = FileAccess.open(file_name, FileAccess.WRITE)
	json_file.store_string(json_text)
	json_file.flush()
	json_file.close()

func save_game():
	save_info()
	var file_name = SAVE_DIR + "save_" + str(save_slot) + ".json"
	var result = {}
	result["game_time"] = Globals.time.current.to_dict()
	result["map"] = Globals.scene_manager.current_map_name
	result["location"] = vec2_to_dict(Globals.player.transform.origin)
	result["rotation"] = Globals.player.last_direction
	result["inventory"] = Globals.player.inventory.save_items()
	var json_text = JSON.stringify(result)
	var json_file = FileAccess.open(file_name, FileAccess.WRITE)
	json_file.store_string(json_text)
	json_file.flush()
	json_file.close()

func clear():
	var save_file = SAVE_DIR + "save_" + str(save_slot) + ".json"
	DirAccess.remove_absolute(save_file)
	var save_info_file = SAVE_DIR + "save_" + str(save_slot) + ".info.json"
	DirAccess.remove_absolute(save_info_file)
	last_play = 0

static func dict_to_vec2(dict: Dictionary) -> Vector2:
	return Vector2(dict.get("x", 0), dict.get("y", 0))
	
static func vec2_to_dict(vec: Vector2) -> Dictionary:
	return {
		"x": vec.x,
		"y": vec.y,
	}
