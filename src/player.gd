extends Actor


onready var _animated_sprite = $AnimatedSprite
onready var _shoot_animated_sprite = $Position2D/ShootAnimatedSprite
onready var _jetPack = $FlingFire
onready var _jetPackCap = $ProgressBar

signal player_fling(is_fling)

var bullet = preload("res://src/Objs/Bullet.tscn")

enum State {IDLE, FLY, CROUCH, RUN}
var state = State.IDLE

var jet_pack_capacity = 100

func character_behaviour() -> Vector2:

	if Input.get_action_strength("jump_fly") > 0.42 and jet_pack_capacity > 0:
		state = State.FLY
		jet_pack_capacity -= 0.3
		if jet_pack_capacity < 0:
			jet_pack_capacity = 0.0
	else:
		
		jet_pack_capacity += 0.05
		if jet_pack_capacity > 100:
			jet_pack_capacity = 100
			
		if Input.is_action_pressed("move_left"):
			state = State.IDLE
		elif Input.is_action_pressed("move_right"):
			state = State.IDLE
		elif Input.get_action_strength("crouch") > 0.42:
			state = State.CROUCH
		else:
			state = State.IDLE
	
	var x_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
	match state:
		State.IDLE:
			return Vector2(x_dir, 1.0)
				
		State.FLY:
			return Vector2(x_dir, -1.0 if jet_pack_capacity > 0 else 1.0)
			
		State.CROUCH:
			x_dir *= 0.5
			return Vector2(x_dir, 1.0)
			
				
		State.RUN:
			return Vector2(x_dir, 1.0)
			
	return Vector2(x_dir, 1.0)
	
func camera_calibaration():
	pass
	
	
func _physics_process(delta: float) -> void:
	#var direction: = get_direction()
	
	var direction: = character_behaviour()
	
	#if Input.is_action_pressed("jump_fly"):
	velocity = calculate_move_velocity(velocity, direction, speed)
	velocity = move_and_slide(velocity, Vector2.UP)
	
	_update_look_at()
	
	#update_animation(direction, velocity)
#	process_shoot()
	update_animation(direction, velocity)

	
func _update_look_at():
	var x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	var vec = Vector2(x, y)
	if vec == Vector2.ZERO:
		return
		
	$Position2D.rotation = vec.angle()
	if vec.distance_to(Vector2.ZERO) == 1:
		process_shoot(vec)
	
	
func process_shoot(vec: Vector2) -> void:
	var b = bullet.instance()
	b.global_position = _shoot_animated_sprite.global_position
	b.rotation = vec.angle()
	b.speed = vec.normalized() * 1000
#	if _animated_sprite.flip_h:
#		b.speed.x *= -1
	get_parent().add_child(b)
	_shoot_animated_sprite.frame = 0
	_shoot_animated_sprite.play("shoot")
	
	
func update_animation(direction: Vector2, velocity: Vector2) -> void:
	get_node("CollisionShape2D").disabled = false
	_jetPackCap.value = jet_pack_capacity
#	if direction.y == 1.0:
#		_animated_sprite.play("Jump")
	if velocity.x < 0 and !_animated_sprite.flip_h:
		_shoot_animated_sprite.flip_h = true
		_jetPack.position.x = 4
		if _shoot_animated_sprite.position.x > 0: 
			_shoot_animated_sprite.position.x *= -1
		_animated_sprite.flip_h = true
	if velocity.x > 0 and _animated_sprite.flip_h:
		_shoot_animated_sprite.flip_h = false
		_jetPack.position.x = 0
		if _shoot_animated_sprite.position.x < 0: 
			_shoot_animated_sprite.position.x *= -1
		_animated_sprite.flip_h = false
		
		
	if abs(velocity.x) > 0 and is_on_floor() and not Input.get_action_strength("crouch") > 0.42:
		_animated_sprite.play("Run")
		var strain = abs(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"))
		_animated_sprite.speed_scale = range_lerp(strain, 0.0, 1.0, 0.5, 1.0)
	else:
		if Input.get_action_strength("crouch") > 0.42:
			get_node("CollisionShape2D").disabled = true
			_animated_sprite.play("Crouch")
			if velocity.x < 0 and !_animated_sprite.flip_h:
				_animated_sprite.flip_h = true
			if velocity.x > 0 and _animated_sprite.flip_h:
				_animated_sprite.flip_h = false
		else:
			get_node("CollisionShape2D").disabled = false
			_animated_sprite.play("Idle") 
	
#	if Input.is_action_pressed("shoot"):
		#_shoot_animated_sprite.stop()
#		_shoot_animated_sprite.frame = 0
#		_shoot_animated_sprite.play("shoot")
		#_shoot_animated_sprite

	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - 
		Input.get_action_strength("move_left"),
		-1.0 if Input.get_action_strength("jump_fly") > 0.42 else 1.0
	)
	
func calculate_move_velocity(
		linear_velocity : Vector2,
		direction: Vector2,
		speed: Vector2
	) -> Vector2:
	var new_velocity = linear_velocity
#	if Input.is_action_pressed("crouch"):
#		speed.x = 150
	new_velocity.x = speed.x * direction.x
	new_velocity.y += gravity * get_physics_process_delta_time()
	
	if direction.y == -1.0:
		new_velocity.y = speed.y * direction.y
		emit_signal("player_fling", true)
	else:
		emit_signal("player_fling", false)
	
	return new_velocity



func _on_Joystick_controller_is_active(distance, degree) -> void:
	$Position2D.rotation_degrees = degree
