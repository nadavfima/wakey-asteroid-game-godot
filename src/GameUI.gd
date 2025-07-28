extends Control

# References to child UI elements
@onready var user_score_label = $UserScoreLabel
@onready var extinctions_label = $ExtinctionsLabel
@onready var epoch_label = $EpochLabel

func _ready():
	# Initialize UI elements
	pass

func start_game():
	# Start the epoch counter
	epoch_label.start_counting()

func end_game():
	# Stop the epoch counter
	epoch_label.stop_counting()

func update_score(score: int):
	# Update the user score display
	user_score_label.update_score(score)

func update_extinctions(extinctions: int, max_extinctions: int):
	# Update the extinctions display
	extinctions_label.update_extinctions(extinctions, max_extinctions)

func get_user_score_label():
	return user_score_label

func get_extinctions_label():
	return extinctions_label

func get_epoch_label():
	return epoch_label 