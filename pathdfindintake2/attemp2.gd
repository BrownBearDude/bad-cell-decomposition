extends Node2D

var shapes = []
var all_points = []

var new_connections = []

var cells = [[]]

var hsdr

func _draw():
	for num in range(0, new_connections.size(), 2):
		draw_line(new_connections[num], new_connections[num+1], Color.red, 10)
	for num in range(0, cells.size()):
		for num_2 in range(1, cells[num].size()):
			draw_line(cells[num][num_2], cells[num][num_2-1], Color.blue, 10)

func _ready():
	#get shapes from collisions, not a long term solution but during development it's good. 
	#will need to be made editable in runtime eventaully, but that's months away.
	for shape in range(0, self.get_child_count()):
		shapes.append(self.get_child(shape).polygon)
		all_points.append(shapes[shape])

	var angles = []
	var concave_angles = []

	#find relevant angles, main shape - internal, holes - external
	for num in range(0, shapes.size()):
		for num_2 in range(0, shapes[num].size()):
			#individaul points in shape
			var current = shapes[num][num_2]
			var a = num_2+1; if a > shapes[num].size()-1: a = 0; a = shapes[num][a]; a = a - current
			var b = num_2-1; if b < 0: b = shapes[num].size()-1; b = shapes[num][b]; b = b - current
			var angle = atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y) #beautiful math thing
			if angle < 0: angle = (2 * PI) + angle
			if !(num == 0): angle = (2 * PI) - angle 
			if angle > PI: concave_angles.append([angle, shapes[num][num_2], num])
			angles.append([angle, shapes[num][num_2], num])
	
	
	############################



	#hmm, smooth buttery code, lovely, may refactor anyway.
	#slight bit of repitition, 2 instances of the same 4 lines. 
	#code make it so that it "eliminates" instead of current thing
	for num in range(0, concave_angles.size()):
		var current = concave_angles[num].duplicate()
		var highscore = pow(2, 64) - 1
		var highscore_point
		for num_2 in range(0, angles.size()):
			var current_2 = angles[num_2].duplicate()
			if current[1] != current_2[1]:
				if current[2] == current_2[2]:
					if concave_angles.has(current_2):
						var angle_between = current[0] + current_2[0]
						for num_3 in range(num, num_2): angle_between -= angles[num_3][0]
						if current_2[2] != 0: if !(angle_between > 0):
							continue
						elif !(angle_between <= 0): 
							continue
						var distance = current[1].distance_squared_to(current_2[1]) #distance_squared_to slightly faster
						if distance < highscore:
							highscore = distance
							highscore_point = current_2
				else:
					var no_collisions = true
					for num in range(0, new_connections.size(), 2):
						var collisions = Geometry.segment_intersects_segment_2d(new_connections[num], new_connections[num+1], current[1], current_2[1])
						if collisions != null: if !(collisions == current[1] or collisions == current_2[1]):
							no_collisions = false
					if no_collisions:
						var distance = current[1].distance_squared_to(current_2[1])
						if distance < highscore:
							highscore = distance
							highscore_point = current_2
		new_connections.append(current[1])
		new_connections.append(highscore_point[1])

	####################
	
	
