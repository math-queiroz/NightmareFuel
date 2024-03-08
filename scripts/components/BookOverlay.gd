@tool

extends Control

const bookmaked_page = 5

@export var page : int = 0 : set = _set_page
@export var book_pages : BookPages
@export var book_page_next_audio_stream : AudioStream
@export var book_page_prev_audio_stream : AudioStream

@onready var last_index : int = int(float(len(book_pages.pages)/2.0))
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer

func _set_page(value) -> void:
	print_debug("Called!")
	if value < 0 or value >= last_index or value == page:
		return
	$PageLeft.set_text(book_pages.pages[value*2])
	$PageRight.set_text(book_pages.pages[value*2+1] if value*2+1 < len(book_pages.pages) else "")
	audio_player.set_pitch_scale(randf_range(0.8, 1.2))
	if not audio_player.playing:
		audio_player.play()
	page = value

func _ready() -> void:
	$PageLeft.set_text(book_pages.pages[0])
	$PageRight.set_text(book_pages.pages[1])

func goto_page(idx) -> void:
	if not audio_player.playing:
		audio_player.set_stream(book_page_next_audio_stream)
	page = idx

func next_page() -> void:
	if not audio_player.playing:
		audio_player.set_stream(book_page_next_audio_stream)
	page += 1

func prev_page() -> void:
	if not audio_player.playing:
		audio_player.set_stream(book_page_prev_audio_stream)
	page -= 1

func goto_bookmark() -> void:
	if not audio_player.playing:
		audio_player.set_stream(book_page_next_audio_stream)
	page = bookmaked_page
