extends Control

var earth_texture: Texture2D
var earth_icons: Array[TextureRect] = []

func _ready():
	# Load the Earth texture
	earth_texture = load("res://assets/tiny_earth.png")
	
	# Create Earth icon containers with larger sizes
	for i in range(3):
		var earth_icon = TextureRect.new()
		earth_icon.texture = earth_texture
		earth_icon.custom_minimum_size = Vector2(64, 64)  # Increased from 48x48 to 64x64
		earth_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		earth_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Position the icons horizontally, properly centered
		# ExtinctionsLabel width is 200 pixels (250 - 50)
		# Icon size: 64x64 pixels
		# Spacing between icons: 16 pixels
		# Total width needed: 3 * 64 + 2 * 16 = 224 pixels
		# Since container is only 200 pixels, we need to adjust spacing
		# Available space: 200 - (3 * 64) = 200 - 192 = 8 pixels
		# Spacing between icons: 8 / 2 = 4 pixels
		# Starting position: (200 - 224) / 2 = -12, but we'll use 0 and adjust spacing
		var icon_spacing = 4  # Reduced spacing to fit within container
		earth_icon.position.x = i * (64 + icon_spacing)  # 64 pixels per icon + 4 pixels spacing
		earth_icon.position.y = 15      # Adjusted position for larger icons
		
		add_child(earth_icon)
		earth_icons.append(earth_icon)

func update_extinctions(remaining: int):
	# Update the visual state of Earth icons
	for i in range(3):
		if i < remaining:
			# Show active Earth icon
			earth_icons[i].modulate = Color.WHITE
		else:
			# Show faded Earth icon
			earth_icons[i].modulate = Color(0.3, 0.3, 0.3, 0.5) 