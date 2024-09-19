@tool
extends Node

var items = {}
var items_loaded = false

func _load_items():
	items_loaded = true
	var items_iter = Utils.ResourceFileIterator.new("res://components/items")
	for item in items_iter:
		var id = item.trim_suffix(".tres")
		var resource = ResourceLoader.load("res://components/items/" + item, type_string(typeof(ItemResource)), ResourceLoader.CACHE_MODE_REUSE)
		if resource != null:
			items[id] = resource
		else:
			push_error("Unable to load '" + id + "' item resource!")

func _init():
	_load_items()

func get_item(id: String):
	return items.get(id, null)
