@tool
extends VBoxContainer
class_name DropCurveEditUI

@onready
var max_spinner: SpinBox = %MaxValue

var current: Curve

signal curve_updated(curve: Curve)

func _update_cap(new_cap: float):
	current.max_value = new_cap

func _ready():
	if current == null:
		current = Curve.new()
	max_spinner.value_changed.connect(_update_cap)
	max_spinner.value = current.max_value

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_curve(curve: Curve):
	current = curve
	if max_spinner != null:
		max_spinner.value = curve.max_value
