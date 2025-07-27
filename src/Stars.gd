extends Node2D

var width = 720; var height = 1280;
var star = []; var num_star=100;
var cx = width / 2; var cy = height/2;
var starNode = load("src/Star.tscn");

# Star movement control
var global_speed_multiplier = 0.0  # 0 = stopped, 1.0 = full speed
var target_speed_multiplier = 0.0  # Target speed we're transitioning to
var acceleration_rate = 1.0  # How fast to accelerate (speed per second)
var deceleration_rate = 2.0  # How fast to decelerate (speed per second)
var is_transitioning = false

func _ready():
	set_process(true)
	# Start with 100 stars for menu
	create_stars(100)
	
func create_stars(count: int):
	for n in range(count):
		var new_star = starNode.instantiate()
		# Better initial distribution across the entire screen
		new_star.position.x = randf_range(-360.0, 360.0)
		new_star.position.y = randf_range(-100.0, height + 100.0)  # Spread across full height
		new_star.speed = randf_range(3,6)
		add_child(new_star)
		star.append(new_star)
	
func start_game():
	# Start accelerating stars to full speed
	target_speed_multiplier = 1.0
	is_transitioning = true
	# Add 100 more stars for gameplay
	create_stars(100)
	# Redistribute all stars to ensure good coverage when game starts
	redistribute_stars()

func end_game():
	# Start decelerating stars to stop
	target_speed_multiplier = 0.0
	is_transitioning = true
	# Remove extra stars (keep only first 100)
	remove_extra_stars()

func remove_extra_stars():
	# Remove stars beyond the first 100 (menu stars)
	while star.size() > 100:
		var last_star = star.pop_back()
		if last_star != null:
			last_star.queue_free()

func redistribute_stars():
	# Redistribute stars across the screen for better coverage
	for n in range(star.size()):
		if star[n] != null:
			star[n].position.x = randf_range(-360.0, 360.0)
			star[n].position.y = randf_range(-100.0, height + 100.0)

func _process(delta):
	# Handle speed transitions
	if is_transitioning:
		if target_speed_multiplier > global_speed_multiplier:
			# Accelerating
			global_speed_multiplier = min(global_speed_multiplier + acceleration_rate * delta, target_speed_multiplier)
		else:
			# Decelerating
			global_speed_multiplier = max(global_speed_multiplier - deceleration_rate * delta, target_speed_multiplier)
		
		# Check if transition is complete
		if abs(global_speed_multiplier - target_speed_multiplier) < 0.01:
			global_speed_multiplier = target_speed_multiplier
			is_transitioning = false
	
	# Update star positions (downward movement)
	for n in range(star.size()):
		if star[n] != null:
			# Apply global speed multiplier to individual star speed
			var effective_speed = star[n].speed * global_speed_multiplier
			star[n].position.y += effective_speed
			
			# Reset star position when it goes off screen
			if star[n].position.y > height:
				star[n].position.y = randf_range(-100.0, 0.0)
				star[n].position.x = randf_range(-360.0, 360.0)
	
	
