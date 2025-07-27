extends Node2D

var asteroid_id: int = 0
var hitCount = 0
var wasHit = false
var hitEarth = false
var hitByMoon = false  # New state to track moon hits
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
	# Mark as hit by asteroid (similar to moon hit but different state)
	hitByMoon = true  # Reuse the same state since both lead to removal
	hitCount += 1
	wasHit = true

func markAsRemoved():
	isRemoved = true
