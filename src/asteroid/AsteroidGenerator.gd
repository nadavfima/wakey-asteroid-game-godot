

class AsteroidGenerator:

	static var next_asteroid_id = 1

	var Asteroid1 = load("res://src/asteroid/Asteroid1.tscn")
	var Asteroid2 = load("res://src/asteroid/Asteroid2.tscn")
	var Asteroid3 = load("res://src/asteroid/Asteroid3.tscn")
	var Asteroid4 = load("res://src/asteroid/Asteroid4.tscn")
	var Asteroid5 = load("res://src/asteroid/Asteroid5.tscn")
	var Asteroid6 = load("res://src/asteroid/Asteroid6.tscn")
	var Asteroid7 = load("res://src/asteroid/Asteroid7.tscn")
	var Asteroid8 = load("res://src/asteroid/Asteroid8.tscn")
	var Asteroid9 = load("res://src/asteroid/Asteroid9.tscn")
	var Asteroid10 = load("res://src/asteroid/Asteroid10.tscn")
	var Asteroid11 = load("res://src/asteroid/Asteroid11.tscn")
	

	func generateAsteroid():
		
		randomize()
		var randomAsteroid = randi() % 11 + 1
		
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
			7:
				newAsteroid = Asteroid7.instantiate()
			8:
				newAsteroid = Asteroid8.instantiate()
			9:
				newAsteroid = Asteroid9.instantiate()
			10:
				newAsteroid = Asteroid10.instantiate()
			11:
				newAsteroid = Asteroid11.instantiate()

		# Assign unique ID to the asteroid
		newAsteroid.asteroid_id = next_asteroid_id
		next_asteroid_id += 1
		
		pass
		
		return newAsteroid
	pass
pass
