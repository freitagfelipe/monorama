extends KinematicBody2D

export var speed: int
var is_receving_input := true
var velocity: Vector2
var direction: String
var current_animation: String
var last_animation: String = "Idle front"

signal player_move(position)
signal player_animation(animation)

func _physics_process(_delta):
	if not is_receving_input:
		return
	
	var is_moving = false
	
	velocity = Vector2.ZERO

	if Input.is_action_pressed("forward"):
		current_animation = "Walking back"
		is_moving = true
		direction = "up"
		velocity.y = -1
	elif Input.is_action_pressed("down"):
		current_animation = "Walking front"
		is_moving = true
		direction = "down"
		velocity.y = 1

	if Input.is_action_pressed("left"):
		current_animation = "Walking left"
		is_moving = true
		direction = "left"
		velocity.x = -1
	elif Input.is_action_pressed("right"):
		current_animation = "Walking right"
		is_moving = true
		direction = "right"
		velocity.x = 1
		
	velocity *= speed
	velocity = move_and_slide(velocity)
	
	if not is_moving:
		match direction:
			"right":
				current_animation = "Idle right"
			"left":
				current_animation = "Idle left"
			"up":
				current_animation = "Idle back"
			"down":
				current_animation = "Idle front"
		
	if velocity != Vector2.ZERO:
		emit_signal("player_move", "Player position: %s %s" % [position.x, position.y])
	
	if last_animation != current_animation:
		$Sprite.play(current_animation)
		
		emit_signal("player_animation", "Player animation: %s" % [$Sprite.animation])
	else:
		last_animation = current_animation
	
func set_is_receving_input(state):
	is_receving_input = state
