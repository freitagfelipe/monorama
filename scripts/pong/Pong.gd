extends Control

var my_player: KinematicBody2D
var second_player: KinematicBody2D
var update_game_thread = Thread.new()
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
	while true:
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
				
				if player == 1 and HostController.in_use:
					new_score[0] += 1
				else:
					new_score[1] += 1

				$Score.text = "%d x %d" % [new_score[0], new_score[1]]

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
