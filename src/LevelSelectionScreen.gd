extends CanvasLayer

signal level_selected(level_number: int)
signal back_to_title_requested

var level_buttons = []
var total_levels = 3  # Default to 3 levels, will be updated

func _ready():
	# Get all level buttons
	level_buttons = [
		$Control/VBoxContainer/LevelGrid/Level1Button,
		$Control/VBoxContainer/LevelGrid/Level2Button,
		$Control/VBoxContainer/LevelGrid/Level3Button,
		$Control/VBoxContainer/LevelGrid/Level4Button,
		$Control/VBoxContainer/LevelGrid/Level5Button,
		$Control/VBoxContainer/LevelGrid/Level6Button,
		$Control/VBoxContainer/LevelGrid/Level7Button,
		$Control/VBoxContainer/LevelGrid/Level8Button,
		$Control/VBoxContainer/LevelGrid/Level9Button
	]
	
	# Connect all level button signals
	for i in range(level_buttons.size()):
		var button = level_buttons[i]
		button.pressed.connect(_on_level_button_pressed.bind(i + 1))
	
	# Connect back button
	$Control/VBoxContainer/BackButton.pressed.connect(_on_back_button_pressed)
	
	# Update available levels
	update_available_levels()

func update_available_levels():
	# Get the total number of available levels from the level manager
	if LevelManager.instance:
		total_levels = LevelManager.instance.get_total_levels()
	
	# Enable/disable buttons based on available levels
	for i in range(level_buttons.size()):
		var button = level_buttons[i]
		var level_number = i + 1
		
		if level_number <= total_levels:
			button.disabled = false
			button.modulate = Color.WHITE
		else:
			button.disabled = true
			button.modulate = Color(0.5, 0.5, 0.5, 0.5)

func _on_level_button_pressed(level_number: int):
	print("Level ", level_number, " selected")
	level_selected.emit(level_number)

func _on_back_button_pressed():
	print("Back to title requested")
	back_to_title_requested.emit() 
