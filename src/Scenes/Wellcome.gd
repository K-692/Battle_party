extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ipAddrInput = $IpAddr
onready var ipAddrDisplay = $IpAddrDisplay
var ipAddr : String = "dummy"
# Called when the node enters the scene tree for the first time.

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Create_button_up():
	if MultiPlayer.create_server():
		ipAddrDisplay.text += '\nserver created'
	else:
		ipAddrDisplay.text += '\nserver failed'
		

func _on_Join_button_up():
	ipAddr = ipAddrInput.text
	ipAddrDisplay.text = ipAddr
	if MultiPlayer.create_clint(ipAddr):
		ipAddrDisplay.text += '\ncreate_clint created'
	else:
		ipAddrDisplay.text += '\nreate_clint failed'

func display(info, enter: bool):
	ipAddrDisplay.text += '\n%s' % 'enter' if enter else 'exit' 
	ipAddrDisplay.text = ' %s ' % info.name
	 


func _on_IpAddr_request_completion():
	_on_Join_button_up()




# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	ipAddrDisplay.text += '\nplayer connected %s' % id 
	
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)

func _player_disconnected(id):
	display(player_info.get(id), true)
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	# Only called on clients, not server. Will go unused; not useful here.
	ipAddrDisplay.text += '\nconnected_ok'
	

func _server_disconnected():
	# Server kicked us; show error and abort.
	ipAddrDisplay.text += '\n_server_disconnected'
	

func _connected_fail():
	# Could not even connect to server; abort.
	ipAddrDisplay.text += '\n_connected_fail'
	

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	display(info, true)

	# Call function to update lobby UI here
