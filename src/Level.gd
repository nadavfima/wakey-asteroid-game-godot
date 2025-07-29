class_name Level
extends Resource

@export var level_name: String = "Level 1"
@export var bpm: int = 139
@export var bars: int = 16
@export var music_track: AudioStream

# Asteroid spawn patterns
@export var single_asteroid_seconds: Array[int] = [3, 6, 9]
@export var low_intensity_periods: Array[Array] = [[26, 38], [52, 64], [78, 90], [121, 150], [181, 210]]
@export var high_intensity_periods: Array[Array] = [[13, 25], [39, 51], [65, 77], [91, 120], [151, 180]]

func _init():
	# Default constructor for Level 1
	level_name = "Level 1"
	bpm = 139
	bars = 16
	single_asteroid_seconds = [3, 6, 9]
	low_intensity_periods = [[26, 38], [52, 64], [78, 90], [121, 150], [181, 210]]
	high_intensity_periods = [[13, 25], [39, 51], [65, 77], [91, 120], [151, 180]]

# Helper method to check if an asteroid should be spawned at a given second
func should_spawn_asteroid_at_second(seconds: int) -> bool:
	# Check single asteroid spawns
	for spawn_second in single_asteroid_seconds:
		if seconds == spawn_second:
			return true
	
	# Check low intensity periods
	for period in low_intensity_periods:
		if seconds >= period[0] and seconds <= period[1]:
			return true
	
	# Check high intensity periods
	for period in high_intensity_periods:
		if seconds >= period[0] and seconds <= period[1]:
			return true
	
	return false

# Helper method to determine if this is a high intensity spawn
func is_high_intensity_spawn(seconds: int) -> bool:
	for period in high_intensity_periods:
		if seconds >= period[0] and seconds <= period[1]:
			return true
	return false

# Helper method to get the total duration of the level in seconds
func get_level_duration() -> int:
	var max_second = 0
	
	# Check single asteroid spawns
	for second in single_asteroid_seconds:
		max_second = max(max_second, second)
	
	# Check periods
	for period in low_intensity_periods:
		max_second = max(max_second, period[1])
	
	for period in high_intensity_periods:
		max_second = max(max_second, period[1])
	
	return max_second 