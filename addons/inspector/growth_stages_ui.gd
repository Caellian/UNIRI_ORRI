@tool
extends VBoxContainer
class_name GrowthStagesUI

@onready
var new_stage_name: LineEdit = %NewStageName
@onready
var add_button: Button = %AddStage

@onready
var stage_list: VBoxContainer = %StageList

var stages = []
signal stages_changed(stages)

var EntryUI = preload("res://addons/inspector/stage_entry_ui.tscn")

func _ready():
	add_button.icon = get_theme_icon("Add", "EditorIcons")
	add_button.pressed.connect(_add_list_item)

func _add_list_item():
	var name = new_stage_name.text
	if name == "":
		return
	for s in stages:
		if s.name == name:
			return
	var last = PlantResource.GrowthStage.new(name)
	_add_child_ui(last)
	stages.append(last)
	stages_changed.emit(stages)

func _clear_list(notify: bool = true):
	for child in stage_list.get_children():
		_remove_child(child)
	stages.clear()
	if notify:
		stages_changed.emit(stages)

func _add_child_ui(item):
	var entry = EntryUI.instantiate()
	entry.attach_item(item)
	entry.stage_remove.connect(_remove_child)
	stage_list.add_child(entry)

func _remove_child(child: StageEntryUI, notify: bool = true):
	stage_list.remove_child(child)
	var pos = -1
	for i in range(0, stages.size()):
		if stages[i].name == child.tracked.name:
			pos = i
			break
	if pos == -1:
		return
	stages.remove_at(pos)
	child.queue_free()
	if notify:
		stages_changed.emit(stages)

func set_stages(stages):
	_clear_list(false)
	self.stages = stages
	if stages != null:
		for it in stages:
			_add_child_ui(it)
