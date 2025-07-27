extends RichTextLabel

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
	
	# Create a more visually appealing score display - now the main indicator
	text = str(
		"[center]",
		"[font_size=24][color=#FEC15D]SCORE[/color][/font_size]\n",
		"[font_size=72][color=#FFFFF3]", score, "[/color][/font_size]",
		"[/center]"
	)
