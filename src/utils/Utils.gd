extends Node

func background_cover(tex: Node, containar_size):
#	var window_size = OS.get_window_size()
	var texture = tex.texture.get_size()
	var window_aspec = containar_size[0]/ containar_size[1]
	var texture_aspec = texture[0]/ texture[1]
	var scale = 1
	if window_aspec > texture_aspec:
		scale = containar_size[0] / texture[0]
		tex.margin_top = (containar_size[1]  - (texture[1] * scale)) / 2
		
	else:
		#match height
		scale = containar_size[1] / texture[1]
		tex.margin_left = (containar_size[0]  - (texture[0] * scale)) / 2
	
	tex.rect_scale = Vector2(scale, scale)
