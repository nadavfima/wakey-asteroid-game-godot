extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var main_scene = get_parent().get_parent()
	if main_scene.has_method("get_user_score"):
		text = str("[center]","User Score\n", main_scene.userScore,"[/center]")
	else:
		text = str("[center]","User Score\n", 0,"[/center]")
	pass
