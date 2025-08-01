extends Node2D

# Global game settings
const MAX_EXTINCTIONS = 3
const COMPENSATE_FRAMES = 0
const COMPENSATE_HZ = 60.0
const BACKGROUND_COLOR = Color(0.133, 0.039, 0.329)

# Game states
enum GameState {TITLE, LEVEL_SELECTION, PLAYING, GAME_OVER}
var current_state = GameState.TITLE

var ateroidsGenerated = 0
var lastBeat = 0
var playing = false
var lastAsteroidGeneratedOnSecond = 0
var userScore = 0
var massExtinctions = 0

# Level management
var level_manager: LevelManager

# Animation tweens
var moon_tween: Tween = null
var earth_tween: Tween = null
var screen_shake_tween: Tween = null

# Popup label system
var popup_label_scene = preload("res://src/ScorePopupLabel.tscn")
var active_popups = []
var asteroid_popups = {}  # Dictionary to track popup labels by asteroid ID

# Explosion system
var explosion_scene = preload("res://src/Explosion.tscn")

# Screen shake system
var original_camera_position: Vector2
var is_shaking = false

# Position constants
const MOON_TITLE_SCALE = 1.5
const MOON_GAME_SCALE = 1.0
const MOON_TITLE_Y = -300
const MOON_GAME_Y = -100
const EARTH_TITLE_Y = 200
const EARTH_GAME_Y = 400 
const ANIMATION_DURATION = 1.0

#onready var Asteroid = preload("res://src/asteroid/AsteroidScene.tscn")

var asteroidGenerator = preload("res://src/asteroid/AsteroidGenerator.gd").AsteroidGenerator.new()

func _ready():
	# Initialize level manager
	level_manager = LevelManager.new()
	add_child(level_manager)
	
	# Set background color from global settings
	RenderingServer.set_default_clear_color(BACKGROUND_COLOR)
	
	# Debug output to verify level loading
	var current_level = level_manager.get_current_level()
	print("Level system initialized:")
	print("  Level name: ", current_level.level_name)
	print("  BPM: ", current_level.bpm)
	print("  Music track: ", current_level.music_track.get_path() if current_level.music_track else "None")
	print("  Max extinctions: ", MAX_EXTINCTIONS)
	print("  Level duration: ", level_manager.get_level_duration(), " seconds")
	
	# Store original camera position for screen shake
	original_camera_position = $Camera2D.position
	
	# Connect signals from instanced scenes
	$TitleScreen.start_game_requested.connect(_on_start_button_pressed)
	$GameOverScreen.restart_game_requested.connect(_on_restart_button_pressed)
	$GameOverScreen.main_menu_requested.connect(_on_main_menu_button_pressed)
	$LevelSelectionScreen.level_selected.connect(_on_level_selected)
	$LevelSelectionScreen.back_to_title_requested.connect(_on_back_to_title_requested)
	
	# Test animation system
	print("Initial positions:")
	print("Moon: ", $Area2D/Player.position)
	print("Earth: ", $Area2D/earth.position)
	
	show_title_screen()
	pass

func _process(_delta):
	if current_state != GameState.PLAYING:
		return
		
	if !playing or !$AudioPlayer.playing:
		$AudioPlayer.play()
		playing = true
		return
	
	var current_level = level_manager.get_current_level()
	var time = $AudioPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES
	
	
	var beat = int(time * current_level.bpm / 60.0)
	var seconds = int(time)
	var seconds_total = int($AudioPlayer.stream.get_length())
	
	var minutesPlayed = seconds / 60
	var secondsPlayed = seconds % 60
	if (beat != lastBeat):
		#print(str("BEAT: ", beat % current_level.bars + 1, "/", current_level.bars, " TIME: ", minutesPlayed, ":", secondsPlayed, " / ", seconds_total / 60, ":", strsec(seconds_total % 60)))
		lastBeat = beat;
		#only start generating after 13 seconds
		
		# Check if we should spawn an asteroid at this second
		if level_manager.should_spawn_asteroid_at_second(seconds):
			var is_high_intensity = level_manager.is_high_intensity_spawn(seconds)
			print("Spawning asteroid at second ", seconds, " (high intensity: ", is_high_intensity, ")")
			generateAsteroid(seconds, !is_high_intensity)  # enforceSecondsRule is true for low intensity, false for high intensity
			
	
	pass

