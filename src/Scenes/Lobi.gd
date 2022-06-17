extends Control


func _fix_background():
	Utils.background_cover($TextureRect, OS.get_window_size())


onready var server_list_node = $ServerFinder/Panel/VBoxContainer

var server_btn = preload("res://src/components/Button.tscn")

func _ready():
	_fix_background()
	get_tree().get_root().connect("size_changed", self, "_fix_background")
	MultiPlayer.connect("new_server", self, "_new_server")
	MultiPlayer.connect("new_player", self, "_new_player")
	
	if MultiPlayer.is_host:
		$ServerFinder.queue_free()
		
	
func _join(info):
	MultiPlayer.create_client(info.ip, info.port)
	$ServerFinder.queue_free()
	print_debug('joingingfgdksadfjklo')
	MultiPlayer.listen_ad_close()
	
	
func _new_server(info):
	print_debug('_new_server', info)
	var join = server_btn.instance()
	join.connect("pressed", self, "_join", [info])
	join.text = info.name
	server_list_node.add_child(join)

	
func _new_player(info):
	var player = Label.new()
	player.text = info.name
	$HBoxContainer/Panel/Players.add_child(player)


func _on_LineEdit_text_entered(new_text):
	$HBoxContainer/Panel2/LineEdit.text = ''
	var id = get_tree().get_network_unique_id()
	rpc("sent_msg", id, new_text)

sync func sent_msg(id, msg):
	var mlable = Label.new()
	var sender = ''
	if id == get_tree().get_network_unique_id():
		sender = MultiPlayer.user_name
	else:
		sender = MultiPlayer.player_info[id].name
	
	mlable.text = '[' + sender + ']: '+ msg
	$HBoxContainer/Panel2/VBoxContainer.add_child(mlable)
	
