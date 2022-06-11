extends KinematicBody2D


export var speed: = Vector2(1, 0)

func _physics_process(delta: float) -> void:
	
	position += speed * delta
	 







