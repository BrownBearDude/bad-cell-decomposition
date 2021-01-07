extends Node2D

var shapes = []
var all_points = []

var new_connections = []

var cell = []

var hsdr = Vector2.ZERO

var debugging = []

func _draw():
	for num in range(0, new_connections.size(), 2):
		draw_line(new_connections[num], new_connections[num+1], Color.red, 10)
	
	for num in range(1, cell.size()):
		draw_line(cell[num], cell[num-1], Color.blue, 10)
	
	for ob in debugging:
		draw_circle(ob, 5, Color.purple)
	
	for num in range(1, debugging.size()):
		draw_line(debugging[num-1], debugging[num], Color.aqua)
	
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
			if angle > PI: concave_angles.append([angle, shapes[num][num_2], num, num_2])
			angles.append([angle, shapes[num][num_2], num, num_2])
	
	
	
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
					if !(abs(current[3] - point[3]) > 1): continue
					var angle_between = current[0] + point[0]
					for num_3 in range(num, num_2): angle_between -= angles[num_3][0]
					if !((angle_between <= 0) if point[2] != 0 else (angle_between >= 0)): continue #idk, need to change this
				else:  
					var no_collisions = true
					for num in range(0, new_connections.size(), 2):
						if !((new_connections[num] == current[1] and new_connections[num+1] == point[1]) or (new_connections[num] == point[1] and new_connections[num+1] == current[1])):
							var collisions = Geometry.segment_intersects_segment_2d(new_connections[num], new_connections[num+1], current[1], point[1])
							if collisions != null: 
								if !(collisions == current[1] or collisions == point[1]): 
									no_collisions = false
					if !no_collisions: continue
				var distance = current[1].distance_squared_to(point[1])
				if distance < high_score: 
					high_score = distance; high_score_point = point
		new_connections.append(current[1])
		new_connections.append(high_score_point[1])
	
	
	#actaully forms the cells
	var high_score = 0
	var iteration_num = 0
	var num_shape = 0; var num_point = 2; 
	var first = shapes[num_shape][num_point - 1] if num_shape == 0 else shapes[num_shape][num_point + 1]
	var previous = first
	cell.append(shapes[num_shape][num_point]); 
	high_score = first.distance_squared_to(shapes[num_shape][num_point]) 
	hsdr = first.direction_to(shapes[num_shape][num_point])
	while shapes[num_shape][num_point] != first and iteration_num <= 30:
		iteration_num += 1;
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
		for num_3 in range(0, shapes.size()): if (shapes[num_3] as Array).has(low_score_point): 
				num_point = (shapes[num_3] as Array).find(low_score_point)
				num_shape = num_3
				break
		
		#for finding longest edge #need to do 
		var d = low_score_point.distance_squared_to(previous)
		if d > high_score:
			high_score = d
			hsdr = low_score_point.direction_to(previous)
			print(hsdr)
		previous = current
		
	hsdr = hsdr.tangent()
	var ordered = cell.duplicate(true)
	ordered.sort_custom(self, "sort_custom")
	hsdr = ordered[0].direction_to(ordered[-1]).tangent()
	ordered.sort_custom(self, "sort_custom")
	
	
	var top = cell.find(ordered[0])
	var top2 = cell[top]; top2 = ordered[0] - top2; top2 = top2.dot(hsdr)
	var top3 = top+1; if top3 > cell.size()-1: top3 = 0; 
	var top4 = cell[top3]; top4 = ordered[0] - top4; top4 = top4.dot(hsdr)
	
	var bottom = cell.find(ordered[0])
	var bottom2 = cell[bottom]; bottom2 = ordered[0] - bottom2; bottom2 = bottom2.dot(hsdr) 
	var bottom3 = bottom-1; if bottom3 < 0: cell.size()-1; 
	var bottom4 = cell[bottom3]; bottom4 = ordered[0] - bottom4; bottom4 = bottom4.dot(hsdr)
	
	for num in range(1, abs(ordered[0].dot(hsdr)-ordered[-1].dot(hsdr)), 5):
		while !(top2 < num and num < top4) or (top4 < num and num < top2):  
			top += 1; if top > cell.size()-1: top = 0;
			top2 = cell[top]; top2 = ordered[0] - top2; top2 = top2.dot(hsdr)
			top3 = top+1; if top3 > cell.size()-1: top3 = 0;
			top4 = cell[top3]; top4 = ordered[0] - top4; top4 = top4.dot(hsdr)
		var t = (top4 - top2)
		if !(t == 0): t = (num - top2) / t
		debugging.append(cell[top].linear_interpolate(cell[top3], t))
		
		while  !(bottom2 < num and num < bottom4) or (bottom4 < num and num < bottom2):
			bottom -= 1; if bottom < 0: bottom = cell.size()-1;
			bottom2 = cell[bottom]; bottom2 = ordered[0] - bottom2; bottom2 = bottom2.dot(hsdr)
			bottom3 = bottom-1; if bottom3 < 0: bottom3 = cell.size()-1;
			bottom4 = cell[bottom3]; bottom4 = ordered[0] - bottom4; bottom4 = bottom4.dot(hsdr)
		t = (bottom4 - bottom2)
		if !(t == 0): t = (num - bottom2) / t
		debugging.append(cell[bottom].linear_interpolate(cell[bottom3], t))

#might be a bad function becuz it only does 1 thing #fuck you?
func _top(num, cell, ordered, top, top2, top3, top4):
	while !(top2 < num and num < top4) or (top4 < num and num < top2):  
			top += 1; if top > cell.size()-1: top = 0;
			top2 = cell[top]; top2 = ordered[0] - top2; top2 = top2.dot(hsdr)
			top3 = top+1; if top3 > cell.size()-1: top3 = 0;
			top4 = cell[top3]; top4 = ordered[0] - top4; top4 = top4.dot(hsdr)
	var t = (top4 - top2)
	if !(t == 0): t = (num - top2) / t
	return[(cell[top].linear_interpolate(cell[top3], t)), top, top2, top3, top4 ]
	


func sort_custom(a, b):
	if a.dot(hsdr) > b.dot(hsdr): 
		return true
	return false
