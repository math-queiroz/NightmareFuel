extends Draggable
class_name IceCube

var melt_state : int = -1
var melt_sprites = [
	preload("res://sprites/ice_cube_2.png"),
	preload("res://sprites/ice_cube_3.png")
]

func melt():
	melt_state += 1
	if (melt_state >= len(melt_sprites)):
		queue_free()
	else:
		$Sprite2D.set_texture(melt_sprites[melt_state])
