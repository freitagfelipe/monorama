extends Control

var player_one_waiting := false
var player_two_waiting := false
var update_screen_thread = Thread.new()
var change_scene := false
var send_change_scene_message := false
var in_use

func _ready():
	if HostController.in_use:
		in_use = HostController
	else:
		in_use = ClientConnectionHandler
		
	update_screen_thread.start(self, "update_screen")

func _process(_delta):
	if player_one_waiting and player_two_waiting and not send_change_scene_message:
		send_change_scene_message = true
		
		in_use.send_message("Change to lobby")

func lobby_button_trigger():
	if not player_one_waiting:
		if not player_two_waiting:
			$WaitingOtherPlayerBeforeGo.visible = true
			$WaitingOtherPlayerBeforeGo/Animation.play("WaitingAnimation")
		
		in_use.send_message("Other player waiting")
		
	player_one_waiting = true

func update_screen():
	while not change_scene:
		var package = in_use.socket.get_var()
		
		if package:
			var data = package.split(" ")
			
			if package.begins_with("Other player waiting"):
				player_two_waiting = true
				
				if not player_one_waiting:
					$OtherPlayerWaiting.visible = true
					$OtherPlayerWaiting/Animation.play("OtherPlayerWaitingAnimation")
			elif package.begins_with("Change to lobby"):
				change_scene = true
				
				go_to_lobby()

func go_to_lobby():
	in_use.send_message("Change to lobby")
	
	var enviroment
	
	if HostController.in_use:
		enviroment = load("res://scenes/host/HostScene.tscn")
	else:
		enviroment = load("res://scenes/client/ClientScene.tscn")

	AfterGameController.is_after_game = true
	
	update_screen_thread.wait_to_finish()

	get_tree().change_scene_to(enviroment)
