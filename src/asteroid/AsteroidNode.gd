extends Node2D

var hitCount = 0
var wasHit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func onHit():
	hitCount += 1
	wasHit = true
