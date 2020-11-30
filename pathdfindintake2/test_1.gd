extends Node2D
#storage of shapes with neirbours, might be a bad way to store shapes, 
#I don'know and don't care, might look into it in the future. 
signal pathfinding_complete
var show_path = false
var nodes = {
	#big shape
	Vector2(900,0) : [Vector2(1000,150), Vector2(100,0)],
	Vector2(100,0) : [Vector2(900, 0), Vector2(0,300)],
	Vector2(0,300) : [Vector2(100,0), Vector2(100,600)],
	Vector2(100,600) : [Vector2(0,300), Vector2(900,600)],
	Vector2(900,600) : [Vector2(100,600), Vector2(1000,450)],
	Vector2(1000,450) : [Vector2(900,600), Vector2(900,300)],
	Vector2(900,300) : [Vector2(1000,450), Vector2(1000, 150)],
	Vector2(1000,150) : [Vector2(900,300), Vector2(900,0)],
	#small shape
	Vector2(300,300) : [Vector2(400,200), Vector2(400,400)],
	Vector2(400,400) : [Vector2(300,300), Vector2(700,400)],
	Vector2(700,400) : [Vector2(400,400), Vector2(600,300)],
	Vector2(600,300) : [Vector2(700,400), Vector2(700,200)],
	Vector2(700,200) : [Vector2(600,300), Vector2(400,200)],
	Vector2(400,200) : [Vector2(700,200), Vector2(300,300)]
}

var keys = nodes.keys() 
var points_at_point = []
var f = []

func _ready():
	f = _phase_0(nodes)
	yield(self, "pathfinding_complete")
	set_process(true)

#needed for drawing 
func _process(delta): 
	update()
	
	#debugging mouse poisition
	if Input.is_action_just_pressed("ui_accept"):
		print(get_global_mouse_position())
	if Input.is_action_just_pressed("toggle_show_path"):
		show_path = !show_path

#draw the outline of the big shape. 
func _draw():
	for ob in nodes:
		var slice_array = ob
		var slice = nodes[ob]
		for ob in slice:
			draw_line(ob, slice_array, Color.white, 10.00)
	if show_path == true:
		for num in range(1, f.size()):
			draw_line(f[num-1], f[num], Color.red, 2)

func _phase_0(nodes):
	keys.sort_custom(self, "custom_sort")
	print_debug(keys)
	var num = 0
	var slice = []
	var slice_array = []
	while num < keys.size():
		var index = null
		slice_array = slice_array.duplicate(true)
		if nodes[keys[num]][0].x >= keys[num].x and nodes[keys[num]][1].x >= keys[num].x:
			index = (_increase_in_conn(slice, keys, nodes, num))
			if index == null: index = 0
			slice_array.append(slice.duplicate(true))
			keys.insert(num, keys[num])
			slice.insert(index, keys[num])
			slice.insert(index, keys[num])
			slice_array.append(slice)
			num += 1
		elif nodes[keys[num]][0].x <= keys[num].x and nodes[keys[num]][1].x <= keys[num].x:
			var slice_save_point = slice.duplicate(true)
			
			index = _decrease_in_conn(slice, keys, nodes, num, 0)
			if index != null:
				slice[index] = keys[num]
				slice_save_point.remove(index)
			index = _decrease_in_conn(slice, keys, nodes, num, 1)
			if index != null:
				slice[index] = keys[num]
				slice_save_point.remove(index)
			slice_array.append(slice.duplicate(true))
			slice_array.append(slice_save_point.duplicate(true))
			keys.insert(num, keys[num])
			num += 1
			slice = slice_save_point.duplicate(true)
		else:
			index = _not_increase_in_conn(slice, keys, nodes, num)
			if index != null:
				slice[index] = keys[num]
				slice_array.append(slice)
		num += 1
	emit_signal("pathfinding_complete")
	return _phase_1(nodes, keys, slice_array)

func custom_sort(a, b):
	if a.x < b.x:
		return true 
	if a.x == b.x:
		if a.y < b.y:
			return true
	return false 

