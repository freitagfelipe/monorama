extends KinematicBody2D

export var speed: int

signal player_move(message)

func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("down"):
		velocity.y = 1
	elif Input.is_action_pressed("forward"):
		velocity.y = -1
	
	velocity *= speed
	
	move_and_slide(velocity)
	
	emit_signal("player_move", "Pong player position: %f %f" % [position.x, position.y])
