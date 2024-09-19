@tool
extends EditorPlugin

var InspectorPluginT = preload("res://addons/inspector/inspector.gd")
var inspector_plugin: InspectorPlugin

func _enter_tree():
	inspector_plugin = InspectorPluginT.new()
	add_inspector_plugin(inspector_plugin)


func _exit_tree():
	remove_inspector_plugin(inspector_plugin)