#these things are simular
func _increase_in_conn(slice, keys, nodes, num):
	if !(slice.empty()):
		var i = 0
		for ob in slice:
			if keys[num].y <= ob.y: 
				return i
			i += 1
		return slice.size()
	else:
		return 0

func _decrease_in_conn(slice, keys, nodes, num, not_a_swear):
	var index = slice.find(nodes[keys[num]][not_a_swear])
	if index >= 0 : return index
 
func _not_increase_in_conn(slice, keys, nodes, num):
	var index = slice.find(nodes[keys[num]][0])
	if index >= 0 : return index
	else:
		index = slice.find(nodes[keys[num]][1])
		if index >= 0: return index 
		else: return  

func _phase_1(nodes, keys, input):
	input.invert()
	keys.invert()
	
	for num in range(2, input.size()):
		for num_2 in range(0, input[num].size()):
			if input[num].size() > input[num-1].size():
				if !(input[num][num_2] == keys[num]):
					if num_2 > input[num].find(keys[num]):
						var current = input[num][num_2]
						var previous = input[num-1][num_2-(input[num].size() - input[num-1].size())]
							
						if !(current.x == previous.x):
							var t = (keys[num].x - current.x) / (previous.x - current.x)
							input[num][num_2] = current.linear_interpolate(previous, t)
						#modified progression
					else:
						var current = input[num][num_2]
						var previous = input[num-1][num_2]
			
						if !(current.x == previous.x):
							var t = (keys[num].x - current.x) / (previous.x - current.x)
							input[num][num_2] = current.linear_interpolate(previous, t)
						#normal progression
			elif input[num].size() < input[num-1].size():
				if num_2 >= input[num-1].find(keys[num-1]):
					var current = input[num][num_2]
					var previous = input[num-1][num_2-(input[num].size() - input[num-1].size())]
					if !(current.x == previous.x):
						var t = (keys[num].x - current.x) / (previous.x - current.x)
						input[num][num_2] = current.linear_interpolate(previous, t)
					#modified progression
				else:
					var current = input[num][num_2]
					var previous = input[num-1][num_2]
					if !(current.x == previous.x):
						var t = (keys[num].x - current.x) / (previous.x - current.x)
						input[num][num_2] = current.linear_interpolate(previous, t)
					#modified progression
			else:
				var current = input[num][num_2]
				var previous = input[num-1][num_2]
				if !(current.x == previous.x):
					var t = (keys[num].x - current.x) / (previous.x - current.x)
					input[num][num_2] = current.linear_interpolate(previous, t)
				#normal progression
	
	keys.invert()
	input.invert()
	return _phase_2(nodes, keys, input)

func _phase_2(nodes, keys, input):
	var final_array = []
	var temp_array = []
	var previous_size = 0
	for num in range(0, input.size()):
		if previous_size != input[num].size():
			final_array += temp_array.duplicate(true)
			temp_array.clear()
			temp_array.resize(floor(input[num].size()/2))
			for a in range(0, temp_array.size()):
				temp_array[a] = []
		for num_2 in range(0, input[num].size(), 2):
			temp_array[floor(num_2/2)].append([input[num][num_2], input[num][num_2+1]])
		previous_size = input[num].size()
	return _phase_3(nodes, keys, final_array)

func _phase_3(nodes, keys, input):
	var final_path = []
	for num in range(0, input.size()):
		var path_width = 30
		var path = 0
		for num_2 in range(1, input[num].size()):
			if !(input[num][num_2][0].x - input[num][num_2-1][0].x == 0): 
				while path * path_width < (input[num][num_2][0].x - input[num][num_2-1][0].x):
					var t = 0
					if !(path * path_width == 0):
						t = (path * path_width) / (input[num][num_2][0].x - input[num][num_2-1][0].x)
						final_path.append(input[num][num_2-1][0].linear_interpolate(input[num][num_2][0], t))
						final_path.append(input[num][num_2-1][1].linear_interpolate(input[num][num_2][1], t))
					path += 1
				path = path - (input[num][num_2][0].x - input[num][num_2-1][0].x) / path_width 
				print(path)
	emit_signal("path_finding_complete")
	return(final_path)
	

