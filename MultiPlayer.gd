extends Node

const SERVER_PORT = 6382
const MAX_PLAYERS = 6
var peer = NetworkedMultiplayerENet.new()


func create_server() -> bool: 
	var res = peer.create_server(SERVER_PORT, MAX_PLAYERS) == OK
	get_tree().network_peer = peer
	return res

func create_clint(server_ip: String, server_port: int = SERVER_PORT) -> bool:
	var res = peer.create_client(server_ip, server_port) == OK
	get_tree().network_peer = peer
	return res
	
