

class AsteroidGenerator:

	var Asteroid1 = load("res://src/asteroid/Asteroid1.tscn")
	var Asteroid2 = load("res://src/asteroid/Asteroid2.tscn")
	var Asteroid3 = load("res://src/asteroid/Asteroid3.tscn")
	var Asteroid4 = load("res://src/asteroid/Asteroid4.tscn")
	var Asteroid5 = load("res://src/asteroid/Asteroid5.tscn")
	var Asteroid6 = load("res://src/asteroid/Asteroid6.tscn")
	

	func generateAsteroid():
		
		randomize()
		var randomAsteroid = randi() % 3 + 1
		
		#print("random asteroid ", randomAsteroid)
		
		var newAsteroid;
		match randomAsteroid:
			1:
				newAsteroid = Asteroid1.instantiate()
			2:
				newAsteroid = Asteroid2.instantiate()
			3:
				newAsteroid = Asteroid3.instantiate()
			4:
				newAsteroid = Asteroid4.instantiate()
			5:
				newAsteroid = Asteroid5.instantiate()
			6:
				newAsteroid = Asteroid6.instantiate()

		pass
		
		return newAsteroid
	pass
pass
