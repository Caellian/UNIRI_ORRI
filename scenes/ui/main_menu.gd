extends CanvasLayer

@onready
var scene_manager: SceneManager = get_node("/root/Game/SceneManager")

func _on_play_button_pressed():
	scene_manager.open_ui("pick_save_slot")

func _on_settings_button_pressed():
	scene_manager.open_ui("settings_menu")
	
func _on_quit_button_pressed():
	get_tree().quit()
