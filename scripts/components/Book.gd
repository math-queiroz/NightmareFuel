extends Area2D

@export var book_open_sound : AudioStream
@export var book_close_sound : AudioStream
@export var book_next_page_sound : AudioStream
@export var book_prev_page_sound : AudioStream

@onready var level_node : Level = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1) as Level

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed and level_node.held_object == null:
		if(%Sprite2DBook.visible):
			%Sprite2DOverlay.set_visible(true)
			%Sprite2DBook.set_visible(false)
			_play_audio(book_open_sound)
		else:
			%Sprite2DOverlay.set_visible(false)
			%Sprite2DBook.set_visible(true)
			_play_audio(book_close_sound)

func _play_audio(stream) -> void:
	%AudioStreamPlayerBook.set_stream(stream)
	%AudioStreamPlayerBook.set_pitch_scale(randf_range(0.8,1.1))
	%AudioStreamPlayerBook.play()
