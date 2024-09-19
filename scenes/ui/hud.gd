extends CanvasLayer

@onready
var time_label: Label = %Time
@onready
var gold_label: Label = %Gold
@onready
var hotbar: Hotbar = %Hotbar

func _update_time(curr: GameTime.TimeInfo):
	time_label.text = "%d-%d %02d:%02d" % [curr.year, curr.day, curr.hour, curr.minute]

func _update_gold(curr: float):
	gold_label.text = "%.0f" % curr

func _ready():
	Globals.time.time_change.connect(_update_time)
	_update_time(Globals.time.current)
	Globals.player.inventory.gold_change.connect(_update_gold)
	_update_gold(Globals.player.inventory.gold)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
