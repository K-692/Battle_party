extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var ipAddrInput = $IpAddr
onready var ipAddrDisplay = $IpAddrDisplay
var ipAddr : String = "dummy"
# Called when the node enters the scene tree for the first time.
export(String, FILE, "*.tscn,*.scn") var lobi_scene: String



func _fix_background():
	Utils.background_cover($TextureRect, OS.get_window_size())
	

func _ready():
	_fix_background()
	get_tree().get_root().connect("size_changed", self, "_fix_background")
	ipAddrDisplay.text += "\n%s -> %s" % MultiPlayer.get_local_ip() 
	 
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Create_button_up():
	if ipAddrInput.text == '':
		return
	MultiPlayer.set_name(ipAddrInput.text)
	if MultiPlayer.create_server():
		ipAddrDisplay.text += '\nserver created'
		get_tree().change_scene(lobi_scene)
	else:
		ipAddrDisplay.text += '\nserver failed'
		

func _on_Join_button_up():
	if ipAddrInput.text == '':
		return
	MultiPlayer.set_name(ipAddrInput.text)
	MultiPlayer.join()
	get_tree().change_scene(lobi_scene)
	

func display(info, enter: bool):
	ipAddrDisplay.text += '\n%s' % 'enter' if enter else 'exit' 
	ipAddrDisplay.text = ' %s ' % info.name
	 


func _on_IpAddr_request_completion():
	_on_Join_button_up()
