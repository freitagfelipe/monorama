extends Control

var multiplayer_scene := preload("res://scenes/multiplayer/Multiplayer.tscn")
var host_scene := preload("res://scenes/host/HostScene.tscn")

func exit_button_trigger():
	print("Exiting game")
	
	get_tree().quit()

func multiplayer_button_trigger():
	print("Changing to multiplayer scene")
	
	get_tree().change_scene_to(multiplayer_scene)

func host_server_button_trigger():
	print("Starting host")
	
	get_tree().change_scene_to(host_scene)
