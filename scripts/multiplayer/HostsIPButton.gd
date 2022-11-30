extends Button

signal connect_client(ip)

func server_button_trigger():
	var ip := text
	
	emit_signal("connect_client", ip)
