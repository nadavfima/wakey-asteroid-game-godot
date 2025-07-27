extends Node2D

const BPM = 139
const BARS = 16

# Game states
enum GameState {TITLE, PLAYING, GAME_OVER}
var current_state = GameState.TITLE

var ateroidsGenerated = 0
var lastBeat = 0
var playing = false
const COMPENSATE_FRAMES = 0
const COMPENSATE_HZ = 60.0

var lastAsteroidGeneratedOnSecond = 0
var userScore = 0
var massExtinctions = 0
var maxExtinctions = 3

# Animation tweens
var moon_tween: Tween = null
var earth_tween: Tween = null
var screen_shake_tween: Tween = null

# Popup label system
var popup_label_scene = preload("res://src/ScorePopupLabel.tscn")
var active_popups = []
var asteroid_popups = {}  # Dictionary to track popup labels by asteroid ID

# Screen shake system
var original_camera_position: Vector2
var is_shaking = false

# Position constants
const MOON_TITLE_Y = -400
const MOON_GAME_Y = 0
const EARTH_TITLE_Y = 39
const EARTH_GAME_Y = 333 
const ANIMATION_DURATION = 1.0

#onready var Asteroid = preload("res://src/asteroid/AsteroidScene.tscn")

const oneAstr = [3,6,9]
const lowAstr =  [[26, 38], [52, 64], [78, 90], [121, 150], [181, 210]]
const highAstr = [[13, 25], [39, 51], [65, 77], [91, 120], [151, 180]]

var asteroidGenerator = preload("res://src/asteroid/AsteroidGenerator.gd").AsteroidGenerator.new()

var spaceRubble = { 3 : oneAstr,
					6 : oneAstr,
					9 : oneAstr,
					
					 }

func _ready():
	RenderingServer.set_default_clear_color(Color(0.133, 0.039, 0.329))
	
	# Store original camera position for screen shake
	original_camera_position = $Camera2D.position
	
	# Connect button signals
	$TitleScreen/Control/StartButton.pressed.connect(_on_start_button_pressed)
	$GameOverScreen/Control/VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$GameOverScreen/Control/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	
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
	
	var time = $AudioPlayer.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency() + (1 / COMPENSATE_HZ) * COMPENSATE_FRAMES
	
	
	var beat = int(time * BPM / 60.0)
	var seconds = int(time)
	var seconds_total = int($AudioPlayer.stream.get_length())
	
	var minutesPlayed = seconds / 60
	var secondsPlayed = seconds % 60
	if (beat != lastBeat):
		#print(str("BEAT: ", beat % BARS + 1, "/", BARS, " TIME: ", minutesPlayed, ":", secondsPlayed, " / ", seconds_total / 60, ":", strsec(seconds_total % 60)))
		lastBeat = beat;
		#only start generating after 13 seconds
		
		for n in oneAstr:
			if (seconds == n):
				generateAsteroid(seconds, true)
		
		for n in lowAstr:
			if (seconds >= n[0] && seconds <= n[1]):
				generateAsteroid(seconds, true)
				
		for n in highAstr:
			if (seconds >= n[0] && seconds <= n[1]):
				generateAsteroid(seconds, false)
			
	
	pass

func show_title_screen():
	current_state = GameState.TITLE
	$TitleScreen.visible = true
	$GameOverScreen.visible = false
	$GameUI.visible = false
	$AudioPlayer.stop()
	playing = false
	
	# Ensure stars are stopped
	$Stars.end_game()
	
	# Reset moon's x position to center
	$Area2D/Player.reset_position()
	
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
	current_state = GameState.PLAYING
	$TitleScreen.visible = false
	$GameOverScreen.visible = false
	$GameUI.visible = true
	
	# Start star acceleration
	$Stars.start_game()
	
	# Start the years counter
	$GameUI/EpochLabel.start_counting()
	
	# Animate moon and earth to game positions
	animate_to_game_positions()
	
	# Start audio after animation completes
	$AudioPlayer.play()
	playing = true

func show_game_over_screen():
	current_state = GameState.GAME_OVER
	$TitleScreen.visible = false
	$GameOverScreen.visible = true
	$GameUI.visible = false
	$AudioPlayer.stop()
	playing = false
	
	# Start star deceleration
	$Stars.end_game()
	
	# Reset moon's x position to center
	$Area2D/Player.reset_position()
	
	# Animate moon and earth back to title positions
	animate_to_title_positions()
	
	# Update game over screen with final score
	$GameOverScreen/Control/VBoxContainer/ScoreLabel.text = "[color=#FEC15D]Final Score:[/color] [color=#FFFFF3]" + str(userScore) + "[/color]"
	
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
	moon_tween.tween_property($Area2D/Player, "position:y", MOON_GAME_Y, ANIMATION_DURATION)
	
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
	moon_tween.tween_property($Area2D/Player, "position:y", MOON_TITLE_Y, ANIMATION_DURATION)
	
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

