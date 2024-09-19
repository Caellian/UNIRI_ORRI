extends PanelContainer
class_name SaveSlot

var slot_index: int = 0
var save: GameSave

@onready
var character_image: TextureRect = %CharacterImage

@onready
var delete_button: TextureButton = %DeleteButton
@onready
var last_play: Label = %LastPlayed
@onready
var play_button: Button = %PlayButton

func _on_delete_pressed():
	save.clear()
	_update_display()

func _on_select():
	save.load_game()

func _update_display():
	delete_button.visible = save.last_play > 0
	
	var texture: AtlasTexture = character_image.texture
	if save.last_play == 0:
		play_button.text = "New Game"
		texture.region.position.x = 0
		last_play.text = "EMPTY"
	else:
		texture.region.position.x = 16
		last_play.text = Time.get_date_string_from_unix_time(save.last_play) + " " + Time.get_time_string_from_unix_time(save.last_play)

func _ready():
	slot_index = get_index() + 1
	save = GameSave.saved_games[slot_index]
	_update_display()

func _on_play_button_pressed():
	pass # Replace with function body.
