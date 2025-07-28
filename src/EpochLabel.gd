extends RichTextLabel

var start_time: float = 0.0
var years_per_second: float = 1000000.0  # 1 million years per second of gameplay

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

func start_counting():
	start_time = Time.get_unix_time_from_system()

func stop_counting():
	# Reset to default display
	start_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	
	# Only count if we're in playing state
	if main_scene.current_state != main_scene.GameState.PLAYING:
		text = str(
			"[center]",
			"[font_size=20][color=#FEC15D]EPOCH[/color][/font_size]\n",  # Increased from 16
			"[font_size=40][color=#FFFFF3]13.8B[/color][/font_size]",  # Increased from 32
			"[/center]"
		)
		return
	
	# Calculate years since big bang
	var current_time = Time.get_unix_time_from_system()
	var elapsed_seconds = current_time - start_time
	var years = 13800000000 + (elapsed_seconds * years_per_second)  # Start from 13.8 billion years
	
	# Format the years display
	var years_text = ""
	if years >= 1000000000:
		years_text = str(int(years / 1000000000)) + "B"
	elif years >= 1000000:
		years_text = str(int(years / 1000000)) + "M"
	elif years >= 1000:
		years_text = str(int(years / 1000)) + "K"
	else:
		years_text = str(int(years))
	
	# Create a more visually appealing display with larger fonts
	text = str(
		"[center]",
		"[font_size=20][color=#FEC15D]EPOCH[/color][/font_size]\n",  # Increased from 16
		"[font_size=40][color=#FFFFF3]", years_text, "[/color][/font_size]",  # Increased from 32
		"[/center]"
	) 
