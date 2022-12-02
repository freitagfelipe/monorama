extends Control

signal send_message_to_other_player(text)
signal send_message(text)
signal is_receving_input(state)

func _ready():
	$GameTotem.get_node("TotemState").text = "pong\npress E"

func _process(_delta):
	if Input.is_action_just_pressed("text"):
		var text_state = not $TextInputCanvas/Control/TextInput.visible
		
		$TextInputCanvas/Control/TextInput.visible = text_state
		$TextInputCanvas/Control/TextInput.text = ""
		
		emit_signal("is_receving_input", not text_state)
		
	if Input.is_action_just_pressed("send message"):
		if $TextInputCanvas/Control/TextInput.text.length() != 0:
			emit_signal("send_message", $TextInputCanvas/Control/TextInput.text)
			emit_signal("send_message_to_other_player", "Message: %s" % [$TextInputCanvas/Control/TextInput.text])
		
		emit_signal("is_receving_input", true)
		
		$TextInputCanvas/Control/TextInput.visible = false
		$TextInputCanvas/Control/TextInput.text = ""
