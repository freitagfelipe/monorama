extends Node

var socket := StreamPeerTCP.new()
var in_use := false

func client_connect_to_server(ip):
	print("Client connecting to the server with ip: ", ip)
	
	if socket.connect_to_host(ip, 1126) != OK:
		print("Failed to connect with the server")
		
	in_use = true

func send_message(message):
	print("Sending message: %s" % [message])
	
	socket.put_var(message)
