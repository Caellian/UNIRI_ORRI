extends HBoxContainer
class_name Hotbar

signal slot_change(active: ItemSlot)

@onready
var player: Player = get_node("/root/Game/%Player")

var slots: Dictionary
var selected_slot: int
var prev_slot_i: int = 0
var slot_row: int = 0

func get_slot(index: int) -> ItemSlot:
	if index < 0 or index >= slots.size():
		return null
	return slots[index]

func current_slot() -> ItemSlot:
	var current: ItemSlot = slots[selected_slot]
	current.row = slot_row
	current.column = selected_slot
	return current

# Called when the node enters the scene tree for the first time.
func _ready():
	for child_i in range(0, get_child_count()):
		var slot = get_child(child_i)
		slots[child_i] = slot
		var callback = func(new_slot):
			if new_slot == slot:
				slot._selection_change(new_slot == slot)
			elif prev_slot_i == child_i:
				slot._selection_change(false)
		slot_change.connect(callback)
	current_slot()._selection_change(true)

func _physics_process(delta):
	var selection_offset = int(Input.is_action_just_released("prev_item")) - int(Input.is_action_just_released("next_item"))
	var new_selection = selected_slot + selection_offset
	var slot_count = slots.size()
	if new_selection < 0:
		new_selection += slot_count
	elif new_selection >= slot_count:
		new_selection -= slot_count
	if new_selection != selected_slot:
		prev_slot_i = selected_slot
		selected_slot = new_selection
		slot_change.emit(current_slot())
