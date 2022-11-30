extends Node

var tcp := TCP_Server.new()
var udp_watcher := PacketPeerUDP.new()
var waiting_second_player := true
var socket: StreamPeerTCP

signal player_connected

func init_server():
	print("Initing server")
	
	var result_udp_watcher = udp_watcher.listen(7777, "0.0.0.0")
	var result_tcp_listen = tcp.listen(1126, "0.0.0.0")
	
	if result_tcp_listen != OK or result_udp_watcher != OK:
		return -1
		
	var responding_broadcast_thread := Thread.new()
	var recieve_connection_thread := Thread.new()
	
	responding_broadcast_thread.start(self, "responding_broadcast")
	recieve_connection_thread.start(self, "recieve_connection")

func responding_broadcast():
	print("Responding broadcast")
	
	while waiting_second_player:
		if udp_watcher.wait() == OK:
			if udp_watcher.get_var() == "Searching fliper server":
				print("Responding broadcast")
				
				udp_watcher.set_dest_address(udp_watcher.get_packet_ip(), udp_watcher.get_packet_port())
				udp_watcher.put_var("Found fliper server")
				
	print("Finished responding broadcast")
			
func recieve_connection():
	print("Waiting connections")
	
	while waiting_second_player:
		var socket_response = tcp.take_connection()
			
		if socket_response:
			waiting_second_player = false
			
			socket = socket_response
			
			emit_signal("player_connected")
			
	print("Connected")
	
func send_message(message):
	if not socket:
		return
	
	print("Sending message: %s" % [message])
	
	socket.put_var(message)
