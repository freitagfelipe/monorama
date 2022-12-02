extends Control

var main_character_node := preload("res://scenes/characters/MainCharacter.tscn")
var second_character_node := preload("res://scenes/characters/SecondCharacter.tscn")
var pong_scene := preload("res://scenes/pong/Pong.tscn")
var error_scene := preload("res://scenes/error/ErrorCreateTwoServers.tscn")
var is_in_current_scene := true
var has_player_connected := false
var my_player
var second_player: KinematicBody2D
var update_game_thread = Thread.new()

signal close_host_thread

func _ready():
	if not AfterGameController.is_after_game and HostController.init_server() == -1:
		get_tree().change_scene_to(error_scene)
		
		return
	
	$WaitingAnimation.play("WaitingAnimation")

	my_player = main_character_node.instance()
	second_player = second_character_node.instance()
	
	$Enviroment/PlayersSpawn.add_child(my_player)
	$Enviroment/PlayersSpawn.add_child(second_player)
	
	if AfterGameController.is_after_game:
		my_player.position = Vector2(1520, 229)
		second_player.position = Vector2(1648, 227)
		
		AfterGameController.is_after_game = false
		
		player_connected()
	else:
		$Enviroment/GameTotem.set_waiting_other_player(true)
		my_player.position = Vector2(548, 157)
		second_player.position = Vector2(544, -172)
	
	second_player.get_node("AnimationPlayer").play("SleepingTextAnimation")
	
	HostController.connect("player_connected", self, "player_connected")
	
	$Enviroment.connect("send_message_to_other_player", HostController, "send_message")
	$Enviroment.connect("is_receving_input", my_player, "set_is_receving_input")
	$Enviroment.connect("send_message", my_player.get_node("Message"), "show_message")
	
	$Enviroment/GameTotem.connect("turn_input", my_player, "set_is_receving_input")
	$Enviroment/GameTotem.connect("player_attach", HostController, "send_message")
	$Enviroment/GameTotem.connect("start_game", self, "start_pong")
	
	$Enviroment/MenuCanvas.connect("is_receving_input", my_player, "set_is_receving_input")
	$Enviroment/MenuCanvas.connect("back_to_main_screen", self, "back_to_main_screen")
	
	my_player.connect("player_move", HostController, "send_message")
	my_player.connect("player_animation", HostController, "send_message")
	my_player.connect("player_position", $Enviroment/GameTotem, "totem_state")
	
	connect("close_host_thread", self, "reset_lobby")
	
	update_game_thread.start(self, "update_game")

func player_connected():
	print("Other player conected")
	
	$CanvasLayer/WaitingText.visible = false
	$WaitingAnimation.stop()
	
	$Enviroment/GameTotem.set_waiting_other_player(false)
	
	second_player.get_node("AnimationPlayer").stop()
	second_player.get_node("SleepingText").visible = false
	
	HostController.send_message("Player position: %s %s" % [my_player.position.x, my_player.position.y])
	
	has_player_connected = true
	
func update_game():
	while is_in_current_scene:
		if has_player_connected:
			var package = HostController.socket.get_var()
			
			if package:
				var data = package.split(" ")
				
				if package.begins_with("Player position"):
					second_player.set_deferred("position", Vector2(float(data[2]), float(data[3])))
				elif package.begins_with("Message"):
					data.remove(0)
		
					second_player.get_node("Message").show_message(data.join(" "))
				elif package.begins_with("Player animation"):
					data.remove(0)
					data.remove(0)
					
					second_player.get_node("Sprite").play(data.join(" "))
				elif package.begins_with("Player waiting for game"):
					$Enviroment/GameTotem.set_other_player_waiting(int(data[4]))
				elif package.begins_with("Start game"):
					is_in_current_scene = false
				elif package.begins_with("disconnect"):
					emit_signal("close_host_thread")
					
					return

func start_pong():
	print("Starting pong")
	
	is_in_current_scene = false
	
	HostController.send_message("Start game")

	update_game_thread.wait_to_finish()
	
	get_tree().change_scene_to(pong_scene)

func reset_lobby():
	update_game_thread.wait_to_finish()
	
	HostController.init_server()
	
	$WaitingAnimation.play("WaitingAnimation")
	
	$CanvasLayer/WaitingText.visible = true
	
	$Enviroment/GameTotem.set_waiting_other_player(true)
	
	has_player_connected = false
	
	second_player.get_node("SleepingText").visible = true
	second_player.get_node("AnimationPlayer").play("SleepingTextAnimation")
	second_player.position = Vector2(544, -172)
	
	HostController.init_server()
	
	HostController.socket = null
	
	update_game_thread = Thread.new()
	
	update_game_thread.start(self, "update_game")

func back_to_main_screen():
	print("Going to main screen")
	
	is_in_current_scene = false
	
	var main_screen = load("res://scenes/main/MainScene.tscn")
	
	if not HostController.waiting_second_player:
		HostController.send_message("disconnect")
		
		HostController.socket = null
	
	HostController.in_use = false
	HostController.waiting_second_player = false
	
	get_tree().change_scene_to(main_screen)
