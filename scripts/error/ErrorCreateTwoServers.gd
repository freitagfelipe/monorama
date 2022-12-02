extends Control

func back_to_main_screen_button_trigger():
	var main_screen = load("res://scenes/main/MainScene.tscn")
	
	get_tree().change_scene_to(main_screen)
