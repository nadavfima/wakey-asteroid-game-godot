extends Node2D

var asteroid_id: int = 0
var hitCount = 0
var wasHit = false
var hitEarth = false
var hitByMoon = false  # Track if hit by moon
var hitByAsteroid = false  # Track if hit by another asteroid
var isRemoved = false  # Track if asteroid has already been removed

# Mass configuration - can be set in the scene editor
@export var mass_category: String = "large"  # "small", "medium", "large"

# Cached mass value (calculated once during initialization)
var cached_mass: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	# Calculate and cache the mass value once during initialization
	_calculate_mass()

# Calculate the mass value based on the category with random variance
func _calculate_mass():
	var base_mass: float
	match mass_category:
		"small":
			base_mass = 0.6
		"medium":
			base_mass = 0.8
		"large":
			base_mass = 1.2
		_:
			base_mass = 1.0  # Default fallback
	
	# Add random variance (same as the original system)
	var variance = randf_range(1.0 - PhysicsConfig.ASTEROID_MASS_VARIANCE, 1.0 + PhysicsConfig.ASTEROID_MASS_VARIANCE)
	cached_mass = base_mass * variance

# Get the cached mass value
func get_mass() -> float:
	return cached_mass


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
