extends Control

var my_player: KinematicBody2D
var second_player: KinematicBody2D
var update_game_thread = Thread.new()
var in_game := true
var in_use

func _ready():
	if HostController.in_use:
		print("Pong with HostController")
		
		in_use = HostController
		
		my_player = $PlayerOne
		second_player = $PlayerTwo
		
		$Ball.connect("ball_move", HostController, "send_message")
		$Ball.connect("score", HostController, "send_message")
		$Ball.connect("score", self, "update_score")
	else:
		print("Pong with ClientConnectionHandler")
		
		in_use = ClientConnectionHandler
		
		my_player = $PlayerTwo
		second_player = $PlayerOne
		
		$Ball.set_physics_process(false)
		
	second_player.set_physics_process(false)
	
	my_player.connect("player_move", in_use, "send_message")
	
	update_game_thread.start(self, "update_game")
	
func update_game():
	while in_game:
		var package = in_use.socket.get_var()
		
		if package:
			var data = package.split(" ")
			
			if package.begins_with("Pong player position"):
				print("Pong player position: ", data)
				
				second_player.set_deferred("position", Vector2(float(data[3]), float(data[4])))
		
			elif ClientConnectionHandler.in_use and package.begins_with("Ball position"):
				print("Ball position: ", data)
				
				$Ball.set_deferred("position", Vector2(float(data[2]), float(data[3])))
			elif package.begins_with("Player score"):
				var player = int(data[2])
				var old_score = $Score.text.split(" x ")
				var new_score = [int(old_score[0]), int(old_score[1])]
				
				if HostController.in_use:
					if player == 1:
						new_score[0] += 1
					else:
						new_score[1] += 1
				else:
					if player == 1:
						new_score[0] += 1
					else:
						new_score[1] += 1

				$Score.text = "%d x %d" % [new_score[0], new_score[1]]
			elif package.begins_with("Finish game"):
				var score = $Score.text.split(" x ")
				
				in_game = false
	
				if HostController.in_use:
					go_to_after_game(int(score[0]))
				else:
					go_to_after_game(int(score[1]))

func _process(_delta):
	var score = $Score.text.split(" x ")
	
	if HostController.in_use and int(score[0]) >= 7:
		HostController.send_message("Finish game")
	elif ClientConnectionHandler.in_use and int(score[1]) >= 7:
		ClientConnectionHandler.send_message("Finish game")

func update_score(message):
	var data = message.split(" ")
	
	var player = int(data[2])
	var old_score = $Score.text.split(" x ")
	var new_score = [int(old_score[0]), int(old_score[1])]
	
	if player == 1 and HostController.in_use:
		new_score[0] += 1
	else:
		new_score[1] += 1

	$Score.text = "%d x %d" % [new_score[0], new_score[1]]

func go_to_after_game(my_score):
	in_use.send_message("Finish game")
	
	var after_game
	
	if my_score >= 7:
		after_game = load("res://scenes/after game/Winner.tscn")
	else:
		after_game = load("res://scenes/after game/Loser.tscn")
	
	update_game_thread.wait_to_finish()
	
	get_tree().change_scene_to(after_game)
