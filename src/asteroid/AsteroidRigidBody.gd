extends RigidBody2D

#var mainScene = load("res://src/MainScene.gd")

signal asteroid_hit_by_moon
signal asteroid_hit_by_asteroid
signal asteroid_hit_earth
signal asteroid_crazy_spin
signal asteroid_moon_hit_complete  # New signal for when moon hit sequence is complete

# Rotation tracking variables
var is_spinning_crazily = false
var rotation_since_crazy_spin = 0.0  # Track total rotation since entering crazy spin
var last_awarded_rotation = 0.0     # Track the last rotation where we awarded points

# Asteroid physics
var asteroid_mass: float = 1.0

# Visual feedback
var collision_flash_tween: Tween = null
var moon_hit_flash_tween: Tween = null  # New tween for moon hit flashing

func _init():
	angular_velocity = randf_range(PhysicsConfig.INITIAL_ANGULAR_VELOCITY_MIN, PhysicsConfig.INITIAL_ANGULAR_VELOCITY_MAX)
	var selected_range = PhysicsConfig.RANGE_MODERATE
	linear_velocity = Vector2(0.0, randf_range(selected_range[0], selected_range[1]))
	
	# Set random mass for more realistic physics
	asteroid_mass = randf_range(1.0 - PhysicsConfig.ASTEROID_MASS_VARIANCE, 1.0 + PhysicsConfig.ASTEROID_MASS_VARIANCE)
	mass = asteroid_mass

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
		_handle_moon_collision(body)
		emit_signal("asteroid_hit_by_moon", get_node("."))
	# If we hit another asteroid
	elif has_on_hit:
		print("Hit another asteroid!")
		_handle_asteroid_collision(body)
		emit_signal("asteroid_hit_by_asteroid", get_node("."))
	# If we hit Earth
	elif body.name == "earth":
		print("Hit Earth!")
		_handle_earth_collision(body)
		emit_signal("asteroid_hit_earth", get_node("."))
	else:
		print("Hit something else: ", body.name)

func _handle_moon_collision(moon_body):
	# Realistic moon collision - transfer momentum and add spin
	var collision_normal = (global_position - moon_body.global_position).normalized()
	
	# Since moon is a CharacterBody2D, we only consider the asteroid's velocity
	var relative_velocity = linear_velocity
	
	# Calculate momentum transfer with reduced elasticity for moon
	var impulse_magnitude = relative_velocity.length() * PhysicsConfig.MOON_COLLISION_ELASTICITY
	var impulse = collision_normal * impulse_magnitude
	
	# Apply impulse to asteroid (moon doesn't move due to physics)
	linear_velocity += impulse / mass
	
	# Add some velocity reduction to prevent flying off screen
	linear_velocity *= PhysicsConfig.MOON_VELOCITY_REDUCTION
	
	# Add angular velocity based on collision point
	var collision_point = global_position
	var radius_vector = collision_point - moon_body.global_position
	var tangential_force = radius_vector.cross(impulse)
	angular_velocity += tangential_force * PhysicsConfig.MOON_SPIN_SCALE_FACTOR
	
	# Add some randomness to make it more interesting
	angular_velocity += randf_range(PhysicsConfig.MOON_ANGULAR_BOOST_MIN, PhysicsConfig.MOON_ANGULAR_BOOST_MAX)
	
	# Mark asteroid as hit by moon and start flashing sequence
	var asteroid_node = get_parent()
	if asteroid_node.has_method("onHitByMoon"):
		asteroid_node.onHitByMoon()
		_start_moon_hit_flash_sequence()
	
	# Visual feedback for moon collision
	_add_collision_flash()

func _handle_asteroid_collision(other_asteroid):
	# Realistic asteroid-asteroid collision with momentum conservation
	var collision_normal = (global_position - other_asteroid.global_position).normalized()
	var relative_velocity = linear_velocity - other_asteroid.linear_velocity
	
	# Calculate collision response using elastic collision formulas
	var velocity_along_normal = relative_velocity.dot(collision_normal)
	
	if velocity_along_normal > 0:  # Only process if asteroids are moving toward each other
		var restitution = PhysicsConfig.COLLISION_ELASTICITY
		var impulse_magnitude = -(1 + restitution) * velocity_along_normal
		impulse_magnitude /= 1/mass + 1/other_asteroid.mass
		
		var impulse = collision_normal * impulse_magnitude
		
		# Apply impulse to both asteroids
		linear_velocity += impulse / mass
		other_asteroid.linear_velocity -= impulse / other_asteroid.mass
		
		# Add angular velocity based on collision geometry
		var radius_vector_self = global_position - other_asteroid.global_position
		var radius_vector_other = other_asteroid.global_position - global_position
		
		var tangential_force_self = radius_vector_self.cross(impulse)
		var tangential_force_other = radius_vector_other.cross(-impulse)
		
		angular_velocity += tangential_force_self * PhysicsConfig.ASTEROID_SPIN_SCALE_FACTOR
		other_asteroid.angular_velocity += tangential_force_other * PhysicsConfig.ASTEROID_SPIN_SCALE_FACTOR
		
		# Add some chaos factor for more interesting collisions
		angular_velocity += randf_range(PhysicsConfig.ASTEROID_ANGULAR_BOOST_MIN, PhysicsConfig.ASTEROID_ANGULAR_BOOST_MAX)
		other_asteroid.angular_velocity += randf_range(PhysicsConfig.ASTEROID_ANGULAR_BOOST_MIN, PhysicsConfig.ASTEROID_ANGULAR_BOOST_MAX)
		
		# Visual feedback for asteroid collision
		_add_collision_flash()
		other_asteroid._add_collision_flash()

