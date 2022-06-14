extends Actor


onready var _animated_sprite = $AnimatedSprite
onready var _shoot_animated_sprite = $ShootAnimatedSprite
onready var _jetPack = $FlingFire


signal player_fling(is_fling)

var bullet = preload("res://src/Objs/Bullet.tscn")

enum State {IDLE, FLY, CROUCH, RUN}
var state = State.IDLE

func character_behaviour() -> Vector2:
	if Input.is_action_pressed("jump_fly"):
		state = State.FLY
	elif Input.is_action_pressed("move_left"):
		state = State.IDLE
	elif Input.is_action_pressed("move_right"):
		state = State.IDLE
	elif Input.is_action_pressed("crouch"):
		state = State.CROUCH
	else:
		state = State.IDLE
		
	var x_dir = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		
	match state:
		State.IDLE:
			return Vector2(x_dir, 1.0)
				
		State.FLY:
			return Vector2(x_dir, -1.0)
			
		State.CROUCH:
			return Vector2(x_dir, 1.0)
			
				
		State.RUN:
			return Vector2(x_dir, 1.0)
			
	return Vector2(x_dir, 1.0)
	
	
func _physics_process(delta: float) -> void:
	#var direction: = get_direction()
	var direction: = character_behaviour()
	
	#if Input.is_action_pressed("jump_fly"):
	velocity = calculate_move_velocity(velocity, direction, speed)
	velocity = move_and_slide(velocity, Vector2.UP)
	update_animation(direction, velocity)
	process_shoot()
	update_animation(direction, velocity)

	
	
func process_shoot() -> void:
	if Input.is_action_pressed("shoot"):
		var b = bullet.instance()
		b.global_position = _shoot_animated_sprite.global_position
		if _animated_sprite.flip_h:
			b.speed.x *= -1
		get_parent().add_child(b)
	
	
func update_animation(direction: Vector2, velocity: Vector2) -> void:
	get_node("CollisionShape2D").disabled = false
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
		
		
	if abs(velocity.x) > 0 and is_on_floor() and not Input.is_action_pressed("crouch"):
		_animated_sprite.play("Run")
	else:
		if Input.is_action_pressed("crouch"):
			get_node("CollisionShape2D").disabled = true
			_animated_sprite.play("Crouch")
			if velocity.x < 0 and !_animated_sprite.flip_h:
				_animated_sprite.flip_h = true
			if velocity.x > 0 and _animated_sprite.flip_h:
				_animated_sprite.flip_h = false
		else:
			get_node("CollisionShape2D").disabled = false
			_animated_sprite.play("Idle") 
	
	if Input.is_action_pressed("shoot"):
		#_shoot_animated_sprite.stop()
		_shoot_animated_sprite.frame = 0
		_shoot_animated_sprite.play("shoot")
		#_shoot_animated_sprite

	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - 
		Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump_fly") else 1.0
	)
	
func calculate_move_velocity(
		linear_velocity : Vector2,
		direction: Vector2,
		speed: Vector2
	) -> Vector2:
	var new_velocity = linear_velocity
	if Input.is_action_pressed("crouch"):
		speed.x = 150
	new_velocity.x = speed.x * direction.x
	new_velocity.y += gravity * get_physics_process_delta_time()
	
	if direction.y == -1.0:
		new_velocity.y = speed.y * direction.y
		emit_signal("player_fling", true)
	else:
		emit_signal("player_fling", false)
	
	return new_velocity

