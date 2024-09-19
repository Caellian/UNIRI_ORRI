extends PanelContainer
class_name ItemSlot

@export
var item: ItemResource

var row: int
var column: int

var style_box: StyleBoxFlat

func _selection_change(selected: bool):
	if selected:
		style_box.border_color = Color("dac8bf")
		custom_minimum_size = Vector2(48, 48)
	else:
		style_box.border_color = Color("f3c473")
		custom_minimum_size = Vector2(32, 32)

# Called when the node enters the scene tree for the first time.
func _ready():
	style_box = StyleBoxFlat.new()
	style_box.bg_color = Color("ba9250")
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color("f3c473")
	self.add_theme_stylebox_override("panel", style_box)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
