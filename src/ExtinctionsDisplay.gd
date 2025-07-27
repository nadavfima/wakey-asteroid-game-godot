extends Control

var earth_texture: Texture2D
var earth_icons: Array[TextureRect] = []

func _ready():
	# Load the Earth texture
	earth_texture = load("res://assets/tiny_earth.png")
	
	# Create Earth icon containers
	for i in range(3):
		var earth_icon = TextureRect.new()
		earth_icon.texture = earth_texture
		earth_icon.custom_minimum_size = Vector2(48, 48)
		earth_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		earth_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Position the icons horizontally, centered
		# ExtinctionsLabel width is 200 pixels (250 - 50)
		# Total width for 3 icons with spacing: 3 * 48 + 2 * 12 = 168 pixels
		# Center offset: (200 - 168) / 2 = 16 pixels
		earth_icon.position.x = 16 + i * 60  # 60 pixels apart, centered within the label
		earth_icon.position.y = 10      # Closer to the title
		
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