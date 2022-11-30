class_name DiscoverServersController

extends Node

var socket = PacketPeerUDP.new()

signal finish_finding_severs(servers_ip)

func _init():
	print("Initing discover servers!")
	
	socket.set_dest_address("255.255.255.255", 7777)
	
	socket.set_broadcast_enabled(true)
	
	var thread = Thread.new()
	
	thread.start(self, "find_servers")
	

func find_servers():
	print("Start finding servers")

	var timer = Timer.new()
	
	add_child(timer)
	
	timer.one_shot = true
	
	timer.start(5)
	
	var servers_ip = []
	
	while timer.time_left != 0:
		socket.put_var("Searching fliper server")
		
		var response = socket.get_var()
		
		if response == "Found fliper server" and not servers_ip.has(socket.get_packet_ip()):
			servers_ip.push_back(socket.get_packet_ip())
			
			print("Found flipler server!")
			
		yield(get_tree().create_timer(0.5), "timeout")
		
	print("Finish finding servers")
	
	remove_child(timer)

	emit_signal("finish_finding_severs", servers_ip)
