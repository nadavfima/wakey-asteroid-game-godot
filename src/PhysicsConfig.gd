extends Node

# Physics configuration for realistic asteroid collisions
class_name PhysicsConfig

# Collision elasticity and friction
const DEFAULT_ELASTICITY = 0.7
const DEFAULT_FRICTION = 0.3
const EARTH_ELASTICITY = 0.2  # Earth is less bouncy
const MOON_ELASTICITY = 0.5   # Moon is more bouncy
const COLLISION_ELASTICITY = 0.3    # How bouncy collisions are (0-1) - reduced for less bounce
const MOON_COLLISION_ELASTICITY = 0.1  # Even less bouncy for moon collisions
const FRICTION_COEFFICIENT = 0.3    # How much velocity is lost in collisions

# Mass and size variations
const MASS_VARIANCE = 0.3
const SIZE_VARIANCE = 0.2
const ASTEROID_MASS_VARIANCE = 0.2  # Random mass variation for more realistic physics

# Angular velocity thresholds
const CRAZY_SPIN_THRESHOLD = 20.0
const SPIN_SCORE_INTERVAL = 5      # Points awarded per rotation when spinning crazily (integer)

# Collision force multipliers
const ASTEROID_COLLISION_FORCE = 1.0
const MOON_COLLISION_FORCE = 0.8
const EARTH_COLLISION_FORCE = 2.0

# Chain reaction settings
const CHAIN_REACTION_RADIUS = 200.0
const CHAIN_REACTION_BONUS_PER_ASTEROID = 2
const VELOCITY_BONUS_THRESHOLD = 1000.0
const ANGULAR_BONUS_THRESHOLD = 30.0

# Visual effect durations
const COLLISION_FLASH_DURATION = 0.2
const SPIN_TRAIL_DURATION = 0.5
const IMPACT_SHAKE_DURATION = 0.3

# Sound effect triggers
const MIN_COLLISION_VELOCITY_FOR_SOUND = 500.0
const MIN_ANGULAR_VELOCITY_FOR_SPIN_SOUND = 15.0

# Physics layers (if you want to set up collision layers)
const LAYER_ASTEROID = 1
const LAYER_MOON = 2
const LAYER_EARTH = 4

# Velocity ranges for asteroid generation
const RANGE_EASY = [600, 900]
const RANGE_MODERATE = [900, 1200]
const RANGE_HARD = [1200, 1500]
const RANGE_CRAZY = [1500, 2000]

# Angular velocity ranges
const INITIAL_ANGULAR_VELOCITY_MIN = -5
const INITIAL_ANGULAR_VELOCITY_MAX = 5

# Velocity reduction factors
const MOON_VELOCITY_REDUCTION = 0.8  # Reduce velocity by 20% after moon collision

# Angular velocity scale factors
const MOON_SPIN_SCALE_FACTOR = 0.01  # Scale factor for realistic spin from moon collision
const ASTEROID_SPIN_SCALE_FACTOR = 0.005  # Scale factor for asteroid-asteroid collision spin
const EARTH_SPIN_SCALE_FACTOR = 0.02  # Scale factor for earth collision spin

# Random angular velocity ranges for collisions
const MOON_ANGULAR_BOOST_MIN = -10
const MOON_ANGULAR_BOOST_MAX = 10
const ASTEROID_ANGULAR_BOOST_MIN = -15
const ASTEROID_ANGULAR_BOOST_MAX = 15
const EARTH_ANGULAR_BOOST_MIN = -20
const EARTH_ANGULAR_BOOST_MAX = 20

# Helper function to calculate collision force
static func calculate_collision_force(velocity: Vector2, mass: float, elasticity: float = DEFAULT_ELASTICITY) -> float:
	return velocity.length() * mass * elasticity

# Helper function to determine collision type
static func get_collision_type(velocity: Vector2, angular_velocity: float) -> String:
	if abs(angular_velocity) >= CRAZY_SPIN_THRESHOLD:
		return "crazy_spin"
	elif velocity.length() >= VELOCITY_BONUS_THRESHOLD:
		return "high_velocity"
	else:
		return "normal"

# Helper function to get color for collision type
static func get_collision_color(collision_type: String) -> Color:
	match collision_type:
		"crazy_spin":
			# red
			return Color(1.0, 0.0, 0.0, 1.0)
		"high_velocity":
			# yellow
			return Color(1.0, 1.0, 0.0, 1.0)
		_:
			return Color(1.0, 1.0, 1.0, 1.0)  # White 