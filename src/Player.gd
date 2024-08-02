extends CharacterBody2D


var width = 800;

func _ready():
	set_process(true)
	pass
	
func _process(delta):
	_updateWakeyPositionAccordingToMouse(delta)
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		print("Collided with: ", collision.collider.name)

	
	pass

func _updateWakeyPositionAccordingToMouse(delta):
	
	var motion = (get_global_mouse_position().x - position.x) * 0.2
	var moonSize = 220
	var limit = width/2 - moonSize/2
	var newX = position.x + motion

	if (newX < limit && newX > -1 * limit):
		
		var xForFunc = newX - limit # 0-800 -> -400 -> 400
		
		var y = 0.0005 * (newX * newX)
		
		#print("new y is ", y)
		
		#translate(Vector2(motion, y))
		position.x = newX
		position.y = y
	else :
		if (newX > limit):
			position.x = limit;
		else:
			position.x = -1 * limit;

	pass
