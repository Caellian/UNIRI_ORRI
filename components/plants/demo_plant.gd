extends Node2D
class_name DemoPlant

signal grown()

@onready
var sprite: Sprite2D = %Sprite2D
var image: AtlasTexture

var passive: float = 0
var stage: int = 0

func grow():
	if stage >= 3:
		grown.emit()
		Globals.player.inventory.earn(20)
		Globals.player.player_sound.play_sound(PlayerSound.Sound.COLLECT)
	else:
		stage += 1
		if image != null:
			image.region.position.x = 16 + stage * 16

func interact():
	grow()

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(sprite)
	image = sprite.texture
	var sprite_clone = Sprite2D.new()
	var image_clone = AtlasTexture.new()
	image_clone.atlas = image.atlas
	image_clone.region = Rect2i(image.region)
	sprite_clone.texture = image_clone
	add_child(sprite_clone)
	sprite = sprite_clone
	image = image_clone

func _process(delta):
	passive += delta
	if passive > 10:
		grow()
		passive = 0
