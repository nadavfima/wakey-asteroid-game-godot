extends CanvasLayer

signal start_game_requested

func _ready():
	# Connect the start button signal
	$Control/StartButton.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed():
	start_game_requested.emit() 
