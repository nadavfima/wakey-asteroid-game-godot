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
var moon_tween: Tween
var earth_tween: Tween

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
	RenderingServer.set_default_clear_color(Color(0,0.03,0.18))
	
	# Connect button signals
	$TitleScreen/Control/StartButton.pressed.connect(_on_start_button_pressed)
	$GameOverScreen/VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$GameOverScreen/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)
	
	# Initialize tweens
	moon_tween = create_tween()
	earth_tween = create_tween()
	
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

func start_game():
	current_state = GameState.PLAYING
	$TitleScreen.visible = false
	$GameOverScreen.visible = false
	$GameUI.visible = true
	
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
	
	# Animate moon and earth back to title positions
	animate_to_title_positions()
	
	# Update game over screen with final scores
	$GameOverScreen/VBoxContainer/ScoreLabel.text = "Final Score: " + str(userScore)
	$GameOverScreen/VBoxContainer/ExtinctionsLabel.text = "Extinctions: " + str(massExtinctions)

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
	body.get_node("VisibleOnScreenNotifier2D").connect("asteroid_exit_screen", Callable(self, "_onAsteroidExitScreen"))

	
	ateroidsGenerated = ateroidsGenerated + 1
	print("asteroid #", ateroidsGenerated, " generated ", newAsteroid)
	pass

func strsec(secs):
	var s = str(secs)
	if (secs < 10):
		s = "0" + s
	return s

func _onAsteroidHitByMoon(asteroid):
	print("hit")
	asteroid.get_parent().onHit()
	pass
	
func _onAsteroidExitScreen(asteroid):
	print("exit screen")
	
	removeAsteroid(asteroid, false)
	pass
	

func removeAsteroid(asteroid, hit):
	
	print("removing asteroid ",asteroid)
	$Area2D/CollisionShape2D.remove_child(asteroid)
	asteroid.queue_free()
	
	
	if (asteroid.wasHit):
		userScore += (5 * asteroid.hitCount)
	else:
		massExtinctions += 1
		
	#print("user score is: ", userScore)
	#print("mass extinctions: ", massExtinctions)
	
	# Check for game over condition
	if massExtinctions >= maxExtinctions:
		show_game_over_screen()
	
	
	pass

func _on_start_button_pressed():
	start_game()

func _on_restart_button_pressed():
	start_game()

func _on_main_menu_button_pressed():
	show_title_screen()
