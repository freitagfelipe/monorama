extends KinematicBody2D

var velocity: Vector2
var rng = RandomNumberGenerator.new()

signal ball_move(position)
signal score(message)

func _ready():
	if HostController.in_use:
		randomize_ball()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var dot = velocity.dot(collision.normal)
		var normal_prime = collision.normal * dot * 2
		var reflected = normal_prime - velocity
		
		velocity = reflected * -1
	
	if position.x < -30:
		randomize_ball()
		
		emit_signal("score", "Player score: 2")
	elif position.x > 1054:
		randomize_ball()
		
		emit_signal("score", "Player score: 1")
	
	emit_signal("ball_move", "Ball position: %f %f" % [position.x, position.y])

func randomize_ball():
	set_deferred("position", Vector2(512, 300))
	
	rng.randomize()
		
	var random_number = rng.randi_range(0, 10)
	
	if random_number < 6:
		velocity = Vector2(250, 5)
	else:
		velocity = Vector2(-250, 5)
