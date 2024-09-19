extends CanvasModulate
class_name GameTime

@export
var SPRING_DURATION: int = 27
@export
var SUMMER_DURATION: int = 35
@export
var AUTUMN_DURATION: int = 21
@export
var WINTER_DURATION: int = 14

@export
var SUMMER_DAY_HOURS: float = 15.0
@export
var WINTER_DAY_HOURS: float = 10.0
@export
var MID_DAY_HOURS: float = 14.0
@export
var SUN_TRANSITION_HOURS: float = 0.5

@export
var START_HOUR: float = 6.0

@export
var HOURS_PER_DAY: int = 24
const MINUTES_PER_HOUR: int = 60

@export_color_no_alpha
var NIGHT_COLOR: Color = Color.MIDNIGHT_BLUE
@export
var DAY_TRANSITION: GradientTexture1D
@export_color_no_alpha
var DAY_COLOR: Color = Color.WHITE
@export
var MINUTE_DURATION: int = 1000

enum Season {
	SPRING,
	SUMMER,
	AUTUMN,
	WINTER
}

class TimeInfo:
	var minute: int
	var hour: int
	var day: int
	var season: Season
	var year: int

	static func from_dict(value: Dictionary) -> TimeInfo:
		var result = TimeInfo.new()
		result.minute = value["minute"]
		result.hour = value["hour"]
		result.day = value["day"]
		result.season = value["season"]
		result.year = value["year"]
		return result
	
	func to_dict() -> Dictionary:
		return {
			"minute": self.minute,
			"hour": self.hour,
			"day": self.day,
			"season": self.season,
			"year": self.year,
		}

func time_to_ms(time: TimeInfo) -> int:
	return (time.hour * MINUTES_PER_HOUR + time.minute) * MINUTE_DURATION

var counter: float = 0.0
var current_season: Season = Season.SPRING
var current_day_duration: float = WINTER_DAY_HOURS
static var current: TimeInfo = TimeInfo.new()

signal time_change(time: TimeInfo)
signal day_change(time: TimeInfo)
signal season_change(time: TimeInfo)
signal time_skipped(duration: float)

var DAYS_PER_YEAR: int
var DAY_TOTAL: float
var SUN_TRANSITION_DURATION: float
func _ready():
	DAYS_PER_YEAR = SPRING_DURATION + SUMMER_DURATION + AUTUMN_DURATION + WINTER_DURATION
	DAY_TOTAL = float(HOURS_PER_DAY * MINUTES_PER_HOUR * MINUTE_DURATION)
	SUN_TRANSITION_DURATION = SUN_TRANSITION_HOURS * MINUTES_PER_HOUR * MINUTE_DURATION

	current_day_duration = _day_duration(current.day)
	set_time_morning()

func _day_to_season(day: int):
	if day < SPRING_DURATION:
		return Season.SPRING
	elif day < SPRING_DURATION + SUMMER_DURATION:
		return Season.SUMMER
	elif day < SPRING_DURATION + SUMMER_DURATION + AUTUMN_DURATION:
		return Season.AUTUMN
	else:
		return Season.WINTER

func _day_duration(day: int):
	return lerpf(WINTER_DAY_HOURS, SUMMER_DAY_HOURS, float((day + WINTER_DURATION / 2) % DAYS_PER_YEAR) / float(DAYS_PER_YEAR))

func _update_time():
	var prev_day = current.day
	
	current.minute += int(floorf(counter / MINUTE_DURATION))
	counter = fmod(counter, MINUTE_DURATION)
	current.hour += current.minute / MINUTES_PER_HOUR
	current.minute = current.minute % MINUTES_PER_HOUR
	current.day += current.hour / HOURS_PER_DAY
	current.hour = current.hour % HOURS_PER_DAY
	current.year += current.day / DAYS_PER_YEAR
	current.day = current.day % DAYS_PER_YEAR
	time_change.emit(current)
	
	if prev_day != current.day:
		day_change.emit(current)
		current_day_duration = _day_duration(current.day)
		var prev_season = current.season
		current.season = _day_to_season(current.day)
		if prev_season != current.season:
			season_change.emit(current)

func _day_start(day_duration: float):
	return (MID_DAY_HOURS - day_duration / 2) * float(MINUTES_PER_HOUR) * float(MINUTE_DURATION)

func _day_end(day_duration: float):
	return (MID_DAY_HOURS + day_duration / 2) * float(MINUTES_PER_HOUR) * float(MINUTE_DURATION) - SUN_TRANSITION_DURATION

func _update_modulate_color():
	var time = float(current.hour * MINUTES_PER_HOUR + current.minute) * float(MINUTE_DURATION) + counter
	var day_start = _day_start(current_day_duration)
	if time < day_start:
		self.color = NIGHT_COLOR
		return
	var day_end = _day_end(current_day_duration)
	var start_until = day_start + SUN_TRANSITION_DURATION
	if time > start_until and time < day_end:
		self.color = DAY_COLOR
		return
	if time <= start_until:
		var part = (time - day_start) / SUN_TRANSITION_DURATION
		self.color = DAY_TRANSITION.gradient.sample(part)
	else:
		var part = (time - day_end) / SUN_TRANSITION_DURATION
		self.color = DAY_TRANSITION.gradient.sample(1.0 - part)

func _physics_process(delta):
	counter += delta * 1000
	if counter > MINUTE_DURATION:
		_update_time()
	
	_update_modulate_color()

func set_time_ms(time: int):
	current.minute = time / MINUTE_DURATION
	current.hour = current.minute / MINUTES_PER_HOUR
	current.minute = current.minute % MINUTES_PER_HOUR
	current.hour = current.hour % HOURS_PER_DAY

func set_time_morning():
	var time_skip: float = 0
	var start = int(_day_start(current_day_duration))
	var time = time_to_ms(current)
	if time > start:
		current.day += 1
		current.year += current.day / DAYS_PER_YEAR
		current.day = current.day % DAYS_PER_YEAR
		time_skip = HOURS_PER_DAY * MINUTES_PER_HOUR * MINUTE_DURATION - time + _day_duration(current.day)
	else:
		time_skip = float(start - time)
	current_day_duration = _day_duration(current.day)
	set_time_ms(int(_day_start(current_day_duration)))
	time_skipped.emit(time_skip)
