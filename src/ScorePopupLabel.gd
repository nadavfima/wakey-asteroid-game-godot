extends RichTextLabel

var tween: Tween
var current_text: String = ""
var current_color: Color = Color.WHITE
var total_score: int = 0
var fade_timer: SceneTreeTimer

func _ready():
	# Set up the label properties
	bbcode_enabled = true
	scroll_active = false
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Start invisible
	modulate.a = 0.0
	
	# Set up the font
	var font = preload("res://assets/Fredoka-Bold.ttf")
	add_theme_font_override("normal_font", font)
	add_theme_font_size_override("normal_font_size", 32)

func update_score(new_score: int):
	# Accumulate the score
	total_score += new_score
	
	# Update the display text with the accumulated score
	var display_text = current_text
	if total_score > 0:
		display_text = "+" + str(total_score) + " " + current_text
	
	# Update the text with color
	self.text = "[color=" + current_color.to_html(false) + "]" + display_text + "[/color]"
	
	# Create a small animation to show the update
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Quick scale animation to show the update
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Reset the fade-out timer to keep the popup visible longer
	if fade_timer:
		fade_timer.timeout.disconnect(_on_fade_timer_timeout)
		fade_timer = null
	
	# Create a new fade timer
	fade_timer = get_tree().create_timer(2.0)
	fade_timer.timeout.connect(_on_fade_timer_timeout)

func _on_fade_timer_timeout():
	# Start the fade out animation
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5)
	await fade_tween.finished
	
	# Reset scale and clean up
	scale = Vector2(1.0, 1.0)
	queue_free()

func show_popup(text: String, score: int = 0, color: Color = Color.WHITE, duration: float = 2.0, asteroid_position: Vector2 = Vector2.ZERO):
	# Store the base text and color for potential updates
	current_text = text
	current_color = color
	total_score = score  # Initialize total score
	
	# Format the text with score if provided
	var display_text = text
	if score > 0:
		display_text = "+" + str(score) + " " + text
	
	# Set the text with color
	self.text = "[color=" + color.to_html(false) + "]" + display_text + "[/color]"
	
	# Position at asteroid location if provided, otherwise use random position
	if asteroid_position != Vector2.ZERO:
		position = asteroid_position
	else:
		# Fallback to random positioning
		var viewport_size = get_viewport_rect().size
		var random_x = randf_range(100, viewport_size.x - 100)
		var random_y = randf_range(200, viewport_size.y - 200)
		position = Vector2(random_x, random_y)
	
	# Create tween for animation
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade in
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Scale up with bounce effect
	scale = Vector2(0.5, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Move up slightly
	var start_pos = position
	var end_pos = position + Vector2(0, -50)
	tween.parallel().tween_property(self, "position", end_pos, duration)
	
	# Set up the fade timer
	fade_timer = get_tree().create_timer(duration + 0.5)
	fade_timer.timeout.connect(_on_fade_timer_timeout) 
