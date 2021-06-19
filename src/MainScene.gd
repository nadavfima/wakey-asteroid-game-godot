extends Node2D

const BPM = 139
const BARS = 16

var ateroidsGenerated = 0
var lastBeat = 0
var playing = false
const COMPENSATE_FRAMES = 0
const COMPENSATE_HZ = 60.0

var lastAsteroidGeneratedOnSecond = 0
var userScore = 0
var massExtinctions = 0

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
	VisualServer.set_default_clear_color(Color(0,0.03,0.18))

	pass

func _process(_delta):
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
		randX = rand_range(paddedWidth / -2, 0)
	else:
		randX = rand_range(0, paddedWidth / 2)
	pass
	
	
	
	var newAsteroid = asteroidGenerator.generateAsteroid()
	newAsteroid.position = Vector2(randX,-800)
	get_node("Area2D/CollisionShape2D").add_child(newAsteroid)
	
	
	var body = newAsteroid.get_node("AsteroidRigidBody")
	body.connect("asteroid_hit_by_moon", self, "_onAsteroidHitByMoon")
	body.get_node("VisibilityNotifier2D").connect("asteroid_exit_screen", self, "_onAsteroidExitScreen")

	
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
	remove_child(asteroid)
	asteroid.queue_free()
	
	
	if (asteroid.wasHit):
		userScore += (5 * asteroid.hitCount)
	else:
		massExtinctions += 1
		
	#print("user score is: ", userScore)
	#print("mass extinctions: ", massExtinctions)
	
	
	pass