func show_title_screen():
	current_state = GameState.TITLE
	$TitleScreen.visible = true
	$LevelSelectionScreen.visible = false
	$GameOverScreen.visible = false
	$GameUI.visible = false
	$AudioPlayer.stop()
	playing = false
	
	# Ensure stars are stopped
	$Area2D/Stars.end_game()
	$GameUI.end_game()
	
	# Reset moon's x position to center
	$Area2D/Player.reset_position()
	
	# Show the moon for title screen
	$Area2D/Player.visible = true
	
	# Animate moon and earth back to title positions
	animate_to_title_positions()
	
	# Reset game state
	userScore = 0
	massExtinctions = 0
	ateroidsGenerated = 0
	lastBeat = 0
	lastAsteroidGeneratedOnSecond = 0
	
	# Clear any existing asteroids
	for child in $Area2D/CollisionShape2D.get_children():
		if child.has_method("queue_free"):
			$Area2D/CollisionShape2D.remove_child(child)
			child.queue_free()
	
	# Clear all popup labels
	clear_all_popups()

func start_game():
	print("Starting game...")
	current_state = GameState.PLAYING
	$TitleScreen.visible = false
	$LevelSelectionScreen.visible = false
	$GameOverScreen.visible = false
	$GameUI.visible = true
	
	# Show the moon again for gameplay
	$Area2D/Player.visible = true
	
	# Reset game state
	userScore = 0
	massExtinctions = 0
	ateroidsGenerated = 0
	lastBeat = 0
	lastAsteroidGeneratedOnSecond = 0
	
	# Clear any existing asteroids
	for child in $Area2D/CollisionShape2D.get_children():
		if child.has_method("queue_free"):
			$Area2D/CollisionShape2D.remove_child(child)
			child.queue_free()
	
	# Clear all popup labels
	clear_all_popups()
	
	# Start star acceleration
	$Area2D/Stars.start_game()
	
	# Start the years counter
	$GameUI.start_game()
	
	# Set the music track from the level BEFORE animation
	var current_level = level_manager.get_current_level()
	print("Loading level: ", current_level.level_name)
	print("Music track: ", current_level.music_track.get_path() if current_level.music_track else "None")
	$AudioPlayer.stream = current_level.music_track
	
	# Animate moon and earth to game positions
	animate_to_game_positions()
	
	# Start audio immediately (don't wait for animation)
	$AudioPlayer.play()
	playing = true
	print("Audio started, playing: ", playing)

func show_game_over_screen():
	current_state = GameState.GAME_OVER
	$TitleScreen.visible = false
	$LevelSelectionScreen.visible = false
	$GameOverScreen.visible = true
	$GameUI.visible = false
	$AudioPlayer.stop()
	playing = false
	
	# Start star deceleration
	$Area2D/Stars.end_game()
	$GameUI.end_game()
	
	# Reset moon's x position to center
	$Area2D/Player.reset_position()
	
	# Animate moon and earth back to title positions
	animate_to_title_positions()
	
	# Update game over screen with final score
	$GameOverScreen.update_final_score(userScore)
	
	# Clear all popup labels
	clear_all_popups()

func test_animation():
	print("Testing animation system...")
	
	# Create a simple test tween
	var test_tween = create_tween()
	test_tween.set_ease(Tween.EASE_OUT)
	test_tween.set_trans(Tween.TRANS_CUBIC)
	
	# Animate moon up and down
	test_tween.tween_property($Area2D/Player, "position:y", MOON_GAME_Y, 0.5)
	test_tween.tween_property($Area2D/Player, "position:y", MOON_TITLE_Y, 0.5)
	
	print("Test animation started")

