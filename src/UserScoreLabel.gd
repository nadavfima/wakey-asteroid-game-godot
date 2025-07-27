extends RichTextLabel

# Animation variables
var previous_score = 0
var score_tween: Tween
var color_tween: Tween
var original_scale: Vector2
var original_color: Color

# Streak tracking variables
var streak_score = 0
var last_score_time = 0.0
var streak_timeout = 1.0  # Reset streak after 2 seconds of no scoring

# Sparkle variables
var sparkle_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up the RichTextLabel properties for better appearance
	bbcode_enabled = true
	scroll_active = false
	fit_content = true
	
	# Set custom font
	var font = load("res://assets/Fredoka-Bold.ttf")
	if font:
		add_theme_font_override("normal_font", font)
		add_theme_font_size_override("normal_font_size", 32)
	
	# Store original properties for animations
	original_scale = scale
	original_color = Color.WHITE
	
	# Initialize previous score
	var main_scene = get_parent().get_parent()
	if main_scene.has_method("get_user_score"):
		previous_score = main_scene.get_user_score()
	elif main_scene.has_method("userScore"):
		previous_score = main_scene.userScore
	else:
		# Try to access the variable directly
		previous_score = main_scene.get("userScore")
		if previous_score == null:
			previous_score = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	var score = 0
	
	# Access the userScore variable directly from MainScene
	if main_scene.has_method("get_user_score"):
		score = main_scene.get_user_score()
	elif main_scene.has_method("userScore"):
		score = main_scene.userScore
	else:
		# Try to access the variable directly
		score = main_scene.get("userScore")
		if score == null:
			score = 0
	
	# Check if score increased and trigger animations
	if score > previous_score:
		var score_increase = score - previous_score
		update_streak(score_increase)
		trigger_score_animations(score_increase)
		previous_score = score
	
	# Check for streak timeout
	if Time.get_unix_time_from_system() - last_score_time > streak_timeout and streak_score > 0:
		reset_streak()
	
	# Create a more visually appealing score display - now the main indicator
	text = str(
		"[center]",
		"[font_size=24][color=#FEC15D]SCORE[/color][/font_size]\n",
		"[font_size=72][color=#FFFFF3]", score, "[/color][/font_size]",
		"[/center]"
	)
	
	# Update pivot offset to center for proper scaling animation
	pivot_offset = size / 2

func update_streak(score_increase: int):
	# Update streak score and time
	streak_score += score_increase
	last_score_time = Time.get_unix_time_from_system()

func reset_streak():
	# Reset streak when timeout occurs
	streak_score = 0
	last_score_time = 0.0

func trigger_score_animations(score_increase: int):
	# Stop any existing tweens
	if score_tween:
		score_tween.kill()
	if color_tween:
		color_tween.kill()
	
	# Create new tweens
	score_tween = create_tween()
	color_tween = create_tween()
	
	# Scale bounce animation
	score_tween.set_parallel(true)
	score_tween.tween_property(self, "scale", original_scale * 1.3, 0.1)
	score_tween.tween_property(self, "scale", original_scale, 0.2).set_delay(0.1)
	
	# Color flash animation - using game's star colors based on streak
	color_tween.set_parallel(true)
	var flash_color = get_streak_color()
	color_tween.tween_property(self, "modulate", flash_color, 0.1)
	color_tween.tween_property(self, "modulate", original_color, 0.3).set_delay(0.1)
	
	# Create sparkles around the score
	create_sparkles(score_increase)
	
	# Create floating score text for larger increases
	if score_increase >= 10:
		create_floating_score_text(score_increase)

func get_streak_color() -> Color:
	# Choose color based on accumulated streak score
	var star_colors = [
		Color.WHITE,                 # White like game's star_color_1
		Color(0.145, 0.678, 1.0),  # Blue like game's star_color_2
		Color(1.0, 0.757, 0.0),    # Yellow like game's star_color_3
		Color(1.0, 0.220, 0.0),    # Orange like game's star_color_4
	]
	
	# Use different colors for different streak ranges
	var color_index = 0
	if streak_score >= 300:
		color_index = 3  # White for big streaks
	elif streak_score >= 200:
		color_index = 2  # Orange for medium-high streaks
	elif streak_score >= 100:
		color_index = 1  # Blue for medium streaks
	else:
		color_index = 0  # Yellow for smaller streaks
	
	return star_colors[color_index]

func create_sparkles(score_increase: int):
	# Create sparkles around the score display
	var sparkle_count = min(score_increase * 2, 12)  # More sparkles for bigger scores, max 12
	
	for i in range(sparkle_count):
		create_single_sparkle()

func create_single_sparkle():
	# Create a sparkle using a simple Label for better visibility
	var sparkle = Label.new()
	sparkle.name = "Sparkle"
	sparkle.text = "✦"  # Unicode star character
	sparkle.add_theme_font_size_override("font_size", 24)
	sparkle.modulate = Color(1.0, 0.757, 0.0, 1.0)  # Bright yellow
	
	# Calculate the center of the score display
	var score_center = global_position + size / 2
	
	# Position sparkle randomly around the score center
	var angle = randf() * 2 * PI
	var distance = randf_range(30, 80)
	var start_pos = score_center + Vector2(cos(angle) * distance, sin(angle) * distance)
	sparkle.position = start_pos
	
	# Add to the scene
	get_parent().add_child(sparkle)
	
	# Animate the sparkle
	var sparkle_tween = create_tween()
	sparkle_tween.set_parallel(true)
	
	# Move outward and fade
	var end_pos = start_pos + Vector2(cos(angle) * 100, sin(angle) * 100)
	sparkle_tween.tween_property(sparkle, "position", end_pos, 0.8)
	sparkle_tween.tween_property(sparkle, "modulate:a", 0.0, 0.8)
	
	# Scale animation
	sparkle_tween.tween_property(sparkle, "scale", Vector2(1.5, 1.5), 0.4)
	sparkle_tween.tween_property(sparkle, "scale", Vector2(0.5, 0.5), 0.4).set_delay(0.4)
	
	# Remove after animation
	sparkle_tween.tween_callback(sparkle.queue_free).set_delay(0.8)



func create_floating_score_text(score_increase: int):
	# Create a temporary label that floats up and fades out
	var floating_label = RichTextLabel.new()
	floating_label.bbcode_enabled = true
	floating_label.fit_content = true
	floating_label.text = str("+", score_increase)
	
	# Set the same font as the main score
	var font = load("res://assets/Fredoka-Bold.ttf")
	if font:
		floating_label.add_theme_font_override("normal_font", font)
		floating_label.add_theme_font_size_override("normal_font_size", 48)
	
	# Position it at the center of the score label
	var score_center = global_position + size / 2
	floating_label.position = score_center + Vector2(0, -50)
	
	# Use streak color for floating text
	floating_label.modulate = get_streak_color()
	
	# Add to the scene
	get_parent().add_child(floating_label)
	
	# Animate the floating text
	var float_tween = create_tween()
	float_tween.set_parallel(true)
	float_tween.tween_property(floating_label, "position:y", floating_label.position.y - 100, 1.0)
	float_tween.tween_property(floating_label, "modulate:a", 0.0, 1.0)
	float_tween.tween_property(floating_label, "scale", Vector2(1.5, 1.5), 0.5)
	float_tween.tween_property(floating_label, "scale", Vector2(1.0, 1.0), 0.5).set_delay(0.5)
	
	# Remove the floating label after animation
	float_tween.tween_callback(floating_label.queue_free).set_delay(1.0)
