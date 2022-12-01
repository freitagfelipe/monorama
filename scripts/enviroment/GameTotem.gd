extends Node2D

var my_player_atached := 0
var other_player_atached := 0
var waiting_other_player := false

signal turn_input(state)
signal player_attach(message)
signal start_game

func _ready():
	$TotemState.visible = false

func totem_state(player_position: Vector2):
	if position.distance_to(player_position) < 100 and not waiting_other_player:
		$TotemState.visible = true
		
		if Input.is_action_just_released("start game"):
			if my_player_atached:
				my_player_atached = 0
			else:
				my_player_atached = 1
			
			emit_signal("turn_input", not my_player_atached)
			
			emit_signal("player_attach", "Player waiting for game: %d" % [my_player_atached])
	else:
		$TotemState.visible = false

func _process(_delta):
	if my_player_atached and other_player_atached:
		emit_signal("start_game")
	elif my_player_atached or other_player_atached:
		$TotemState.text = "pong\nwaiting"
	else:
		$TotemState.text = "pong\npress E"

func set_other_player_waiting(value):
	other_player_atached = value

func set_waiting_other_player(state):
	waiting_other_player = state
