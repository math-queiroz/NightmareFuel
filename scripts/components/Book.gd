extends Area2D

@export var book_open_sound : AudioStream
@export var book_close_sound : AudioStream
@export var book_next_page_sound : AudioStream
@export var book_prev_page_sound : AudioStream

@onready var level_node : Level = get_tree().get_current_scene() as Level
@onready var book_overlay : Control = %BookOverlay
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayerBook

func set_open(value: bool, silent: bool = false) -> void:
	book_overlay.set_visible(value)
	$Sprite2DBook.set_visible(!value)
	if not silent:
		_play_audio(book_open_sound if value else book_close_sound)

func _on_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT \
		and event.pressed and level_node.held_object == null:
		set_open($Sprite2DBook.visible)

func _play_audio(stream) -> void:
	audio_player.set_stream(stream)
	audio_player.set_pitch_scale(randf_range(0.8,1.1))
	if audio_player.is_inside_tree():
		audio_player.play()
