extends KinematicBody2D

export var speed: int
var is_receving_input := true
var velocity: Vector2

signal player_move(position)

func _physics_process(_delta):
	if not is_receving_input:
		return

	velocity = Vector2.ZERO

	if Input.is_action_pressed("forward"):
		velocity.y = -1

	if Input.is_action_pressed("down"):
		velocity.y = 1

	if Input.is_action_pressed("left"):
		velocity.x = -1

	if Input.is_action_pressed("right"):
		velocity.x = 1
		
	velocity *= speed
	velocity = move_and_slide(velocity)
		
	if velocity != Vector2.ZERO:
		emit_signal("player_move", "Player position: %s %s" % [position.x, position.y])
	
	
func set_is_receving_input(state):
	is_receving_input = state
