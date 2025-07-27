extends RigidBody2D

#var mainScene = load("res://src/MainScene.gd")

signal asteroid_hit_by_moon
signal asteroid_hit_by_asteroid
signal asteroid_hit_earth

const range_easy = [600, 900]
const range_moderate = [900, 1200]
const range_hard = [1200, 1500]
const range_crazy = [1500, 2000]

func _init():
	angular_velocity = randf_range(-5, 5)
	var selected_range = range_moderate
	linear_velocity = Vector2(0.0, randf_range(selected_range[0], selected_range[1]))

func _process(delta):
	
	#print("body process")
	for body in get_colliding_bodies():
		#if we hit the moon
		if body.name == "Player":
			emit_signal("asteroid_hit_by_moon", get_node("."))
		# If we hit another asteroid
		elif body.has_method("onHit"):
			emit_signal("asteroid_hit_by_asteroid", get_node("."))
		# If we hit Earth
		elif body.name == "earth":
			emit_signal("asteroid_hit_earth", get_node("."))
	
	pass

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
