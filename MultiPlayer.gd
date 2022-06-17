extends Node

const SERVER_PORT = 6382
const MAX_PLAYERS = 6
var peer = NetworkedMultiplayerENet.new()
const MULTICAST_IP = '235.36.100.3'
const MULTICAST_PORT = 5640
var peerUdp := PacketPeerUDP.new()
var knownServers = {}

signal new_server

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

func create_ad() -> void:
	# ips 224.0.0.0 through 239.255.255.255
	is_server = true
	peerUdp.set_dest_address(MULTICAST_IP, MULTICAST_PORT)
	var  msg = {'name': 'hello form multicast', 'port': 5564}
	var json = to_json(msg).to_ascii()
	peerUdp.put_packet(json)
	
	
func listen_ad() -> void:
	is_client = true
	print_debug('listen ad')
	var local_ip = get_local_ip() 	
	peerUdp.listen(MULTICAST_PORT)	
	peerUdp.join_multicast_group(MULTICAST_IP, local_ip[1])	


func create_server() -> bool: 
	var res = peer.create_server(SERVER_PORT, MAX_PLAYERS) == OK
	get_tree().network_peer = peer
	return res

func create_clint(server_ip: String, server_port: int = SERVER_PORT) -> bool:
	var res = peer.create_client(server_ip, server_port) == OK
	get_tree().network_peer = peer
	return res
	
	
func _ready():
	pass
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