func _onAsteroidHitByMoon(asteroid):
	print("hit")
	asteroid.get_parent().onHit()
	
	# Give immediate score for the hit
	userScore += 5
	
	# Add screen shake for moon collision
	_add_screen_shake(5.0, 0.2)
	
	# Don't Show popup for moon hit
	# var asteroid_node = asteroid.get_parent()
	# var asteroid_id = asteroid_node.asteroid_id
	# show_score_popup("MOON HIT!", 2, Color(0xFE, 0xC1, 0x5D), asteroid.global_position, asteroid_id)
	
	# Add angular velocity boost to potentially trigger crazy spin
	var angular_boost = randf_range(15.0, 25.0)
	asteroid.angular_velocity += angular_boost * (1 if randf() > 0.5 else -1)  # Random direction
	print("Added angular boost: ", angular_boost, " to asteroid")
	pass

func _onAsteroidHitByAsteroid(asteroid):
	print("asteroid hit asteroid")
	asteroid.get_parent().onHit()
	
	# Give immediate score for asteroid-asteroid collision
	userScore += 5
	
	# Get the asteroid ID from the parent node
	var asteroid_node = asteroid.get_parent()
	var asteroid_id = asteroid_node.asteroid_id
	
	# Add screen shake for asteroid collision
	_add_screen_shake(8.0, 0.3)
	
	# Show popup for chain reaction
	show_score_popup("CHAIN REACTION!", 5, Color(0xFF, 0x6B, 0x6B), asteroid.global_position, asteroid_id)
	
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
	_add_screen_shake(15.0, 0.5)
	
	# Show popup for mass extinction
	show_score_popup("MASS EXTINCTION!", 0, Color(0xFF, 0x00, 0x00), asteroid.global_position, asteroid_id)
	
	# Remove the asteroid after a delay to show the impact
	await get_tree().create_timer(0.5).timeout
	removeAsteroid(asteroid_node, false)
	
	pass
	
func _onAsteroidExitScreen(asteroid):
	print("exit screen")
	
	# Check if asteroid is still valid before accessing its properties
	if not is_instance_valid(asteroid):
		print("Asteroid is no longer valid, skipping exit screen handling")
		return
	
	# Don't remove asteroids that have already hit Earth (they'll be removed separately)
	if asteroid.hitEarth:
		return
	
	removeAsteroid(asteroid, false)
	pass

func _onAsteroidCrazySpin(asteroid, points):
	print("Asteroid crazy spin! Awarding ", points, " points")
	userScore += points
	
	# Get the asteroid ID from the parent node
	var asteroid_node = asteroid.get_parent()
	var asteroid_id = asteroid_node.asteroid_id
	
	# Show popup for crazy spin (will update existing popup if one exists for this asteroid)
	show_score_popup("CRAZY SPIN!", points, Color(0x4E, 0xCA, 0xE8), asteroid.global_position, asteroid_id)
	pass
	

func removeAsteroid(asteroid, hit):
	
	print("removing asteroid ",asteroid)
	
	# Check if asteroid is still valid before accessing its properties
	if not is_instance_valid(asteroid):
		print("Asteroid is no longer valid, skipping removal")
		return
	
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
	
	
	if (asteroid.wasHit):
		# Bonus score when asteroid is removed, based on number of hits
		var bonus_points = 10 * asteroid.hitCount
		userScore += bonus_points
		
		# Don't Show popup for destruction bonus
		# var asteroid_id = asteroid.asteroid_id
		# show_score_popup("DESTROYED!", bonus_points, Color(0x51, 0xCF, 0x66), asteroid.global_position, asteroid_id)
	
	#print("user score is: ", userScore)
	#print("mass extinctions: ", massExtinctions)
	

	# Check for game over condition immediately
	if massExtinctions >= maxExtinctions:
		show_game_over_screen()
	
	pass

func _on_start_button_pressed():
	start_game()

func _on_restart_button_pressed():
	start_game()

func _on_main_menu_button_pressed():
	show_title_screen()

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
