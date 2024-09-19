extends Object
class_name Inventory

signal gold_change(state: float)

var items: Array[Item] = []
var gold: float = 0.0

func earn(amount: float):
	gold += amount
	gold_change.emit(gold)

func spend(amount: float) -> bool:
	if amount >= gold:
		gold -= amount
		gold_change.emit(gold)
		return true
	return false

func save_items() -> Dictionary:
	return {
		"gold": gold
	}

func load_items(dict: Dictionary):
	if dict.has("gold"):
		gold = dict.get("gold")
