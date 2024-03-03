extends Control

func _on_mouse_entered():
	%IndicatorLabels.show()

func _on_mouse_exited():
	%IndicatorLabels.hide()
