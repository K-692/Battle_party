extends Node2D

onready var cRad = get_node("ControllerRadius")
onready var cPos = get_node("ControllerPosition")
onready var radius = cRad.get_rect().size[0] / 2

signal controller_is_active(distance, degree)

func calculate():
	var distance = cPos.position.distance_to(Vector2.ZERO) / radius 
	var degree = cPos.position.angle_to_point(Vector2.ZERO)
	degree = rad2deg(degree)
	emit_signal("controller_is_active", distance, degree)

	

func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		self.visible = true	
		global_position = get_global_mouse_position()  #event.position
#		set_global_position(event.position)
	
	if event is InputEventScreenDrag:	
		cPos.position =  get_global_mouse_position() - global_position
#		cPos.position =  event.position - global_position
		cPos.position = cPos.position.clamped(radius)
		print('c ', cPos.position,  '  r ', cRad.position, '  s ', position, '  g ', global_position, ' e ', event.position)
		
		calculate()
		
	if Input.is_action_just_released("click"):
		cPos.position = Vector2(0, 0)
		self.visible = false
		calculate()
	
#	if event is InputEventMouseMotion:
#		print(event.position)
	
	
		
		


