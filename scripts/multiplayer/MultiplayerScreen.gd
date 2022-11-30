extends Control

var main_scene := load("res://scenes/main/MainScene.tscn")
var server_button := preload("res://scenes/multiplayer/HostsIPButton.tscn")
var client_scene := preload("res://scenes/client/ClientScene.tscn")
var discover_server := DiscoverServersController.new()
var searching := true

func _ready():
	print("Starting multilpayer scene")
	
	$SearchingAnimation.play("SearchingAnimation")
	
	add_child(discover_server)
	
	discover_server.connect("finish_finding_severs", self, "add_new_servers_in_screen")
	
	discover_server.find_servers()

func connect_client_to_server(ip):
	print("Connecting client to server and changing the scene")
	
	ClientConnectionHandler.client_connect_to_server(ip)
	
	get_tree().change_scene_to(client_scene)

func add_new_servers_in_screen(servers):
	$SearchingText.visible = false
	$SearchingAnimation.stop()
	
	if servers.size() == 0:
		$NotFoundServer.visible = true
	
	for server in servers:
		var button = server_button.instance()
		
		button.text = server
		
		$ServersIP/VBoxContainer.add_child(button)
		
		button.connect("connect_client", self, "connect_client_to_server")
		
	searching = false

func try_again_button_trigger():
	if not searching:
		$SearchingText.visible = true
		$SearchingAnimation.play("SearchingAnimation")
		discover_server.find_servers()
		$NotFoundServer.visible = false

func back_button_trigger():
	print("Changing scene to main scene")
	
	get_tree().change_scene_to(main_scene)
