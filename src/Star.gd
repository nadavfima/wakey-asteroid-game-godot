extends Node2D

# Star properties
var star_type: String = "tiny"  # "tiny", "roundy", "shiny", "twinkling"
var star_color: Color
var star_size: float
var speed: float

# Animation properties
var alpha_double: float = 0.0
var multiplier_factor: int = 1
var increment_factor: float
var parallax_factor: float

# Twinkling properties (for twinkling stars)
var twinkle_duration: int
var twinkle_alpha: float = 1.0

# Star colors matching Kotlin version
var star_colors = [
	Color.WHITE,           # star_color_1
	Color(0.145, 0.678, 1.0),  # star_color_2 (#25ADFF)
	Color(1.0, 0.757, 0.0),    # star_color_3 (#FFC100)
	Color(1.0, 0.220, 0.0)     # star_color_4 (#FF3800)
]

func _ready():
	# Initialize star properties
	setup_star()

func setup_star():
	# Set random star size (matching Kotlin constraints)
	var min_size = 1.0
	var max_size = 12.0
	var big_star_threshold = 8.0
	star_size = min_size + randf() * (max_size - min_size)
	parallax_factor = star_size / 2.0
	
	# Choose star color with bias towards white (matching Kotlin star_colors_small ratio)
	var color_weights = [4, 1, 1]  # 4 white, 1 blue, 1 yellow (no orange for small stars)
	var total_weight = 6
	var rand = randi() % total_weight
	
	if rand < 4:
		star_color = star_colors[0]  # White
	elif rand < 5:
		star_color = star_colors[1]  # Blue
	else:
		star_color = star_colors[2]  # Yellow
	
	# Determine star type with bias towards smaller stars
	var size_rand = randf()
	if star_size >= big_star_threshold:
		# Big stars - mostly tiny white stars, some colored variants
		if size_rand < 0.6:
			star_type = "tiny"
			increment_factor = randf() * 0.045
		elif size_rand < 0.8:
			star_type = "shiny"
			increment_factor = randf() * 0.030
		elif size_rand < 0.9:
			star_type = "twinkling"
			increment_factor = randf() * 0.045
			twinkle_duration = randi_range(500, 2000)
		else:
			star_type = "roundy"
			increment_factor = randf() * 0.025
	else:
		# Small stars - mostly tiny white stars, some twinkling
		if size_rand < 0.7:
			star_type = "tiny"
			increment_factor = randf() * 0.045
		else:
			star_type = "twinkling"
			increment_factor = randf() * 0.045
			twinkle_duration = randi_range(500, 2000)

func _process(delta):
	calculate_frame()
	queue_redraw()

func calculate_frame():
	# Calculate alpha animation (matching Kotlin BaseStar logic)
	if alpha_double > 1.0:
		multiplier_factor *= -1
	
	alpha_double += increment_factor * multiplier_factor
	
	if alpha_double < 0.0:
		# Reset star when it fades out completely
		reset_star()
		return
	
	# Handle twinkling animation for twinkling stars
	if star_type == "twinkling":
		# Check if game is active (stars are moving)
		var game_active = false
		if get_parent() and get_parent().global_speed_multiplier > 0.1:
			game_active = true
		
		if game_active:
			# Slow down twinkling during gameplay (1/4 speed)
			var time = Time.get_time_dict_from_system()
			var time_ms = time.hour * 3600000 + time.minute * 60000 + time.second * 1000 + time.get("millisecond", 0)
			var slow_duration = twinkle_duration * 4  # 4x slower
			var sine_input = 2.0 * PI * (time_ms % slow_duration) / slow_duration
			twinkle_alpha = 0.5 * (1.0 + sin(sine_input))
			twinkle_alpha *= alpha_double
		else:
			# Normal twinkling speed in menu
			var time = Time.get_time_dict_from_system()
			var time_ms = time.hour * 3600000 + time.minute * 60000 + time.second * 1000 + time.get("millisecond", 0)
			var sine_input = 2.0 * PI * (time_ms % twinkle_duration) / twinkle_duration
			twinkle_alpha = 0.5 * (1.0 + sin(sine_input))
			twinkle_alpha *= alpha_double

func reset_star():
	# Reset star to start a new animation cycle
	alpha_double = 0.0
	multiplier_factor = 1
	
	# Don't reposition here - let Stars.gd handle repositioning when star goes off screen
	# This prevents stars from resetting position mid-movement

func get_alpha_int() -> int:
	if star_type == "twinkling":
		return int(clamp(twinkle_alpha * 255.0, 0.0, 255.0))
	else:
		return int(clamp(alpha_double * 255.0, 0.0, 255.0))

func _draw():
	var alpha = get_alpha_int()
	var draw_color = Color(star_color.r, star_color.g, star_color.b, alpha / 255.0)
	
	match star_type:
		"tiny":
			draw_tiny_star(draw_color)
		"roundy":
			draw_roundy_star(draw_color)
		"shiny":
			draw_shiny_star(draw_color)
		"twinkling":
			draw_twinkling_star(draw_color)

func draw_tiny_star(color: Color):
	# Simple filled circle - make it smaller for better proportion
	var draw_size = max(0.5, star_size / 3.0)  # Scale down the size
	draw_circle(Vector2.ZERO, draw_size, color)

func draw_roundy_star(color: Color):
	# Circle outline (stroke style) - scale down for smaller appearance
	var draw_size = max(0.5, star_size / 3.0)
	var stroke_width = max(0.5, draw_size / 4.0)
	draw_arc(Vector2.ZERO, draw_size, 0, 2 * PI, 16, color, stroke_width)

func draw_shiny_star(color: Color):
	# Cross shape with horizontal and vertical rectangles - scale down
	var draw_size = max(0.5, star_size / 3.0)
	var h_rect = Rect2(-draw_size, -draw_size / 6.0, draw_size * 2, draw_size / 3.0)
	var v_rect = Rect2(-draw_size / 6.0, -draw_size, draw_size / 3.0, draw_size * 2)
	
	draw_rect(h_rect, color)
	draw_rect(v_rect, color)

func draw_twinkling_star(color: Color):
	# Same as shiny star but with twinkling alpha
	draw_shiny_star(color)
