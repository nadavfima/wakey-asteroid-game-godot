extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	if main_scene.has_method("get_mass_extinctions"):
		var remaining = 3 - main_scene.massExtinctions
		text = str("[center]","Extinctions Remaining\n", remaining,"[/center]")
	else:
		text = str("[center]","Extinctions Remaining\n", 3,"[/center]")
	pass
