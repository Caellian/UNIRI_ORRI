extends AudioStreamPlayer2D
class_name PlayerSound

enum Sound {
	DIG,
	COLLECT,
	PICKUP,
}

@onready
var playback: AudioStreamPlaybackPolyphonic = get_stream_playback()

var _stream_cache = {}
func _stream(name: String):
	if _stream_cache.has(name):
		return _stream_cache.get(name)
	var audio = ResourceLoader.load("res://sound/player/" + name + ".wav", type_string(typeof(AudioStreamWAV)))
	_stream_cache[name] = audio
	return audio

func _sound_name(sound: Sound):
	if sound == Sound.DIG:
		return "dig"
	elif sound == Sound.COLLECT:
		return "collect"
	elif sound == Sound.PICKUP:
		return "pickup_item"
	else:
		push_error("unhandled sound: " + str(sound))

func play_sound(sound: Sound):
	var sound_stream = _stream(_sound_name(sound))
	playback.play_stream(sound_stream, 0, 0, randf_range(0.9, 1.1))
