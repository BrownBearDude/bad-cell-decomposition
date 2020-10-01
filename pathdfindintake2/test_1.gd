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
	_points_at_slice(nodes)



func _points_at_slice(nodes):
	#drawing stuff
	set_process(true)
	
	
	keys.sort_custom(self, "custom_sort")
	print_debug(keys)
	
	#will rename variables in the furture 
	var num = 0
	var temp = [] #the current slice
	var temp_2 = [] # an array of current slices
	
	while num < keys.size():
		var index = null
		temp_2 = temp_2.duplicate(true)
		
		if nodes[keys[num]][0].x >= keys[num].x and nodes[keys[num]][1].x >= keys[num].x:
			index = (_increase_in_conn(temp, keys, nodes, num))
			if index == null: index = 0
			temp.insert(index, keys[num])
			temp.insert(index, keys[num])
			temp_2.append(temp)
#			print(temp_2[temp_2.size()-1])
		
		
		
		# this just doesn't work it outputs a blank array, why, why
		elif nodes[keys[num]][0].x <= keys[num].x and nodes[keys[num]][1].x <= keys[num].x:
			var temp_3 = temp.duplicate(true)
#			print("decrease")
			
			index = _decrease_in_conn(temp, keys, nodes, num, 0)
			if index != null:
				temp[index] = keys[num]
				temp_3.remove(index)
			
			index = _decrease_in_conn(temp, keys, nodes, num, 1)
			if index != null:
				temp[index] = keys[num]
				temp_3.remove(index)
			
			temp_2.append(temp)
			temp = temp_3.duplicate(true)
#			print(temp_2[temp_2.size()-1])
		
		else:
			index = _not_increase_in_conn(temp, keys, nodes, num)
			if index != null:
				temp[index] = keys[num]
				temp_2.append(temp)
#				print(temp_2[temp_2.size()-1])
		num += 1
	
	
	for ob in temp_2:
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
		var temp_2 = ob
		var temp = nodes[ob]
		for ob in temp:
			draw_line(ob, temp_2, Color.white, 10.0)



#sort based on x value if there the same y value 
func custom_sort(a, b):
	if a.x < b.x:
		return true 
	if a.x == b.x:
		if a.y < b.y:
			return true
	return false 


#find inbetween what it is and shove it in there. 
func _increase_in_conn(temp, keys, nodes, num):
	if !(temp.empty()):
		var i = 0
		for ob in temp:
			if keys[num].y <= ob.y: 
				return i
			i += 1
		return temp.size()
	else:
		return 0


func _decrease_in_conn(temp, keys, nodes, num, fuck):
	var index = temp.find(nodes[keys[num]][fuck])
	if index >= 0 : return index


#find brother and replace it 
func _not_increase_in_conn(temp, keys, nodes, num):
	var index = temp.find(nodes[keys[num]][0])
	if index >= 0 : return index
	else:
		index = temp.find(nodes[keys[num]][1])
		if index >= 0: return index 
		else: return  
