extends CanvasLayer

@onready
var time_label: Label = %Time

func _update_time(curr: GameTime.TimeInfo):
	time_label.text = "%d-%d %02d:%02d" % [curr.year, curr.day, curr.hour, curr.minute]

func _ready():
	Globals.time.time_change.connect(_update_time)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
