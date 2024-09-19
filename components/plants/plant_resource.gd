@tool
extends Resource
class_name PlantResource

var name: String = "Plant"

var seed: ItemResource
var seed_min: int = 0
var seed_max: int = 0
var product: ItemResource
var product_min: int = 0
var product_max: int = 0

var textures: TileSet
var plant_width: int = 1
var plant_height: int = 1

enum Kind {
	ROOT,
	TUBER,
	BULB,
	RHIZOME,
	CORM,
	STEM, # or shoot
	LEAF,
	FLOWER,
	FRUIT,
	LEGUME,
	NUT,
	GRAIN,
	HERB,
	SPICE
}

var kind: Kind = Kind.ROOT
var growth_stages: Array[GrowthStage] = []

class GrowthStage:
	extends Resource
	var name: String
	var drops: Array[DropGenerator] = []
	
	func _init(name: String):
		self.name = name

func _get_property_list():
	var ret: Array[Dictionary] = []
	ret.append({
		"name": "Name",
		"type": TYPE_STRING
	})
	ret.append({
		"name": "Plant Kind",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "root,tuber,bulb,rhizome,corm,stem,leaf,flower,fruit,legume,nut,grain,herb,spice",
	})
	ret.append({
		"name": "Appearance",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	ret.append({
		"name": "Textures",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
	})
	ret.append({
		"name": "Tile Size/Width",
		"type": TYPE_INT,
	})
	ret.append({
		"name": "Tile Size/Height",
		"type": TYPE_INT,
	})
	ret.append({
		"name": "Drops",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	ret.append({
		"name": "Seed",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
	})
	if self.seed != null:
		ret.append({
			"name": "Seed Amount/Min",
			"type": TYPE_INT,
		})
		ret.append({
			"name": "Seed Amount/Max",
			"type": TYPE_INT,
		})
	ret.append({
		"name": "Product",
		"type": TYPE_OBJECT,
		"hint": PROPERTY_HINT_RESOURCE_TYPE,
	})
	if self.product != null:
		ret.append({
			"name": "Product Amount/Min",
			"type": TYPE_INT,
		})
		ret.append({
			"name": "Product Amount/Max",
			"type": TYPE_INT,
		})
	ret.append({
		"name": "Growth",
		"type": TYPE_NIL,
		"usage": PROPERTY_USAGE_CATEGORY
	})
	ret.append({
		"name": "Growth Stages",
		"type": TYPE_ARRAY,
		"hint_string": "growth_stages"
	})
	return ret

func _set(prop_name: StringName, val) -> bool:
	match prop_name:
		"Name":
			self.name = val
		"Plant Kind":
			self.kind = val
			notify_property_list_changed()
		"Textures":
			if val is TileSet:
				self.textures = val
		"Tile Size/Width":
			self.plant_width = clamp(val, 1, 6)
		"Tile Size/Height":
			self.plant_height = clamp(val, 1, 6)
		"Seed":
			self.seed = val
			notify_property_list_changed()
		"Seed Amount/Min":
			self.seed_min = clamp(val, 0, self.seed_max)
		"Seed Amount/Max":
			self.seed_max = clamp(val, self.seed_min, 32)
		"Product":
			self.product = val
			notify_property_list_changed()
		"Product Amount/Min":
			self.product_min = clamp(val, 0, self.product_max)
		"Product Amount/Max":
			self.product_max = clamp(val, self.product_min, 32)
		"Growth Stages":
			self.growth_stages = val
		_:
			return false
	return true

func _get(prop_name: StringName):
	match prop_name:
		"Name":
			return self.name
		"Plant Kind":
			return self.kind
		"Textures":
			return self.textures
		"Tile Size/Width":
			return self.plant_width
		"Tile Size/Height":
			return self.plant_height
		"Seed":
			return self.seed
		"Seed Amount/Min":
			return self.seed_min
		"Seed Amount/Max":
			return self.seed_max
		"Product":
			return self.product
		"Product Amount/Min":
			return self.product_min
		"Product Amount/Max":
			return self.product_max
		"Growth Stages":
			return self.growth_stages
	return null