func animate_to_game_positions():
	# Signal to Player that animation is starting
	$Area2D/Player.is_animating = true
	
	print("Starting animation to game positions...")
	print("Current moon position: ", $Area2D/Player.position)
	print("Current earth position: ", $Area2D/earth.position)
	
	# Create new tweens
	moon_tween = create_tween()
	moon_tween.set_ease(Tween.EASE_OUT)
	moon_tween.set_trans(Tween.TRANS_CUBIC)
	print("Animating moon from Y=", $Area2D/Player.position.y, " to Y=", MOON_GAME_Y)
	
	# Use parallel() to make position and scale animations happen together
	moon_tween.parallel().tween_property($Area2D/Player, "position:y", MOON_GAME_Y, ANIMATION_DURATION)
	moon_tween.parallel().tween_property($Area2D/Player, "scale", Vector2(MOON_GAME_SCALE, MOON_GAME_SCALE), ANIMATION_DURATION)
	
	earth_tween = create_tween()
	earth_tween.set_ease(Tween.EASE_OUT)
	earth_tween.set_trans(Tween.TRANS_CUBIC)
	print("Animating earth from Y=", $Area2D/earth.position.y, " to Y=", EARTH_GAME_Y)
	earth_tween.tween_property($Area2D/earth, "position:y", EARTH_GAME_Y, ANIMATION_DURATION)
	
	# Wait for animation to complete
	await moon_tween.finished
	print("Animation to game positions completed")
	$Area2D/Player.is_animating = false
	
	# Clean up tweens
	moon_tween = null
	earth_tween = null

func animate_to_title_positions():
	# Signal to Player that animation is starting
	$Area2D/Player.is_animating = true
	
	print("Starting animation to title positions...")
	print("Current moon position: ", $Area2D/Player.position)
	print("Current earth position: ", $Area2D/earth.position)
	
	# Create new tweens
	moon_tween = create_tween()
	moon_tween.set_ease(Tween.EASE_OUT)
	moon_tween.set_trans(Tween.TRANS_CUBIC)
	print("Animating moon from Y=", $Area2D/Player.position.y, " to Y=", MOON_TITLE_Y)
	
	# Use parallel() to make position and scale animations happen together
	moon_tween.parallel().tween_property($Area2D/Player, "position:y", MOON_TITLE_Y, ANIMATION_DURATION)
	moon_tween.parallel().tween_property($Area2D/Player, "scale", Vector2(MOON_TITLE_SCALE, MOON_TITLE_SCALE), ANIMATION_DURATION)
	
	earth_tween = create_tween()
	earth_tween.set_ease(Tween.EASE_OUT)
	earth_tween.set_trans(Tween.TRANS_CUBIC)
	print("Animating earth from Y=", $Area2D/earth.position.y, " to Y=", EARTH_TITLE_Y)
	earth_tween.tween_property($Area2D/earth, "position:y", EARTH_TITLE_Y, ANIMATION_DURATION)
	
	# Wait for animation to complete
	await moon_tween.finished
	print("Animation to title positions completed")
	$Area2D/Player.is_animating = false
	
	# Clean up tweens
	moon_tween = null
	earth_tween = null

func generateAsteroid(seconds, enforceSecondsRule):
	
	# no need for 2 asteroids at the same second
	if (enforceSecondsRule && lastAsteroidGeneratedOnSecond == seconds):
		return;
	
	lastAsteroidGeneratedOnSecond = seconds;
	
	# todo remove this
	#if (ateroidsGenerated > 0):
	#	return
	
	var randX = 0
	
	var screenWidth = get_viewport_rect().size.x
	var paddedWidth = get_viewport_rect().size.x * 0.8
	
	
	randomize()
	
	if (ateroidsGenerated  % 2 == 0):
		randX = randf_range(paddedWidth / -2, 0)
	else:
		randX = randf_range(0, paddedWidth / 2)
	pass
	
	
	
	var newAsteroid = asteroidGenerator.generateAsteroid()
	newAsteroid.position = Vector2(randX,-800)
	get_node("Area2D/CollisionShape2D").add_child(newAsteroid)
	
	
	var body = newAsteroid.get_node("AsteroidRigidBody")
	body.connect("asteroid_hit_by_moon", Callable(self, "_onAsteroidHitByMoon"))
	body.connect("asteroid_hit_by_asteroid", Callable(self, "_onAsteroidHitByAsteroid"))
	body.connect("asteroid_hit_earth", Callable(self, "_onAsteroidHitEarth"))
	body.connect("asteroid_crazy_spin", Callable(self, "_onAsteroidCrazySpin"))
	body.connect("asteroid_moon_hit_complete", Callable(self, "_onAsteroidMoonHitComplete"))
	body.connect("asteroid_asteroid_hit_complete", Callable(self, "_onAsteroidAsteroidHitComplete"))
	body.get_node("VisibleOnScreenNotifier2D").connect("asteroid_exit_screen", Callable(self, "_onAsteroidExitScreen"))

	
	ateroidsGenerated = ateroidsGenerated + 1
	print("asteroid #", ateroidsGenerated, " generated ", newAsteroid)
	pass

