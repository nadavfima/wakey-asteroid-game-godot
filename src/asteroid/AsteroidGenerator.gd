

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
				newAsteroid = Asteroid1.instance()
			2:
				newAsteroid = Asteroid2.instance()
			3:
				newAsteroid = Asteroid3.instance()
			4:
				newAsteroid = Asteroid4.instance()
			5:
				newAsteroid = Asteroid5.instance()
			6:
				newAsteroid = Asteroid6.instance()

		pass
		
		return newAsteroid
	pass
pass
