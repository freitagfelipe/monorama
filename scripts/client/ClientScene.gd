extends Node2D

var main_character_node := preload("res://scenes/characters/MainCharacter.tscn")
var second_character_node := preload("res://scenes/characters/SecondCharacter.tscn")
var pong_scene := preload("res://scenes/pong/Pong.tscn")
var is_in_current_scene := true
var my_player: KinematicBody2D
var second_player: KinematicBody2D
var update_game_thread = Thread.new()

signal close_client_thread

func _ready():
	print("Starting client scene")
	
	my_player = main_character_node.instance()
	second_player = second_character_node.instance()
	
	$Enviroment/PlayersSpawn.add_child(my_player)
	$Enviroment/PlayersSpawn.add_child(second_player)
	
	if AfterGameController.is_after_game:
		my_player.position = Vector2(1648, 227)
		
		AfterGameController.is_after_game = false
	else:
		my_player.position = Vector2(544, -172)
	
	second_player.get_node("SleepingText").visible = false
	
	$Enviroment.connect("send_message_to_other_player", ClientConnectionHandler, "send_message")
	$Enviroment.connect("is_receving_input", my_player, "set_is_receving_input")
	$Enviroment.connect("send_message", my_player.get_node("Message"), "show_message")
	
	$Enviroment/GameTotem.connect("turn_input", my_player, "set_is_receving_input")
	$Enviroment/GameTotem.connect("start_game", self, "start_pong")
	$Enviroment/GameTotem.connect("player_attach", ClientConnectionHandler, "send_message")
	
	$Enviroment/MenuCanvas.connect("is_receving_input", my_player, "set_is_receving_input")
	$Enviroment/MenuCanvas.connect("back_to_main_screen", self, "back_to_main_screen")
	
	my_player.connect("player_move", ClientConnectionHandler, "send_message")
	my_player.connect("player_animation", ClientConnectionHandler, "send_message")
	my_player.connect("player_position", $Enviroment/GameTotem, "totem_state")
	
	ClientConnectionHandler.send_message("Player position: %s %s" % [my_player.position.x, my_player.position.y])
	
	connect("close_client_thread", self, "reset_client")
	
	update_game_thread.start(self, "update_game")

func update_game():
	while is_in_current_scene:
		var package = ClientConnectionHandler.socket.get_var()
		
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
				emit_signal("close_client_thread")
				
				ClientConnectionHandler.send_message("disconnect")
				
				return

func start_pong():
	ClientConnectionHandler.send_message("Start game")
	
	update_game_thread.wait_to_finish()
	
	get_tree().change_scene_to(pong_scene)

func reset_client():
	ClientConnectionHandler.in_use = false
	
	ClientConnectionHandler.socket = StreamPeerTCP.new()
	
	var main_screen = load("res://scenes/main/MainScene.tscn")
	
	get_tree().change_scene_to(main_screen)

func back_to_main_screen():
	print("Going to main screen")
	
	is_in_current_scene = false
	
	var main_screen = load("res://scenes/main/MainScene.tscn")
	
	ClientConnectionHandler.send_message("disconnect")
	ClientConnectionHandler.socket = StreamPeerTCP.new()
	
	get_tree().change_scene_to(main_screen)