#	#hot code, yummy, 
#	for num in range(0, concave_angles.size()):
#		var current = concave_angles[num].duplicate();
#		var high_score = pow(2, 64) - 1; var high_score_point
#		for num_2 in range(0, angles.size()):
#			var point = angles[num_2].duplicate()
#			if current[1] != point[1]: #not the same point
#				#huh
#				if current[2] == point[2]:
#					if !(concave_angles.has(point)): continue 
#					var angle_between = current[0] + point[0]
#					for num_3 in range(num, num_2): angle_between -= angles[num_3][0]
#					if !(!(angle_between > 0) if point[2] != 0 else !(angle_between <= 0)): continue
#				else: 
#					var no_collisions = true
#					for num in range(0, new_connections.size(), 2):
#						var collisions = Geometry.segment_intersects_segment_2d(new_connections[num], new_connections[num+1], current[1], point[1])
#						if collisions != null: if !(collisions == current[1] or collisions == point[1]): no_collisions = false
#					if !no_collisions: continue
#				var distance = current[1].distance_squared_to(point[1])
#				if distance < high_score: 
#					high_score = distance; high_score_point = point
#		new_connections.append(current[1])
#		new_connections.append(high_score_point[1])
#	#############
	
	
	
	#disgusting code, needs refactoring, ew
	var counter = 0
	var num = 0; var num_2 = 1; 
	var first = shapes[num][num_2-1]; cells[-1].append(first); cells[-1].append(shapes[num][num_2]); var previous = shapes[num][num_2-2]; 
	while shapes[num][num_2] != first and counter < 30:
		counter += 1
		var current = shapes[num][num_2];
		var low_score = 2 * PI
		var low_score_point = Vector2.ZERO
		if new_connections.has(current):
			var a = 0
			var go = true
			while go:
				a = new_connections.find(current, a)
				if a == -1:
					go = false
				else: 
					var a2 = new_connections[(a + 1 if((0 if a == 0 else a%2) == 0) else a - 1)]
					if a2 != previous: 
						a2 -= current 
						var b2 = previous - current
						var angle = atan2(a2.x * b2.y - a2.y * b2.x, a2.x * b2.x + a2.y * b2.y)
						if angle < 0: angle = (2 * PI) + angle
						if angle < low_score:
							low_score = angle
							low_score_point = a2 + current
				a += 1 #for index to start at on next iteration for find() 2nd arugument
		var a = num_2+1 if num == 0 else num_2 - 1 ; if a > shapes[num].size()-1: a = 0; a = shapes[num][a]; a = a - current
		var b = previous - current 
		var angle = atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
		if angle < 0: angle = (2 * PI) + angle
		if angle < low_score: 
			low_score = angle
			low_score_point = a + current
		previous = current
		for num_3 in range(0, shapes.size()):
			if (shapes[num_3] as Array).has(low_score_point): 
				num_2 = (shapes[num_3] as Array).find(low_score_point)
				num = num_3
				break
		cells[-1].append(shapes[num][num_2])
	
	
	
	var high_score = 0
	hsdr
	for num in range(1, cells[-1].size()):
		var d = (cells[-1][num-1]).distance_squared_to(cells[-1][num])
		if d > high_score:
			high_score = d
			hsdr = ((cells[-1][num-1]).direction_to(cells[-1][num])).tangent()
	
	var ordered_points = cells[-1].duplicate(true)
	ordered_points.sort_custom(self, "sort_custom")
	
	var slice_array = [[ordered_points[0], ordered_points[0]]]
	var slice = [[ordered_points[0], ordered_points[0]]]
	for num in range(1, ordered_points.size()-1):
		var n = cells[-1].find(ordered_points[num])
		var m = n-1; if n > ordered_points.size()-1: n = 0; if n < 0: n = ordered_points.size();
		var o = slice.find(ordered_points[m])
		if o > -1:
			slice[o] = ordered_points[num]
			slice_array.append(slice)
		else: 
			m = n+1; if n > ordered_points.size()-1: n = 0; if n < 0: n = ordered_points.size();
			o = slice.find(ordered_points[m])
			if o > -1:
				slice[o] = ordered_points[num]
				slice_array.append(slice)
	slice_array.append([ordered_points[-1], ordered_points[-1]])
	
	slice_array.invert()
	ordered_points.invert()
	for num in range(1, slice_array.size()-1):
		var current_2
		var previous_2 
		var p = 0
		if slice_array[num][0] == ordered_points[num]:
			#change second point
			current_2 = slice[num][1]
			previous_2 = slice[num-1][1]
			p = 1
		elif slice_array[num][1] == ordered_points[num]:
			current_2 = slice[num][0]
			previous_2 = slice[num-1][0]
			p = 0
			#change first point
		if thingy(current_2, hsdr) != thingy(previous_2, hsdr):
			var t = (thingy(ordered_points[num], hsdr) - thingy(current_2, hsdr) / (thingy(previous_2, hsdr) - thingy(current_2, hsdr)))
			slice_array[num][p] == current_2.linear_interpolate(previous_2, t)
		
		
		
	
	
	
	

func sort_custom(a, b):
	a = ((hsdr * a[0])/hsdr.length() * hsdr)
	b = ((hsdr * b[0])/hsdr.length() * hsdr)
	if a > b: return true
	return false 


func thingy(a, b):
	return ((b * a) / b.length() * b)
	
