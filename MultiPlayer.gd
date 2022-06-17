extends Node

const SERVER_PORT = 6382
const MAX_PLAYERS = 6
var peer = NetworkedMultiplayerENet.new()
const MULTICAST_IP = '235.36.100.3'
const MULTICAST_PORT = 5640
var peerUdp := PacketPeerUDP.new()
var knownServers = {}

signal new_server(server_info)
signal new_player(player_info)
signal disconnect_player(player_info)

var is_host = false

var is_server = false
var is_client = false
func get_local_ip() -> Array:
	var interfaces = IP.get_local_interfaces()
	var addrs  = IP.get_local_addresses()
	for inter in interfaces:
		if inter['friendly'] == 'WiFi' or inter['friendly'].begins_with('wlan'):
			for addr in inter['addresses']:
				if len(addr.split('.')) == 4:
					return [addr, inter['name']]
	return ['', '']

var  brodcast_msg = {name ='hello form multicast', port= 5564}


func create_ad() -> void:
	# ips 224.0.0.0 through 239.255.255.255
	is_server = true
	peerUdp.set_dest_address(MULTICAST_IP, MULTICAST_PORT)
	brodcast_msg['port'] = SERVER_PORT
	var json = to_json(brodcast_msg).to_ascii()
	peerUdp.put_packet(json)
	
	
func listen_ad() -> void:
	is_client = true
	print_debug('listen ad')
	var local_ip = get_local_ip() 	
	peerUdp.listen(MULTICAST_PORT)	
	peerUdp.join_multicast_group(MULTICAST_IP, local_ip[1])	

func listen_ad_close():
	peerUdp.close()

func create_server() -> bool:
	is_host = true
	var res = peer.create_server(SERVER_PORT, MAX_PLAYERS) == OK
	create_ad()	
	get_tree().network_peer = peer
	return res

func join():
	print_debug('listening..')
	listen_ad()

func create_client(server_ip: String, server_port: int = SERVER_PORT) -> bool:
	var res = peer.create_client(server_ip, server_port) == OK
	get_tree().network_peer = peer
	return res
	
func _signal_reciver():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	

# Player info, associate ID to data
var player_info = {}

# Info we send to other players
var _my_info = { name = "Johnson Magenta" }
var user_name = 'dummy'

func set_name(name: String):
	user_name = name
	_my_info.name = name
	brodcast_msg.name = name



func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	print('_player_connected', id)
	
	rpc_id(id, "register_player", _my_info)

func _player_disconnected(id):
	print('_player_disconnected', id)
	emit_signal("disconnect_player", player_info[id])
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	# Only called on clients, not server. Will go unused; not useful here.
	print('connected')
	pass

func _server_disconnected():
	# Server kicked us; show error and abort.
	print('server_disconnected')
	
	pass

func _connected_fail():
	# Could not even connect to server; abort.
	print('connected_fail')
	pass

remote func register_player(info):
	print('register', info)
	
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info
	# Call function to update lobby UI here
	emit_signal("new_player", info)

	
	
func _ready():
	_signal_reciver()
	
	
	
func _process(delta):
	if is_server:
		create_ad()
		
	elif is_client and peerUdp.get_available_packet_count() > 0: #RETURNS 0 in Android 11
		var serverIp = peerUdp.get_packet_ip()
		var serverPort = peerUdp.get_packet_port()
		var array_bytes = peerUdp.get_packet()
		
		if serverIp != '' and serverPort > 0:
			# We've discovered a new server! Add it to the list and let people know
			if not knownServers.has(serverIp):
				var serverMessage = array_bytes.get_string_from_ascii()
				var gameInfo = parse_json(serverMessage)
				gameInfo.ip = serverIp
				gameInfo.lastSeen = OS.get_unix_time()
				knownServers[serverIp] = gameInfo
				print_debug("New server found: %s - %s:%s" % [gameInfo.name, gameInfo.ip, gameInfo.port])
				emit_signal("new_server", gameInfo)
			# Update the last seen time
			else:
				var gameInfo = knownServers[serverIp]
				gameInfo.lastSeen = OS.get_unix_time()
