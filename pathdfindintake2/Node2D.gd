extends Node2D

export var table = [Vector2(-3, 0.74), Vector2(-2, 1.25), Vector2(-1, 1.57), Vector2(0, 1.7), Vector2(1, 1.56), Vector2(2, 1.2), Vector2(3, 0.6)]
var n = table.size()

# Called when the node enters the scene tree for the first time.
func _ready():
	var sumx = 0.0
	var sumy = 0.0
	var sumx2 = 0.0
	
	var sumx3 = 0.0
	var sumx4 = 0.0
	var sumxy = 0.0
	var sumx2y = 0.0
	for ob in table:
		sumx += ob.x
		sumy += ob.y
		sumx2 += pow(ob.x,2.0)
		sumx3 += pow(ob.x,3)
		sumx4 += pow(ob.x,4)
		sumxy += ob.x * ob.y
		sumx2y += pow(ob.x,2) * ob.y
	print("sumx: "+String(sumx)+" sumy: "+String(sumy)+" sumx2: "+String(sumx2)+" sumx3: "+String(sumx3)+" sumx4: "+String(sumx4)+" sumxy: "+String(sumxy)+" sumx2y: "+String(sumx2y))
	var sumxx = (sumx2) - (pow(sumx,2)/n)
	sumxy = (sumxy) - ((sumx * sumy/n))
	var sumxx2 = (sumx3) - ((sumx2*sumx)/n)
	sumx2y = (sumx2y) - ((sumx2 * sumy)/n)
	var sumx2x2 = (sumx4) - (pow(sumx2,2)/n)
	print("sumxx: "+String(sumxx)+" sumxy: "+String(sumxy)+" sumxx2: "+String(sumxx2)+" sumx2y: "+String(sumx2y)+" sumx2x2: "+String(sumx2x2))
	
	var a = ((sumx2y * sumxx) - (sumxy * sumxx2)) /  ((sumxx * sumx2x2) - pow(sumxx2,2) )
	var b = ((sumxy*sumx2x2) - (sumx2y*sumxx2)) / ((sumxx*sumx2x2)- pow(sumxx2,2))
	var c = (sumy/n) - (b*(sumx/n)) - (a*(sumx2/n))
	print(a) 
	print(b) 
	print(c)



func _draw():
	pass
