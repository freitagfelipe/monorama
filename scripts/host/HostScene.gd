extends Control

var main_character_node := preload("res://scenes/characters/MainCharacter.tscn")
var second_character_node := preload("res://scenes/characters/SecondCharacter.tscn")
var error_scene := preload("res://scenes/error/ErrorCreateTwoServers.tscn")
var has_player_connected := false
var my_player
var second_player

func _ready():
	if HostController.init_server() == -1:
		get_tree().change_scene_to(error_scene)
		
		return

	my_player = main_character_node.instance()
	second_player = second_character_node.instance()
	
	$Enviroment/PlayersSpawn.add_child(my_player)
	$Enviroment/PlayersSpawn.add_child(second_player)
	
	my_player.position = Vector2(548, 157)
	second_player.position = Vector2(539, -172)
	
	$WaitingAnimation.play("WaitingAnimation")
	
	second_player.get_node("AnimationPlayer").play("SleepingTextAnimation")
	
	HostController.connect("player_connected", self, "player_connected")
	$Enviroment.connect("send_message_to_other_player", HostController, "send_message")
	$Enviroment.connect("is_receving_input", my_player, "set_is_receving_input")
	$Enviroment.connect("send_message", my_player.get_node("Message"), "show_message")
	my_player.connect("player_move", HostController, "send_message")
	my_player.connect("player_animation", HostController, "send_message")
	
	var update_game_thread = Thread.new()
	
	update_game_thread.start(self, "update_game")

func player_connected():
	$CanvasLayer/WaitingText.visible = false
	$WaitingAnimation.stop()
	
	second_player.get_node("AnimationPlayer").stop()
	second_player.get_node("SleepingText").visible = false
	
	HostController.send_message("Player position: %s %s" % [my_player.position.x, my_player.position.y])
	
	has_player_connected = true
	
func update_game():
	while true:
		if has_player_connected:
			var package = HostController.socket.get_var()
			
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
