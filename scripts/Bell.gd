extends Area2D

@onready var audio_player = %AudioStreamPlayerBell

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not audio_player.playing:
			audio_player.set_pitch_scale(randf_range(1.0,1.1))
			audio_player.play()
