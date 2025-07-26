extends Node2D

var width = 720; var height = 1280;
var star = []; var num_star=200;
#var speed = 4;
var cx = width / 2; var cy = height/2;
var starNode = load("src/Star.tscn");
#var font = [];

# Star movement control
var global_speed_multiplier = 0.0  # 0 = stopped, 1.0 = full speed
var target_speed_multiplier = 0.0  # Target speed we're transitioning to
var acceleration_rate = 1.0  # How fast to accelerate (speed per second)
var deceleration_rate = 2.0  # How fast to decelerate (speed per second)
var is_transitioning = false

func _ready():
	set_process(true)
	for n in range (num_star):
		#star.append(SetPos())
		star.append(starNode.instantiate())
		star[n].position.x = randf_range(-360.0, 360.0)
		star[n].position.y = randf_range(0, 1280);
		star[n].speed = randf_range(3,6)
		add_child(star[n])
	
func start_game():
	# Start accelerating stars to full speed
	target_speed_multiplier = 1.0
	is_transitioning = true

func end_game():
	# Start decelerating stars to stop
	target_speed_multiplier = 0.0
	is_transitioning = true

func DrawStar(n, delta):
	if (star[n].position.y > height):
		star[n].position.y = 0.0
	#if star[n].z < speed : star[n] = SetPos()
	#star[n].z -= speed
	#var sx = (star[n].x*spread) / (star[n].z + cx)
	#var sy = (star[n].y*spread) / (star[n].z + cy)
	#if (sx < 0 or sx > width): star[n] = SetPos()
	#if (sy < 0 or sy > height): star[n] = SetPos()
	#var size = Vector2(3,3)
	
	#var sx = star[n].x;
	
	
	#print(star[n].y)
	
	#star[n].x += sx;
	#star[n].y += speed;
	
	# Apply global speed multiplier to individual star speed
	var effective_speed = star[n].speed * global_speed_multiplier
	star[n].position.y += effective_speed

#	star[n].translate(Vector2(0, speed))
	#font[n].apply_scale(Vector2(size.x, size.y))
	
	#star[n].global_translate(Vector2(0, speed))
	
func _process(delta):
	# Handle speed transitions
	if is_transitioning:
		if target_speed_multiplier > global_speed_multiplier:
			# Accelerating
			global_speed_multiplier = min(global_speed_multiplier + acceleration_rate * delta, target_speed_multiplier)
		else:
			# Decelerating
			global_speed_multiplier = max(global_speed_multiplier - deceleration_rate * delta, target_speed_multiplier)
		
		# Check if transition is complete
		if abs(global_speed_multiplier - target_speed_multiplier) < 0.01:
			global_speed_multiplier = target_speed_multiplier
			is_transitioning = false
	
	# Update star positions
	for n in range(num_star):
		DrawStar(n, delta)
		queue_redraw()
	
	
