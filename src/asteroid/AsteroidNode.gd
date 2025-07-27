extends Node2D

var asteroid_id: int = 0
var hitCount = 0
var wasHit = false
var hitEarth = false
var hitByMoon = false  # Track if hit by moon
var hitByAsteroid = false  # Track if hit by another asteroid
var isRemoved = false  # Track if asteroid has already been removed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func onHit():
	hitCount += 1
	wasHit = true

func onHitEarth():
	hitEarth = true

func onHitByMoon():
	hitByMoon = true

func onHitByAsteroid():
	# Mark as hit by asteroid
	hitByAsteroid = true
	hitCount += 1
	wasHit = true

func markAsRemoved():
	isRemoved = true
