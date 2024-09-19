@tool
extends MarginContainer
class_name DropOptionsUI

@onready
var item_selection_label: Label = %ItemSelection
@onready
var item_id_input: LineEdit = %ItemResourceID
@onready
var item_id_valid: TextureRect = %ItemIDValid

@onready
var amount_selection_label: Label = %AmountSelection
@onready
var amount_curve_picker: EditorResourcePicker

@onready
var OkIcon = get_theme_icon("ImportCheck", "EditorIcons")
@onready
var InvalidIcon = get_theme_icon("ImportFail", "EditorIcons")

var data

signal values_changed(data)

func set_value(data):
	self.data = data

func _item_change(value):
	data.item = value
	values_changed.emit(data)

func _curve_change(value):
	print(type_string(typeof(value)))
	#data.drop_count = value
	#values_changed.emit(data)

var CurveEdit = preload("res://addons/inspector/drop_curve_edit.tscn")

func _curve_select(a, b):
	var container = get_node("%GridContainer")
	var edit_curve: DropCurveEditUI = CurveEdit.instantiate()
	edit_curve.set_curve(a)
	container.add_child(edit_curve)
	#print(type_string(typeof(a)), "=", str(a), ", ", type_string(typeof(b)), "=", str(b))

func _validate_id(text):
	#var text = item_id_input.text
	if text == "":
		item_id_valid.visible = false
		notify_property_list_changed()
	item_id_valid.visible = true
	if ItemManager.get_item(text) != null:
		item_id_valid.texture = OkIcon
	else:
		item_id_valid.texture = InvalidIcon
	notify_property_list_changed()

func _ready():
	var grid = get_node("%PropertyGrid")
	item_id_input.text_changed.connect(_validate_id)
	amount_curve_picker = EditorResourcePicker.new()
	amount_curve_picker.base_type = "Curve"
	amount_curve_picker.size_flags_horizontal = Control.SIZE_FILL
	amount_curve_picker.resource_selected.connect(_curve_select)
	amount_curve_picker.resource_changed.connect(_curve_change)
	grid.add_child(amount_curve_picker)
	grid.move_child(amount_curve_picker, grid.get_children().find(amount_selection_label) + 1)

func _draw():
	var parent = get_parent_control()
	if parent == null:
		return
	var i = parent.get_children().find(self)
	if i % 2 == 0:
		draw_rect(Rect2(Vector2(0,0),self.get_rect().size), Color(0.1,0.1,0.1,0.3))
	else:
		draw_rect(Rect2(Vector2(0,0),self.get_rect().size), Color(0.1,0.1,0.1,0.2))
