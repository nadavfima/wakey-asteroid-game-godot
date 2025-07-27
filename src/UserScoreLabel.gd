extends RichTextLabel

# Animation variables
var previous_score = 0
var score_tween: Tween
var color_tween: Tween
var original_scale: Vector2
var original_color: Color

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
		trigger_score_animations(score - previous_score)
		previous_score = score
	
	# Create a more visually appealing score display - now the main indicator
	text = str(
		"[center]",
		"[font_size=24][color=#FEC15D]SCORE[/color][/font_size]\n",
		"[font_size=72][color=#FFFFF3]", score, "[/color][/font_size]",
		"[/center]"
	)
	
	# Update pivot offset to center for proper scaling animation
	pivot_offset = size / 2

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
	
	# Color flash animation
	color_tween.set_parallel(true)
	color_tween.tween_property(self, "modulate", Color(1.5, 1.5, 0.5, 1.0), 0.1)
	color_tween.tween_property(self, "modulate", original_color, 0.3).set_delay(0.1)
	
	# Create floating score text for larger increases
	if score_increase >= 10:
		create_floating_score_text(score_increase)

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
	
	# Position it at the score label position
	floating_label.position = global_position + Vector2(0, -50)
	floating_label.modulate = Color(1.0, 1.0, 0.5, 1.0)
	
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
