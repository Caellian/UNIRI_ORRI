extends EditorInspectorPlugin
class_name InspectorPlugin

class DropEditor:
	extends EditorProperty
	
	var weighted: bool = false

const GrowthStagesControl = preload("res://addons/inspector/growth_stages_ui.tscn")
class GrowthStagesProperty:
	extends EditorProperty
	
	var ui: GrowthStagesUI
	var current
	
	func _init():
		ui = GrowthStagesControl.instantiate()
		add_child(ui)
		set_bottom_editor(ui)
		add_focusable(ui)
		ui.stages_changed.connect(_entries_modified)
		
	func _update_property():
		var prev = current
		current = get_edited_object()
		if current != prev:
			var value = current[get_edited_property()]
			ui.set_stages(value)
		
	func _entries_modified(entries):
		current[get_edited_property()] = entries
		var items = current[get_edited_property()]

func _can_handle(object):
	return true # object is Array[DropGenerator] or object is DropGenerator or object is ItemResource

func _parse_property(object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool):
	if type == TYPE_ARRAY and hint_string == "growth_stages":
		add_property_editor(name, GrowthStagesProperty.new())
		return true
	return false
