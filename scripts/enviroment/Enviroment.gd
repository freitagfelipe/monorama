extends Control

signal send_message_to_other_player(text)
signal send_message(text)
signal is_receving_input(state)

func _ready():
	$GameTotem.get_node("TotemState").text = "pong\npress E"

func _process(_delta):
	if Input.is_action_just_pressed("text"):
		$CanvasLayer/Control/TextEdit.visible = true
		
		emit_signal("is_receving_input", false)

	if Input.is_action_just_pressed("exit text"):
		$CanvasLayer/Control/TextEdit.visible = false
		$CanvasLayer/Control/TextEdit.text = ""
		
		emit_signal("is_receving_input", true)
		
	if Input.is_action_just_pressed("send message"):
		emit_signal("send_message", $CanvasLayer/Control/TextEdit.text)
		emit_signal("send_message_to_other_player", "Message: %s" % [$CanvasLayer/Control/TextEdit.text])
		emit_signal("is_receving_input", true)
		
		$CanvasLayer/Control/TextEdit.visible = false
		$CanvasLayer/Control/TextEdit.text = ""
