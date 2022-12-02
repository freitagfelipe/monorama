extends Node2D

func show_message(message: String):
	if message.length() >= 73:
		message = message.substr(0, 73)
		
		message += "..."
	
	$NinePatchRect.visible = true
	$NinePatchRect/Text.text = message
	
	$Timer.start(5)

func on_timeout():
	$NinePatchRect.visible = false
	$NinePatchRect/Text.text = ""
