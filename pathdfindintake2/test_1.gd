extends Node2D
#storage of shapes with neirbours, might be a bad way to store shapes, 
#I don'know and don't care, might look into it in the future. 
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

func _ready():
	#drawing stuff
	set_process(true)
	for ob in _points_at_slice(nodes):
		print(ob)

#needed for drawing 
func _process(delta): 
	update()
	
	#debugging mouse poisition
	if Input.is_action_just_pressed("ui_accept"):
		print(get_global_mouse_position())

#draw the outline of the big shape. 
func _draw():
	for ob in nodes:
		var slice_array = ob
		var slice = nodes[ob]
		for ob in slice:
			draw_line(ob, slice_array, Color.white, 10.00)


func _points_at_slice(nodes):

	keys.sort_custom(self, "custom_sort")
	print_debug(keys)
	
	#will rename variables in the furture 
	var num = 0
	var slice = [] #the current slice
	var slice_array = [] # an array of current slices
	
	while num < keys.size():
		var index = null
		slice_array = slice_array.duplicate(true)
		if nodes[keys[num]][0].x >= keys[num].x and nodes[keys[num]][1].x >= keys[num].x:
			index = (_increase_in_conn(slice, keys, nodes, num))
			if index == null: index = 0
			slice.insert(index, keys[num])
			slice.insert(index, keys[num])
			slice_array.append(slice)
#			print(slice_array[slice_array.size()-1])
		elif nodes[keys[num]][0].x <= keys[num].x and nodes[keys[num]][1].x <= keys[num].x:
			var slice_save_point = slice.duplicate(true)
#			print("decrease")
			index = _decrease_in_conn(slice, keys, nodes, num, 0)
			if index != null:
				slice[index] = keys[num]
				slice_save_point.remove(index)
			index = _decrease_in_conn(slice, keys, nodes, num, 1)
			if index != null:
				slice[index] = keys[num]
				slice_save_point.remove(index)
			slice_array.append(slice)
			slice = slice_save_point.duplicate(true)
#			print(slice_array[slice_array.size()-1])
		else:
			index = _not_increase_in_conn(slice, keys, nodes, num)
			if index != null:
				slice[index] = keys[num]
				slice_array.append(slice)
#				print(slice_array[slice_array.size()-1])
		num += 1
	
	return slice_array


#sort based on x value if there the same y value 
func custom_sort(a, b):
	if a.x < b.x:
		return true 
	if a.x == b.x:
		if a.y < b.y:
			return true
	return false 


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
