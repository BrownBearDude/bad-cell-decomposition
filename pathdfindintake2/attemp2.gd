extends Node2D

var shapes = []
var all_points = []

var new_connections = []

var cell = []

var hsdr

func _draw():
	for num in range(0, new_connections.size(), 2):
		draw_line(new_connections[num], new_connections[num+1], Color.red, 10)
	
	for num_2 in range(1, cell.size()):
		draw_line(cell[num_2], cell[num_2-1], Color.blue, 10)

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
	
	
	
	#finds were the shape should be split
	for num in range(0, concave_angles.size()):
		var current = concave_angles[num].duplicate();
		var high_score = pow(2, 64) - 1; var high_score_point
		for num_2 in range(0, angles.size()):
			var point = angles[num_2].duplicate()
			if current[1] != point[1]: #not the same point
				#huh
				if current[2] == point[2]:
					if !(concave_angles.has(point)): continue 
					var angle_between = current[0] + point[0]
					for num_3 in range(num, num_2): angle_between -= angles[num_3][0]
					if !(!(angle_between > 0) if point[2] != 0 else !(angle_between <= 0)): continue
				else: 
					var no_collisions = true
					for num in range(0, new_connections.size(), 2):
						var collisions = Geometry.segment_intersects_segment_2d(new_connections[num], new_connections[num+1], current[1], point[1])
						if collisions != null: if !(collisions == current[1] or collisions == point[1]): no_collisions = false
					if !no_collisions: continue
				var distance = current[1].distance_squared_to(point[1])
				if distance < high_score: 
					high_score = distance; high_score_point = point
		new_connections.append(current[1])
		new_connections.append(high_score_point[1])
	
	
	var high_score = 0
	var hsdr
	
	#actaully forms the cells
	var iteration_num = 0
	var num_shape = 0; var num_point = 11; 
	var first = shapes[num_shape][num_point - 1] if num_shape == 0 else shapes[num_shape][num_point + 1]
	var previous = first
	cell.append(shapes[num_shape][num_point]); 
	high_score = first.distance_squared_to(shapes[num_shape][num_point]); hsdr = first.direction_to(shapes[num_shape][num_point])
	while shapes[num_shape][num_point] != first and iteration_num <= 30:
		iteration_num += 1; print(iteration_num); 
		if num_point < 0: num_point = shapes[num_shape].size(); if num_point > shapes[num_shape].size()-1: num_shape = 0
		var current = shapes[num_shape][num_point]
		var low_score = 2 * PI; var low_score_point
		if new_connections.has(current):
			var a = 0
			while new_connections.find(current, a) != -1:
				a = new_connections.find(current, a)
				var a2 = new_connections[(a + 1 if((0 if a == 0 else a%2) == 0) else a - 1)]
				if a != -1:
					if a2 != previous:
						var b2 = previous - current
						a2 -= current
						var angle = atan2(a2.x * b2.y - a2.y * b2.x, a2.x * b2.x + a2.y * b2.y)
						if angle < 0: angle = (2 * PI) + angle
						if angle < low_score:
							low_score = angle
							low_score_point = a2 + current
				a += 1
		var a = num_point+1 if num_shape == 0 else num_point - 1 ; if a > shapes[num_shape].size()-1: a = 0; a = shapes[num_shape][a]; a = a - current
		var b = previous - current 
		var angle = atan2(a.x * b.y - a.y * b.x, a.x * b.x + a.y * b.y)
		if angle < 0: angle = (2 * PI) + angle
		if angle < low_score: 
			low_score = angle
			low_score_point = a + current
		cell.append(low_score_point)
		
		#for finding longest edge
		for num_3 in range(0, shapes.size()): if (shapes[num_3] as Array).has(low_score_point): 
				num_point = (shapes[num_3] as Array).find(low_score_point)
				num_shape = num_3
				break
		
		var d = low_score_point.distance_squared_to(previous)
		if d > high_score:
			high_score = d
			hsdr = low_score_point.direction_to(previous)
			print(low_score_point); print(previous)
		previous = current
	print(hsdr)
	
	
	
#	var high_score = 0
#	hsdr
#	for num in range(1, cells[-1].size()):
#		var d = (cells[-1][num-1]).distance_squared_to(cells[-1][num])
#		if d > high_score:
#			high_score = d
#			hsdr = ((cells[-1][num-1]).direction_to(cells[-1][num])).tangent()
#
#	var ordered_points = cells[-1].duplicate(true)
#	ordered_points.sort_custom(self, "sort_custom")
#
#	var slice_array = [[ordered_points[0], ordered_points[0]]]
#	var slice = [[ordered_points[0], ordered_points[0]]]
#	for num in range(1, ordered_points.size()-1):
#		var n = cells[-1].find(ordered_points[num])
#		var m = n-1; if n > ordered_points.size()-1: n = 0; if n < 0: n = ordered_points.size();
#		var o = slice.find(ordered_points[m])
#		if o > -1:
#			slice[o] = ordered_points[num]
#			slice_array.append(slice)
#		else: 
#			m = n+1; if n > ordered_points.size()-1: n = 0; if n < 0: n = ordered_points.size();
#			o = slice.find(ordered_points[m])
#			if o > -1:
#				slice[o] = ordered_points[num]
#				slice_array.append(slice)
#	slice_array.append([ordered_points[-1], ordered_points[-1]])
#
#	slice_array.invert()
#	ordered_points.invert()
#	for num in range(1, slice_array.size()-1):
#		var current_2
#		var previous_2 
#		var p = 0
#		if slice_array[num][0] == ordered_points[num]:
#			#change second point
#			current_2 = slice[num][1]
#			previous_2 = slice[num-1][1]
#			p = 1
#		elif slice_array[num][1] == ordered_points[num]:
#			current_2 = slice[num][0]
#			previous_2 = slice[num-1][0]
#			p = 0
#			#change first point
#		if thingy(current_2, hsdr) != thingy(previous_2, hsdr):
#			var t = (thingy(ordered_points[num], hsdr) - thingy(current_2, hsdr) / (thingy(previous_2, hsdr) - thingy(current_2, hsdr)))
#			slice_array[num][p] == current_2.linear_interpolate(previous_2, t)
#
#func sort_custom(a, b):
#	a = ((hsdr * a[0])/hsdr.length() * hsdr)
#	b = ((hsdr * b[0])/hsdr.length() * hsdr)
#	if a > b: return true
#	return false 
#
#
#func thingy(a, b):
#	return ((b * a) / b.length() * b)
#
