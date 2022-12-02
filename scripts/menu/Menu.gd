extends CanvasLayer

var is_menu_visible := false
var in_use

signal is_receving_input(state)
signal back_to_main_screen

func _init():
	if HostController.in_use:
		in_use = HostController
	else:
		in_use = ClientConnectionHandler

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		is_menu_visible = not is_menu_visible
	
	visible = is_menu_visible
	emit_signal("is_receving_input", not is_menu_visible)

func exit_button_trigger():
	emit_signal("back_to_main_screen")

func continue_button_trigger():
	is_menu_visible = false