func strsec(secs):
	var s = str(secs)
	if (secs < 10):
		s = "0" + s
	return s

func show_score_popup(text: String, score: int = 0, color: Color = Color.WHITE, asteroid_position: Vector2 = Vector2.ZERO, asteroid_id: int = -1):
	# Check if we already have a popup for this asteroid
	if asteroid_id != -1 and asteroid_popups.has(asteroid_id):
		var existing_popup = asteroid_popups[asteroid_id]
		if is_instance_valid(existing_popup):
			# Update existing popup with new score
			existing_popup.update_score(score)
			return
	
	# Create a new popup label
	var popup = popup_label_scene.instantiate()
	$GameUI.add_child(popup)
	active_popups.append(popup)
	
	# Track by asteroid ID if provided
	if asteroid_id != -1:
		asteroid_popups[asteroid_id] = popup
	
	# Show the popup (this will handle its own cleanup)
	popup.show_popup(text, score, color, 1.0, asteroid_position)
	
	# Set up automatic cleanup
	popup.tree_exited.connect(func(): 
		active_popups.erase(popup)
		if asteroid_id != -1 and asteroid_popups.has(asteroid_id):
			asteroid_popups.erase(asteroid_id)
	)

func clear_all_popups():
	# Remove all active popup labels
	for popup in active_popups:
		if is_instance_valid(popup):
			popup.queue_free()
	active_popups.clear()
	asteroid_popups.clear()

func spawn_explosion(position: Vector2):
	# Create a new explosion instance
	var explosion = explosion_scene.instantiate()
	
	# Add it to the main scene so it appears above everything
	add_child(explosion)
	
	# Set the explosion position
	explosion.global_position = position
	
	print("Explosion spawned at position: ", position)

func _onAsteroidHitByMoon(asteroid):
	print("hit")
	var asteroid_node = asteroid.get_parent()
	
	# The asteroid has already been marked as hit by moon in AsteroidRigidBody
	# but we still need to call onHit() to track hit count for bonus points
	asteroid_node.onHit()
	
	# Give immediate score for the hit
	userScore += 5
	print("Moon hit! Score updated to: ", userScore)
	
	# Notify the UserScoreLabel directly about the score change
	if $GameUI.get_user_score_label():
		$GameUI.get_user_score_label().on_score_changed(5)
	
	# Add screen shake for moon collision
	_add_screen_shake(5.0, 0.2)
	
	# Don't Show popup for moon hit
	# var asteroid_id = asteroid_node.asteroid_id
	# show_score_popup("MOON HIT!", 2, Color(0xFE, 0xC1, 0x5D), asteroid.global_position, asteroid_id)
	
	# Add angular velocity boost to potentially trigger crazy spin
	var angular_boost = randf_range(15.0, 25.0)
	asteroid.angular_velocity += angular_boost * (1 if randf() > 0.5 else -1)  # Random direction
	print("Added angular boost: ", angular_boost, " to asteroid")
	
	# The asteroid will now flash and be removed by the flashing sequence
	pass

func _onAsteroidHitByAsteroid(asteroid):
	print("asteroid hit asteroid")
	asteroid.get_parent().onHit()
	
	# Give higher score for asteroid-asteroid collision (more than moon hits)
	userScore += 8  # Increased from 5 to 8
	
	# Notify the UserScoreLabel directly about the score change
	if $GameUI.get_user_score_label():
		$GameUI.get_user_score_label().on_score_changed(8)
	
	# Get the asteroid ID from the parent node
	var asteroid_node = asteroid.get_parent()
	var asteroid_id = asteroid_node.asteroid_id
	
	# Add screen shake for asteroid collision
	_add_screen_shake(8.0, 0.3)
	
	# Convert world position to screen coordinates for popup
	var viewport_size = get_viewport_rect().size
	var camera_pos = $Camera2D.global_position + $Camera2D.offset
	var popup_position = asteroid.global_position - camera_pos + viewport_size / 2
	
	# Show popup for chain reaction with updated score
	show_score_popup("CHAIN REACTION!", 8, Color(0.306, 0.792, 0.910), popup_position, asteroid_id)
	
	# Add significant angular velocity boost for asteroid-asteroid collisions
	var angular_boost = randf_range(20.0, 35.0)
	asteroid.angular_velocity += angular_boost * (1 if randf() > 0.5 else -1)  # Random direction
	print("Asteroid collision! Added angular boost: ", angular_boost, " to asteroid")
	pass

