extends Actor


onready var _animated_sprite = $AnimatedSprite
onready var _shoot_animated_sprite = $ShootAnimatedSprite

var bullet = preload("res://src/Objs/Bullet.tscn")


func _physics_process(delta: float) -> void:
	var direction: = get_direction()
	velocity = calculate_move_velocity(velocity, direction, speed)
	velocity = move_and_slide(velocity, Vector2.UP)
	update_animation(direction, velocity)
	if Input.is_action_just_pressed("gg"):
		_animated_sprite.play("Run")
	
	
	process_shoot()
	
	
func process_shoot() -> void:
	if Input.is_action_pressed("shoot"):
		var b = bullet.instance()
		b.global_position = _shoot_animated_sprite.global_position
		get_parent().add_child(b)
	
func update_animation(direction: Vector2, velocity: Vector2) -> void:
	if direction.y == -1.0:
		_animated_sprite.play("Jump")
	if velocity.x < 0 and !_animated_sprite.flip_h:
		_animated_sprite.flip_h = true
	if velocity.x > 0 and _animated_sprite.flip_h:
		_animated_sprite.flip_h = false
	if abs(velocity.x) > 0:
		_animated_sprite.play("Run")
	else:
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
		-1.0 if Input.is_action_just_pressed("jump_fly") and is_on_floor() else 1.0
	)
	
func calculate_move_velocity(
		linear_velocity : Vector2,
		direction: Vector2,
		speed: Vector2
	) -> Vector2:
	var new_velocity = linear_velocity
	new_velocity.x = speed.x * direction.x
	new_velocity.y += gravity * get_physics_process_delta_time()
	
	if direction.y == -1.0:
		new_velocity.y = speed.y * direction.y
	return new_velocity
