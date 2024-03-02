extends Area2D

const ice_cube_scene : PackedScene = preload("res://components/ice_cube.tscn")
const ice_cube_grab_sounds : Array[AudioStream] = [
	preload("res://sounds/glass3.wav"),
	preload("res://sounds/glass2.wav"),
	preload("res://sounds/glass4.wav")
]

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Melt previous existing cubes
		for existing_cube in %IceCubePool.get_children():
			existing_cube.melt()
		# Instantiate cube and hold it
		var cube = ice_cube_scene.instantiate()
		cube.global_position = global_position
		%IceCubePool.add_child(cube)
		cube.is_held_echo = true
		cube.is_held = true
		_play_ice_sound()

func _on_body_entered(body):
	if body is IceCube and not body.is_held:
		body.queue_free()
		_play_ice_sound(true)

func _play_ice_sound(drop = false):
		%AudioStreamPlayerIceTray.set_pitch_scale(randf_range(0.9,1.1))
		%AudioStreamPlayerIceTray.set_stream(ice_cube_grab_sounds[0 if drop else randi_range(1,2)])
		%AudioStreamPlayerIceTray.play()