func _onAsteroidHitEarth(asteroid):
	print("asteroid hit earth")
	# The asteroid parameter is the RigidBody2D, so we need to get the parent Node2D
	var asteroid_node = asteroid.get_parent()
	asteroid_node.onHitEarth()
	
	# Make the asteroid crash into Earth (stop physics and movement)
	asteroid.crash_into_earth()
	
	# Update extinctions count immediately when Earth is hit
	massExtinctions += 1
	
	# Get the asteroid ID from the parent node
	var asteroid_id = asteroid_node.asteroid_id
	
	# Add dramatic screen shake for earth collision
	_add_screen_shake(25.0, 1.5)
	
	# Spawn explosion at the collision point
	spawn_explosion(asteroid.global_position)
	
	# Convert world position to screen coordinates for popup
	var viewport_size = get_viewport_rect().size
	var camera_pos = $Camera2D.global_position + $Camera2D.offset
	var popup_position = asteroid.global_position - camera_pos + viewport_size / 2
	
	# Show popup for mass extinction
	show_score_popup("MASS EXTINCTION!", 0, Color(1.0, 0.439, 0.263), popup_position, asteroid_id)
	
	# Remove the asteroid after a delay to show the impact
	await get_tree().create_timer(0.5).timeout
	removeAsteroid(asteroid_node, false)
	
	pass
	
func _onAsteroidExitScreen(asteroid):
	
	# Check if asteroid is still valid before accessing its properties
	if not is_instance_valid(asteroid):
		print("Asteroid is no longer valid, skipping exit screen handling")
		return
	
	# Don't remove asteroids that have already hit Earth (they'll be removed separately)
	if asteroid.hitEarth:
		return
	
	# Remove asteroids that exit screen and weren't hit by anything
	removeAsteroid(asteroid, false)
	pass

func _onAsteroidCrazySpin(asteroid, points):
	print("Asteroid crazy spin! Awarding ", points, " points")
	userScore += points
	
	# Notify the UserScoreLabel directly about the score change
	if $GameUI.get_user_score_label():
		$GameUI.get_user_score_label().on_score_changed(points)
	
	# Get the asteroid ID from the parent node
	var asteroid_node = asteroid.get_parent()
	var asteroid_id = asteroid_node.asteroid_id
	
	# Convert world position to screen coordinates for popup
	var viewport_size = get_viewport_rect().size
	var camera_pos = $Camera2D.global_position + $Camera2D.offset
	var popup_position = asteroid.global_position - camera_pos + viewport_size / 2
	
	# Show popup for crazy spin (will update existing popup if one exists for this asteroid)
	show_score_popup("CRAZY SPIN!", points, Color(1.0, 0.420, 0.420), popup_position, asteroid_id)
	pass

func _onAsteroidMoonHitComplete(asteroid):
	print("Asteroid moon hit sequence complete, removing asteroid")
	var asteroid_node = asteroid.get_parent()
	
	# Check if asteroid is still valid and hasn't been removed yet
	if is_instance_valid(asteroid_node) and not asteroid_node.isRemoved:
		removeAsteroid(asteroid_node, true)
	else:
		print("Asteroid was already removed by exit screen logic")
	pass

func _onAsteroidAsteroidHitComplete(asteroid):
	print("Asteroid-asteroid hit sequence complete, removing asteroid")
	var asteroid_node = asteroid.get_parent()
	
	# Check if asteroid is still valid and hasn't been removed yet
	if is_instance_valid(asteroid_node) and not asteroid_node.isRemoved:
		removeAsteroid(asteroid_node, true)
	else:
		print("Asteroid was already removed by exit screen logic")
	pass
	

