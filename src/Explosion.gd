extends AnimatedSprite2D

func _ready():
	# Set up the animation frames
	var frames = SpriteFrames.new()
	frames.add_animation("explode")
	
	# Add all 9 explosion frames
	for i in range(1, 10):
		var texture = load("res://assets/Explosion/Explosion_" + str(i) + ".png")
		frames.add_frame("explode", texture)
	
	# Set the sprite frames
	sprite_frames = frames
	
	# Set animation speed to 9 FPS (9 frames over 1 second)
	frames.set_animation_speed("explode", 9)
	
	# Set animation to not loop
	frames.set_animation_loop("explode", false)
	
	# Scale the explosion down by 50%
	scale = Vector2(0.5, 0.5)
	
	# Connect the animation finished signal
	animation_finished.connect(_on_animation_finished)
	
	# Start the explosion animation (play once, no loop)
	play("explode")

func _on_animation_finished():
	# Remove the explosion when animation is complete
	queue_free() 