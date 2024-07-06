extends Node

var items = {}

func _ready():
	var items_iter = Utils.ResourceFileIterator.new("res://components/items")
	for item in items_iter:
		var id = item.trim_suffix(".tres")
		var resource = ResourceLoader.load("res://components/items/" + item, "ItemResource", ResourceLoader.CACHE_MODE_REUSE)
		if resource != null:
			items[id] = resource
		else:
			push_error("Unable to load '" + id + "' item resource!")

