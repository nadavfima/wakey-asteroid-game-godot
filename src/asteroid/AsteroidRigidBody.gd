extends RigidBody2D

#var mainScene = load("res://src/MainScene.gd")

signal asteroid_hit_by_moon
signal asteroid_hit_by_asteroid
signal asteroid_hit_earth

const range_easy = [600, 900]
const range_moderate = [900, 1200]
const range_hard = [1200, 1500]
const range_crazy = [1500, 2000]

func _init():
	angular_velocity = randf_range(-5, 5)
	var selected_range = range_moderate
	linear_velocity = Vector2(0.0, randf_range(selected_range[0], selected_range[1]))

func _process(delta):
	
	#print("body process")
	for body in get_colliding_bodies():
		#if we hit the moon
		if body.name == "Player":
			emit_signal("asteroid_hit_by_moon", get_node("."))
		# If we hit another asteroid
		elif body.has_method("onHit"):
			emit_signal("asteroid_hit_by_asteroid", get_node("."))
		# If we hit Earth
		elif body.name == "earth":
			emit_signal("asteroid_hit_earth", get_node("."))
	
	pass
pass
