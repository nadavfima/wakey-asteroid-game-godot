extends CanvasLayer

signal restart_game_requested
signal main_menu_requested

func _ready():
	# Connect the button signals
	$Control/VBoxContainer/RestartButton.pressed.connect(_on_restart_button_pressed)
	$Control/VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_button_pressed)

func _on_restart_button_pressed():
	restart_game_requested.emit()

func _on_main_menu_button_pressed():
	main_menu_requested.emit()

func update_final_score(score: int):
	$Control/VBoxContainer/ScoreLabel.text = "[font_size=60][color=#FEC15D]Final Score:[/color] [color=#FFFFF3]" + str(score) + "[/color][/font_size]" 
