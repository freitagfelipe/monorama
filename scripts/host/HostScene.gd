extends Control

var second_character_node := preload("res://scenes/characters/SecondCharacter.tscn")
var error_scene := preload("res://scenes/error/ErrorCreateTwoServers.tscn")
var has_player_connected := false
onready var my_player := $Character
onready var second_player := $SecondCharacter

func _ready():
	if HostController.init_server() == -1:
		get_tree().change_scene_to(error_scene)
		
		return
	
	$WaitingAnimation.play("WaitingAnimation")
	
	HostController.connect("player_connected", self, "player_connected")
	$Enviroment.connect("send_message_to_other_player", HostController, "send_message")
	$Enviroment.connect("is_receving_input", $Character, "set_is_receving_input")
	$Enviroment.connect("send_message", $Character/Message, "show_message")
	my_player.connect("player_move", HostController, "send_message")
	
	var update_game_thread = Thread.new()
	
	update_game_thread.start(self, "update_game")

func player_connected():
	$CanvasLayer/WaitingText.visible = false
	$WaitingAnimation.stop()
	
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
