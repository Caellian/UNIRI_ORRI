extends Node

var instance: GameSettings

const SETTINGS_PATH: String = "user://settings.tres"

func _init():
	if instance == null:
		if ResourceLoader.exists(SETTINGS_PATH):
			instance = ResourceLoader.load("user://settings.tres", type_string(typeof(GameSettings)), ResourceLoader.CACHE_MODE_REUSE)
		else:
			instance = GameSettings.new()
			save()
	print_debug("Settings loaded")
	_apply_settings()

func _apply_settings():
	pass

func save():
	ResourceSaver.save(instance, "user://settings.tres")
	_apply_settings()