func removeAsteroid(asteroid, hit):
	
	print("removing asteroid ",asteroid)
	
	# Check if asteroid is still valid before accessing its properties
	if not is_instance_valid(asteroid):
		print("Asteroid is no longer valid, skipping removal")
		return
	
	# Check if asteroid has already been removed to prevent double-removal
	if asteroid.isRemoved:
		print("Asteroid was already removed, skipping")
		return
	
	# Mark asteroid as removed to prevent future removal attempts
	asteroid.markAsRemoved()
	
	# Update score BEFORE removing the asteroid (so we can access its properties)
	if (asteroid.wasHit):
		# Bonus score when asteroid is removed, based on number of hits
		var bonus_points = 10 * asteroid.hitCount
		userScore += bonus_points
		print("Asteroid destroyed! Bonus points: ", bonus_points, " Score updated to: ", userScore)
		
		# Notify the UserScoreLabel directly about the score change
		if $GameUI.get_user_score_label():
			$GameUI.get_user_score_label().on_score_changed(bonus_points)
		
		# Don't Show popup for destruction bonus
		# var asteroid_id = asteroid.asteroid_id
		# show_score_popup("DESTROYED!", bonus_points, Color(0x51, 0xCF, 0x66), asteroid.global_position, asteroid_id)
	
	# If the asteroid hit Earth, add a small delay to make the impact feel more dramatic
	if asteroid.hitEarth:
		# Wait a short moment to show the impact
		await get_tree().create_timer(0.3).timeout
	
	# Check again after the delay in case the asteroid was freed during the delay
	if not is_instance_valid(asteroid):
		print("Asteroid was freed during delay, skipping removal")
		return
	
	$Area2D/CollisionShape2D.remove_child(asteroid)
	asteroid.queue_free()
	
	#print("user score is: ", userScore)
	#print("mass extinctions: ", massExtinctions)
	

	# Check for game over condition immediately
	if massExtinctions >= MAX_EXTINCTIONS:
		show_game_over_screen()
	
	pass

func _on_start_button_pressed():
	show_level_selection_screen()

func _on_restart_button_pressed():
	show_level_selection_screen()

func _on_main_menu_button_pressed():
	show_title_screen()

func _on_level_selected(level_number: int):
	print("Level ", level_number, " selected, starting game...")
	level_manager.load_level(level_number)
	start_game()

func _on_back_to_title_requested():
	show_title_screen()

func show_level_selection_screen():
	current_state = GameState.LEVEL_SELECTION
	$TitleScreen.visible = false
	$LevelSelectionScreen.visible = true
	$GameOverScreen.visible = false
	$GameUI.visible = false
	$AudioPlayer.stop()
	playing = false
	
	# Ensure stars are stopped
	$Area2D/Stars.end_game()
	$GameUI.end_game()
	
	# Reset moon's x position to center
	$Area2D/Player.reset_position()
	
	# Animate moon and earth back to title positions
	animate_to_title_positions()
	
	# Hide the moon for level selection screen
	$Area2D/Player.visible = false
	
	# Reset game state
	userScore = 0
	massExtinctions = 0
	ateroidsGenerated = 0
	lastBeat = 0
	lastAsteroidGeneratedOnSecond = 0
	
	# Clear any existing asteroids
	for child in $Area2D/CollisionShape2D.get_children():
		if child.has_method("queue_free"):
			$Area2D/CollisionShape2D.remove_child(child)
			child.queue_free()
	
	# Clear all popup labels
	clear_all_popups()
	
	# Update level selection screen with available levels
	$LevelSelectionScreen.update_available_levels()

# Test function to load different levels (for development)
func test_load_level(level_number: int):
	if current_state == GameState.TITLE:
		level_manager.load_level(level_number)
		var current_level = level_manager.get_current_level()
		print("Test: Loaded ", current_level.level_name)
		print("  BPM: ", current_level.bpm)
		print("  Music track: ", current_level.music_track.get_path() if current_level.music_track else "None")

# Getter methods for the UI labels
func get_user_score():
	return userScore

func get_mass_extinctions():
	return massExtinctions

func _add_screen_shake(intensity: float, duration: float):
	print("Screen shake called with intensity: ", intensity, " duration: ", duration)
	
	# Stop any existing screen shake
	if screen_shake_tween:
		screen_shake_tween.kill()
	
	screen_shake_tween = create_tween()
	is_shaking = true
	
	print("Original camera position: ", original_camera_position)
	
	# Create a series of random shakes
	var shake_count = int(duration * 20)  # 20 shakes per second
	print("Creating ", shake_count, " shakes")
	
	for i in range(shake_count):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		var target_position = original_camera_position + shake_offset
		print("Shake ", i, ": offset=", shake_offset, " target=", target_position)
		screen_shake_tween.tween_property($Camera2D, "position", target_position, duration / shake_count)
	
	# Return to original position
	screen_shake_tween.tween_property($Camera2D, "position", original_camera_position, 0.1)
	screen_shake_tween.tween_callback(func(): 
		is_shaking = false
		print("Screen shake finished")
	)
