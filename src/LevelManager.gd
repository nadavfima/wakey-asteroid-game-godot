class_name LevelManager
extends Node

# Singleton pattern for easy access
static var instance: LevelManager

# Current level data
var current_level: Level

func _ready():
	# Set up singleton instance
	instance = self
	
	# Load default level (Level 1)
	load_level(1)

# Load a specific level by number
func load_level(level_number: int):
	var resource_path = "res://src/levels/level_" + str(level_number) + ".tres"
	print("Attempting to load level from: ", resource_path)
	var level_resource = load(resource_path)
	if level_resource and level_resource is Level:
		current_level = level_resource
		print("Successfully loaded ", current_level.level_name, " from resource")
		print("  BPM: ", current_level.bpm)
		print("  Music track: ", current_level.music_track.get_path() if current_level.music_track else "None")
	else:
		print("Level ", level_number, " resource not found, using default Level 1")
		# Fallback to default level
		current_level = Level.new()
		current_level.level_name = "Level 1"
		current_level.bpm = 139
		current_level.bars = 16
		current_level.music_track = preload("res://assets/Space Rubble.wav")
		current_level.single_asteroid_seconds = [3, 6, 9]
		current_level.low_intensity_periods = [[26, 38], [52, 64], [78, 90], [121, 150], [181, 210]]
		current_level.high_intensity_periods = [[13, 25], [39, 51], [65, 77], [91, 120], [151, 180]]

# Get the current level
func get_current_level() -> Level:
	return current_level

# Set a specific level
func set_level(level: Level):
	current_level = level
	print("Loaded level: ", current_level.level_name)

# Load a level from a resource file (for custom levels)
func load_level_from_resource(resource_path: String) -> bool:
	var level_resource = load(resource_path)
	if level_resource and level_resource is Level:
		current_level = level_resource
		print("Loaded level from resource: ", current_level.level_name)
		return true
	else:
		print("Failed to load level from resource: ", resource_path)
		return false

# Helper method to check if an asteroid should be spawned
func should_spawn_asteroid_at_second(seconds: int) -> bool:
	if current_level:
		return current_level.should_spawn_asteroid_at_second(seconds)
	return false

# Helper method to check if this is a high intensity spawn
func is_high_intensity_spawn(seconds: int) -> bool:
	if current_level:
		return current_level.is_high_intensity_spawn(seconds)
	return false

# Get level duration
func get_level_duration() -> int:
	if current_level:
		return current_level.get_level_duration()
	return 0

# Get total number of available levels
func get_total_levels() -> int:
	# Count how many level resource files exist
	var level_count = 0
	for i in range(1, 10):  # Check up to level 10
		var resource_path = "res://src/levels/level_" + str(i) + ".tres"
		if ResourceLoader.exists(resource_path):
			level_count += 1
		else:
			break  # Stop at first missing level
	return level_count 
