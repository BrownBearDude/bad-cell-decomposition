extends KinematicBody2D


var wheel_base = 70
var steering_angle = 15

var velocity = Vector2.ZERO
var steer_angle
var path

func _physics_process(delta):
	calculate_steering(delta)
	get_input()
	move_and_slide(velocity)

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_angle) * delta
	var new_heading = (front_wheel - rear_wheel).normalized()
	velocity = new_heading * velocity.length()
	rotation = new_heading.angle()
