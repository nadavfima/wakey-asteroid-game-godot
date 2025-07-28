extends RichTextLabel

var extinctions_display: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up the RichTextLabel properties for better appearance
	bbcode_enabled = true
	scroll_active = false
	fit_content = true
	
	# Set custom font with larger size
	var font = load("res://assets/Fredoka-Bold.ttf")
	if font:
		add_theme_font_override("normal_font", font)
		add_theme_font_size_override("normal_font_size", 28)  # Increased from 20
	
	# Create the extinctions display
	extinctions_display = preload("res://src/ExtinctionsDisplay.gd").new()
	extinctions_display.position = Vector2(0, 35)  # Adjusted position for larger text
	add_child(extinctions_display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	var remaining = 3
	
	# Access the massExtinctions variable directly from MainScene
	if main_scene.has_method("get_mass_extinctions"):
		var extinctions = main_scene.get_mass_extinctions()
		remaining = 3 - extinctions
	else:
		# Try to access the variable directly
		var extinctions = main_scene.get("massExtinctions")
		print("Got extinctions via get(): ", extinctions)
		if extinctions == null:
			extinctions = 0
		remaining = 3 - extinctions
	
	
	# Update the Earth icons display
	if extinctions_display:
		extinctions_display.update_extinctions(remaining)
	
	# Create the visual extinctions display with larger, more prominent title
	var display_text = str(
		"[center]",
		"[font_size=20][color=#FEC15D]EXTINCTIONS[/color][/font_size]",  # Increased from 14
		"[/center]"
	)
	

	text = display_text
	# Force the RichTextLabel to update
	queue_redraw()
	pass
