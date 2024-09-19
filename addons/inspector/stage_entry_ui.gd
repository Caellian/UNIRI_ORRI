@tool
extends VBoxContainer
class_name StageEntryUI

@onready
var stage_name: Label = %StageName

@onready
var up_button: Button = %StageUp
@onready
var down_button: Button = %StageDown
@onready
var remove_button: Button = %RemoveStage

@onready
var add_drop_button: Button = %AddDropButton

@onready
var drop_list: VBoxContainer = %DropList

var tracked

signal stage_remove(node: StageEntryUI)
signal stage_changed(name: String, value)

var DropOptions = preload("res://addons/inspector/drop_options_ui.tscn")

func _remove_requested():
	stage_remove.emit(self)

func _drops_changed(data):
	pass

func _add_drop():
	var drop_ui: DropOptionsUI = DropOptions.instantiate()
	#drop_ui.values_changed.connect(_drops_changed)
	drop_list.add_child(drop_ui)

func attach_item(item):
	self.tracked = item
	stage_name.text = item.name

func _ready():
	if tracked != null:
		stage_name.text = tracked.name
	up_button.icon = get_theme_icon("ArrowUp", "EditorIcons")
	down_button.icon = get_theme_icon("ArrowDown", "EditorIcons")
	remove_button.icon = get_theme_icon("Remove", "EditorIcons")
	remove_button.pressed.connect(_remove_requested)
	add_drop_button.icon = get_theme_icon("Add", "EditorIcons")
	add_drop_button.pressed.connect(_add_drop)
