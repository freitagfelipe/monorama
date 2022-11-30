extends Node

var tcp := StreamPeerTCP.new()

func client_connect_to_server(ip):
	print("Client connecting to the server with ip: ", ip)
	
	if tcp.connect_to_host(ip, 1126) != OK:
		print("Failed to connect with the server")

func send_message(message):
	print("Sending message: %s" % [message])
	
	tcp.put_var(message)
