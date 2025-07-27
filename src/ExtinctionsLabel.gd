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
		add_theme_font_size_override("normal_font_size", 20)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	var remaining = 3
	
	# Access the massExtinctions variable directly from MainScene
	if main_scene.has_method("get_mass_extinctions"):
		var extinctions = main_scene.get_mass_extinctions()
		remaining = 3 - extinctions
	elif main_scene.has_method("massExtinctions"):
		remaining = 3 - main_scene.massExtinctions
	else:
		# Try to access the variable directly
		var extinctions = main_scene.get("massExtinctions")
		if extinctions == null:
			extinctions = 0
		remaining = 3 - extinctions
	
	# Create a more visually appealing extinctions display - now a secondary indicator
	text = str(
		"[center]",
		"[font_size=14][color=#FEC15D]EXTINCTIONS[/color][/font_size]\n",
		"[font_size=14][color=#FEC15D]LEFT[/color][/font_size]\n",
		"[font_size=36][color=#FFFFF3]", remaining, "[/color][/font_size]",
		"[/center]"
	)
	pass
