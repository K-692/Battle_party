extends Position2D


onready var left_fire = $left
onready var right_fire = $right


func _on_player_player_fling(is_fling: bool) -> void:
	if is_fling:
		right_fire.play("fly")
		left_fire.play("fly")
	else:
		left_fire.play("idle")
		right_fire.play("idle")
