extends Area2D

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if(%Sprite2DBook.visible):
			%Sprite2DOverlay.set_visible(true)
			%Sprite2DBook.set_visible(false)
			%AudioStreamPlayerBookOpen.play()
		else:
			%Sprite2DOverlay.set_visible(false)
			%Sprite2DBook.set_visible(true)
			%AudioStreamPlayerBookClose.play()
