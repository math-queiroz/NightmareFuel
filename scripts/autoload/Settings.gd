extends Node

signal boolean_changed(setting, value)

var hide_book_on_new_customeer : bool = true : set = set_hide_book_on_new_customeer, get = get_hide_book_on_new_customeer

func get_hide_book_on_new_customeer() -> bool:
	return hide_book_on_new_customeer

func set_hide_book_on_new_customeer(value: bool) -> void:
	boolean_changed.emit("hide_book_on_new_customeer", value)
	hide_book_on_new_customeer = value
