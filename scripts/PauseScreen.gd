extends Control

@onready var main_menu_scene : PackedScene = load("res://scenes/main_menu.tscn")

func _unhandled_input(event):
	if event.is_action("ui_cancel") and event.pressed:
		if get_tree().is_paused(): unpause()
		else: pause()

func pause():
	get_tree().paused = true
	set_visible(true)
	#%ButtonBookNextPage.set_visible(false)

func unpause():
	get_tree().paused = false
	set_visible(false)
	#%ButtonBookNextPage.set_visible(true)

func restart():
	get_tree().reload_current_scene()
	get_tree().paused = false

func main_menu():
	get_tree().change_scene_to_packed(main_menu_scene)
	get_tree().paused = false

func quit_game():
	get_tree().quit()
