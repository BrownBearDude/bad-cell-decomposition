extends KinematicBody2D

var min_speed = 100
var max_speed = 2000
var speed = 0 

var min_zoom = Vector2(1, 1)
var max_zoom = Vector2(2, 2)
var zoom = 0



func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if Input.is_action_pressed("zoom_out") && zoom < 1:
		zoom += 0.1
	if Input.is_action_pressed("zoom_in") && zoom > 0:
		zoom -= 0.1
	$Camera2D.zoom = min_zoom.linear_interpolate(max_zoom, zoom)
	
	if Input.is_action_pressed("speed_increase") && speed < 1:
		speed += 0.01
	if Input.is_action_pressed("speed_decrease") && speed > 0.1:
		speed -= 0.01
	var current_speed = min_speed * (1 - speed) + max_speed * speed
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("up"):
		velocity.y -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("right"):
		velocity.x += 1
	move_and_collide(velocity * current_speed * delta)