extends Node
export var on_once = false
export var on = false

var noise 
export var chunk_size = 2
export var render_distance = 8
export(NodePath) var agent_thing_path

func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 1
	noise.period = 16
	
	if on_once:
		_shit()

func _shit():
	$TileMap.clear()
	$TileMap2.clear()
	$TileMap3.clear()
	$TileMap4.clear()
	$TileMap5.clear()
	$TileMap6.clear()
	$TileMap7.clear()
	$TileMap8.clear()
	for chunk_x in range(0, render_distance * 2 + 1):
		chunk_x -= render_distance
		for chunk_y in range(0, render_distance * 2 + 1):
			chunk_y -= render_distance
			for x in chunk_size:
				for y in chunk_size:
					var burh = (($TileMap.world_to_map(get_node(agent_thing_path).position))/chunk_size)
					burh = (Vector2(floor(burh.x), floor(burh.y)))
					var v = Vector2(x + (burh.x - chunk_x) * chunk_size, y + (burh.y - chunk_y) * chunk_size)
					var a = noise.get_noise_2dv(v)
					$TileMap6.set_cellv(v, 7)
					if (a > -0.5):
						$TileMap.set_cellv(v, 0)
						$TileMap.update_bitmask_area(v)
#					if (a > -0.4 and a < 0) or (a > 0.4 and a < 0.5):
#						var h =  randi()%100 
#						if h < 10:
#							$TileMap8.set_cellv(v, 0)
#						if h > 10 and h < 20:
#							$TileMap8.set_cellv(v, 1)
#						if h > 20 and h < 30:
#							$TileMap8.set_cellv(v, 2)
					if (a > 0 and a < 0.2):
						$TileMap7.set_cellv(v, 6)
						$TileMap7.update_bitmask_area(v)
					if (a > 0.3): 
						$TileMap2.set_cellv(v, 1)
						$TileMap2.update_bitmask_area(v)
					if (a > 0.5): 
						$TileMap3.set_cellv(v, 2)
						$TileMap3.update_bitmask_area(v)
					if (a > 0.7): 
						$TileMap4.set_cellv(v, 3)
						$TileMap4.update_bitmask_area(v)
					if (a > 0.8):
						$TileMap5.set_cellv(v, 4)
						$TileMap5.update_bitmask_area(v)

func _process(delta):
	if on:
		_shit()
