extends Node2D

var width: int
var height: int
var star = []; var num_star=100;
var cx: float; var cy: float;
var starNode = load("src/Star.tscn");

# Star movement control
var global_speed_multiplier = 0.0  # 0 = stopped, 1.0 = full speed
var target_speed_multiplier = 0.0  # Target speed we're transitioning to
var acceleration_rate = 1.0  # How fast to accelerate (speed per second)
var deceleration_rate = 2.0  # How fast to decelerate (speed per second)
var is_transitioning = false

func _ready():
	# Get the actual screen dimensions
	width = get_viewport_rect().size.x
	height = get_viewport_rect().size.y
	cx = width / 2.0
	cy = height / 2.0
	
	print("Stars: Initial dimensions - Width: ", width, ", Height: ", height)
	
	# Connect to viewport size changed signal
	var viewport = get_viewport()
	print("Stars: Connecting to viewport size_changed signal...")
	viewport.size_changed.connect(_on_viewport_size_changed)
	print("Stars: Signal connected successfully")
	
	set_process(true)
	# Start with 100 stars for menu
	create_stars(100)

func _on_viewport_size_changed():
	# Update dimensions when screen size changes
	var new_width = get_viewport_rect().size.x
	var new_height = get_viewport_rect().size.y
	
	print("Stars: New dimensions - Width: ", new_width, ", Height: ", new_height)
	print("Stars: Old dimensions - Width: ", width, ", Height: ", height)
	
	# Only update if dimensions actually changed
	if new_width != width or new_height != height:
		print("Stars: Dimensions changed, updating...")
		var old_width = width  # Store old width before updating
		var old_height = height  # Store old height before updating
		
		width = new_width
		height = new_height
		cx = width / 2.0
		cy = height / 2.0
		
		# Redistribute existing stars to fit the new screen size
		redistribute_stars_for_resize(old_width, old_height)
		print("Stars: Redistribution complete")
	else:
		print("Stars: Dimensions unchanged, skipping update")

func create_stars(count: int):
	print("Stars: Creating ", count, " stars...")
	for n in range(count):
		var new_star = starNode.instantiate()
		# Better initial distribution across the entire screen
		new_star.position.x = randf_range(-width/2.0, width/2.0)
		new_star.position.y = randf_range(-100.0, height + 100.0)  # Spread across full height
		new_star.speed = randf_range(3,6)
		add_child(new_star)
		star.append(new_star)
		
		# Log first few stars to understand positioning
		if n < 5:
			print("Stars: Created star ", n, " at position (", new_star.position.x, ", ", new_star.position.y, ")")
	
	print("Stars: Created ", count, " stars with width range: ", -width/2.0, " to ", width/2.0)

func redistribute_stars_for_resize(old_width: float, old_height: float):
	# Redistribute stars to fit the new screen dimensions
	print("Stars: Starting redistribution for resize...")
	print("Stars: Old bounds - X: ", -old_width/2.0, " to ", old_width/2.0)
	print("Stars: New bounds - X: ", -width/2.0, " to ", width/2.0)
	var stars_moved = 0
	
	for n in range(star.size()):
		if star[n] != null:
			var original_x = star[n].position.x
			var original_y = star[n].position.y
			
			# Calculate relative position (0.0 = left edge, 1.0 = right edge)
			var relative_x = (original_x + old_width/2.0) / old_width
			var relative_y = (original_y + 100.0) / (old_height + 200.0)
			
			# Apply relative position to new screen dimensions
			var new_x = (relative_x * width) - width/2.0
			var new_y = (relative_y * (height + 200.0)) - 100.0
			
			# Only move if the position actually changed
			if abs(new_x - original_x) > 1.0 or abs(new_y - original_y) > 1.0:
				star[n].position.x = new_x
				star[n].position.y = new_y
				stars_moved += 1
				print("Stars: Star ", n, " moved from (", original_x, ", ", original_y, ") to (", new_x, ", ", new_y, ")")
	
	print("Stars: Redistributed ", stars_moved, " stars for new screen size")

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
			star[n].position.x = randf_range(-width/2.0, width/2.0)
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
				star[n].position.x = randf_range(-width/2.0, width/2.0)
	
	
