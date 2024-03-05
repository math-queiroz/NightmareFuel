extends Node2D

@export var socre_up_audio_stream : AudioStream
@export var socre_down_audio_stream : AudioStream

@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func on_score_up():
	audio_player.set_stream(socre_up_audio_stream)
	audio_player.play()

func on_score_down():
	audio_player.set_stream(socre_down_audio_stream)
	audio_player.play()
