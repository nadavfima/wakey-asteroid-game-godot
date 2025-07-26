extends Node2D

var color
var speed
#var x = 0.0
#var y = 0.0

		

func _draw():
	randomize()
#	color = Color(randf(), randf(), randf())
	color = Color(1,1,1, randf())
	draw_circle(Vector2(0, 0), 2, color)
