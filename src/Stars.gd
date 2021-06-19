extends Node2D

var width = 720; var height = 1280;
var star = []; var num_star=200;
#var speed = 4;
var cx = width / 2; var cy = height/2;
var starNode = load("src/Star.tscn");
#var font = [];
func _ready():
	set_process(true)
	for n in range (num_star):
		#star.append(SetPos())
		star.append(starNode.instance())
		star[n].position.x = rand_range(-360.0, 360.0)
		star[n].position.y = rand_range(0, 1280);
		star[n].speed = rand_range(3,6)
		add_child(star[n])
	
func DrawStar(n):
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
	star[n].position.y += star[n].speed;

#	star[n].translate(Vector2(0, speed))
	#font[n].apply_scale(Vector2(size.x, size.y))
	
	#star[n].global_translate(Vector2(0, speed))
	
func _process(delta):
	for n in range(num_star):
		DrawStar(n)
		update()
	
	
