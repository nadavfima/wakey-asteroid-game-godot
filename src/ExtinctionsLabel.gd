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
		add_theme_font_size_override("normal_font_size", 28)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	var remaining = 3
	if main_scene.has_method("get_mass_extinctions"):
		remaining = 3 - main_scene.massExtinctions
	
	# Create a more visually appealing extinctions display
	text = str(
		"[center]",
		"[font_size=18][color=#FEC15D]EXTINCTIONS[/color][/font_size]\n",
		"[font_size=18][color=#FEC15D]REMAINING[/color][/font_size]\n",
		"[font_size=48][color=#FFFFF3]", remaining, "[/color][/font_size]",
		"[/center]"
	)
	pass
