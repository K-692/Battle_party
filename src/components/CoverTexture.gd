extends TextureRect
tool


func _fix_texture_size():
	if texture:
		var area = get_parent_area_size()
		var texture_size = texture.get_size()
		if area[1] == 0:
			return
		var area_aspec = area[0]/ area[1]
		var texture_aspec = texture_size[0]/ texture_size[1]
		var scale = 1
		if area_aspec > texture_aspec:
			scale = area[0] / texture_size[0]
			margin_top = (area[1]  - (texture_size[1] * scale)) / 2
			
		else:
			#match height
			scale = area[1] / texture_size[1]
			margin_left = (area[0]  - (texture_size[0] * scale)) / 2
		
		rect_scale = Vector2(scale, scale)

func _ready():
	_fix_texture_size()
	get_tree().get_root().connect("size_changed", self, "_fix_texture_size")
