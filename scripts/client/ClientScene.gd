extends Node2D

var main_character_node := preload("res://scenes/characters/MainCharacter.tscn")
var second_character_node := preload("res://scenes/characters/SecondCharacter.tscn")
var my_player
var second_player

func _ready():
	print("Starting client scene")
	
	my_player = main_character_node.instance()
	second_player = second_character_node.instance()
	
	$Enviroment/PlayersSpawn.add_child(my_player)
	$Enviroment/PlayersSpawn.add_child(second_player)
	
	my_player.position = Vector2(539, -172)
	
	second_player.get_node("SleepingText").visible = false
	my_player.connect("player_move", ClientConnectionHandler, "send_message")
	my_player.connect("player_animation", ClientConnectionHandler, "send_message")
	$Enviroment.connect("send_message_to_other_player", ClientConnectionHandler, "send_message")
	$Enviroment.connect("is_receving_input", $Character, "set_is_receving_input")
	$Enviroment.connect("send_message", $Character/Message, "show_message")
	
	ClientConnectionHandler.send_message("Player position: %s %s" % [my_player.position.x, my_player.position.y])
	
	var update_game_thread = Thread.new()
	
	update_game_thread.start(self, "update_game")

func update_game():
	while true:
		var package = ClientConnectionHandler.tcp.get_var()
		
		if package:
			var data = package.split(" ")
			
			if package.begins_with("Player position"):
				second_player.position.x = int(data[2])
				second_player.position.y = int(data[3])
			elif package.begins_with("Message"):
				data.remove(0)
		
				second_player.get_node("Message").show_message(data.join(" "))
			elif package.begins_with("Player animation"):
				data.remove(0)
				data.remove(0)
				
				second_player.get_node("Sprite").play(data.join(" "))
