extends VisibilityNotifier2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var wasEverOnScreen = false

signal asteroid_exit_screen

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if (!is_on_screen()):
		if (wasEverOnScreen):
			emit_signal("asteroid_exit_screen", get_parent().get_parent())
		pass

	if (is_on_screen()):
		wasEverOnScreen = true
		pass	
	pass
