extends RigidBody2D

#var mainScene = load("res://src/MainScene.gd")

signal asteroid_hit_by_moon
signal asteroid_hit_by_asteroid
signal asteroid_hit_earth
signal asteroid_crazy_spin

const range_easy = [600, 900]
const range_moderate = [900, 1200]
const range_hard = [1200, 1500]
const range_crazy = [1500, 2000]

# Rotation tracking variables
const CRAZY_SPIN_THRESHOLD = 20.0  # Angular velocity threshold for "crazy spin"
const SPIN_SCORE_INTERVAL = 5      # Points awarded per rotation when spinning crazily (integer)
var last_spin_score_time = 0.0
var is_spinning_crazily = false

func _init():
	angular_velocity = randf_range(-5, 5)
	var selected_range = range_moderate
	linear_velocity = Vector2(0.0, randf_range(selected_range[0], selected_range[1]))

func _ready():
	# Connect collision signals
	body_entered.connect(_on_body_entered)

func _process(delta):
	# Check for crazy spin and award points
	_check_crazy_spin(delta)
	
	pass

func _on_body_entered(body):
	print("Asteroid collision detected with: ", body.name, " (type: ", body.get_class(), ")")
	
	# Check if the body is a RigidBody2D and if its parent has the onHit method
	var has_on_hit = false
	if body is RigidBody2D and body.get_parent() != null:
		has_on_hit = body.get_parent().has_method("onHit")
		print("Body parent has onHit method: ", has_on_hit)
	
	# If we hit the moon
	if body.name == "Player":
		print("Hit Player!")
		emit_signal("asteroid_hit_by_moon", get_node("."))
	# If we hit another asteroid
	elif has_on_hit:
		print("Hit another asteroid!")
		emit_signal("asteroid_hit_by_asteroid", get_node("."))
	# If we hit Earth
	elif body.name == "earth":
		print("Hit Earth!")
		emit_signal("asteroid_hit_earth", get_node("."))
	else:
		print("Hit something else: ", body.name)

func _check_crazy_spin(delta):
	# Check if angular velocity exceeds the crazy spin threshold
	if abs(angular_velocity) >= CRAZY_SPIN_THRESHOLD:
		if not is_spinning_crazily:
			is_spinning_crazily = true
			print("Asteroid entered crazy spin mode! Angular velocity: ", angular_velocity)
			_add_crazy_spin_visual_effect()
		
		# Award points periodically while spinning crazily
		last_spin_score_time += delta
		if last_spin_score_time >= 0.5:  # Award points every 0.5 seconds while spinning
			emit_signal("asteroid_crazy_spin", get_node("."), SPIN_SCORE_INTERVAL)
			last_spin_score_time = 0.0
	else:
		if is_spinning_crazily:
			is_spinning_crazily = false
			print("Asteroid stopped crazy spinning. Angular velocity: ", angular_velocity)
			_remove_crazy_spin_visual_effect()

func _add_crazy_spin_visual_effect():
	# Add a visual effect to show the asteroid is spinning crazily
	var collision_shape = get_node("CollisionShape2D")
	if collision_shape:
		# Find the first Sprite2D child and add a pulsing effect
		for child in collision_shape.get_children():
			if child is Sprite2D:
				var tween = create_tween()
				tween.set_loops()  # Loop the animation
				tween.tween_property(child, "modulate", Color(1.8, 0.8, 0.8, 1.0), 0.3)  # Red glow
				tween.tween_property(child, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)  # Back to normal
				break

func _remove_crazy_spin_visual_effect():
	# Remove the visual effect when spinning stops
	var collision_shape = get_node("CollisionShape2D")
	if collision_shape:
		# Find the first Sprite2D child and reset its modulate
		for child in collision_shape.get_children():
			if child is Sprite2D:
				child.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Reset to normal
				break

# Function to handle Earth collision physics
func crash_into_earth():
	# Stop all movement
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Disable physics simulation to prevent bouncing
	freeze = true
	
	# Optional visual effect: slightly scale down the asteroid to show impact
	var collision_shape = get_node("CollisionShape2D")
	if collision_shape:
		# Find the first Sprite2D child (each asteroid has a different name like Asteroid1, Asteroid2, etc.)
		for child in collision_shape.get_children():
			if child is Sprite2D:
				var tween = create_tween()
				tween.tween_property(child, "scale", Vector2(0.8, 0.8), 0.2)
				break
	
	# Optionally, you can also disable collision detection
	# collision_layer = 0
	# collision_mask = 0
	
	pass