func _handle_earth_collision(earth_body):
	# Earth collision - more dramatic physics
	var collision_normal = (global_position - earth_body.global_position).normalized()
	
	# Calculate impact force
	var impact_velocity = linear_velocity.length()
	var impact_force = impact_velocity * mass
	
	# Bounce off with reduced velocity (Earth is massive)
	linear_velocity = collision_normal * impact_velocity * PhysicsConfig.EARTH_ELASTICITY
	
	# Add dramatic spin based on impact
	var tangential_component = linear_velocity.cross(collision_normal)
	angular_velocity += tangential_component * PhysicsConfig.EARTH_SPIN_SCALE_FACTOR
	
	# Add some randomness for dramatic effect
	angular_velocity += randf_range(PhysicsConfig.EARTH_ANGULAR_BOOST_MIN, PhysicsConfig.EARTH_ANGULAR_BOOST_MAX)
	
	# Visual feedback for earth collision
	_add_collision_flash()

func _check_crazy_spin(delta):
	# Check if angular velocity exceeds the crazy spin threshold
	if abs(angular_velocity) >= PhysicsConfig.CRAZY_SPIN_THRESHOLD:
		if not is_spinning_crazily:
			is_spinning_crazily = true
			print("Asteroid entered crazy spin mode! Angular velocity: ", angular_velocity)
			_add_crazy_spin_visual_effect()
			# Reset rotation tracking when entering crazy spin
			rotation_since_crazy_spin = 0.0
			last_awarded_rotation = 0.0
		
		# Track rotation since entering crazy spin mode
		rotation_since_crazy_spin += abs(angular_velocity) * delta
		
		# Award points for every 360 degrees (2π radians) of rotation
		var rotations_completed = rotation_since_crazy_spin / (2 * PI)
		var rotations_since_last_award = rotations_completed - last_awarded_rotation
		
		if rotations_since_last_award >= 1.0:  # Award points for each complete rotation
			var points_to_award = int(rotations_since_last_award) * PhysicsConfig.SPIN_SCORE_INTERVAL
			# Bonus points for higher angular velocity
			var velocity_bonus = int(abs(angular_velocity) / 10.0)
			points_to_award += velocity_bonus
			emit_signal("asteroid_crazy_spin", get_node("."), points_to_award)
			last_awarded_rotation = rotations_completed
			print("Awarded ", points_to_award, " points for ", int(rotations_since_last_award), " complete rotation(s) + velocity bonus")
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

func _add_collision_flash():
	# Stop any existing flash
	if collision_flash_tween:
		collision_flash_tween.kill()
	
	collision_flash_tween = create_tween()
	
	# Find the sprite and flash it
	var collision_shape = get_node("CollisionShape2D")
	if collision_shape:
		for child in collision_shape.get_children():
			if child is Sprite2D:
				var original_color = child.modulate
				collision_flash_tween.tween_property(child, "modulate", Color(1.8, 0.8, 0.8, 1.0), PhysicsConfig.COLLISION_FLASH_DURATION * 0.5)
				collision_flash_tween.tween_property(child, "modulate", original_color, PhysicsConfig.COLLISION_FLASH_DURATION * 0.5)
				break

func _start_moon_hit_flash_sequence():
	# Stop any existing moon hit flash
	if moon_hit_flash_tween:
		moon_hit_flash_tween.kill()
	
	# Wait 2 seconds before starting the flash sequence
	await get_tree().create_timer(2.0).timeout
	
	# Check if asteroid is still valid after the delay
	if not is_instance_valid(self):
		return
	
	moon_hit_flash_tween = create_tween()
	
	# Find the sprite and start flashing
	var collision_shape = get_node("CollisionShape2D")
	if collision_shape:
		for child in collision_shape.get_children():
			if child is Sprite2D:
				var original_color = child.modulate
				
				# Flash for about 1 second (10 flashes of 0.1 seconds each)
				for i in range(10):
					moon_hit_flash_tween.tween_property(child, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.05)  # Bright white flash
					moon_hit_flash_tween.tween_property(child, "modulate", Color(0.3, 0.3, 0.3, 1.0), 0.05)  # Dim flash
				
				# After flashing, emit signal to remove the asteroid
				moon_hit_flash_tween.tween_callback(func(): 
					emit_signal("asteroid_moon_hit_complete", get_node("."))
				)
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
