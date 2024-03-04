extends Control

func _on_mouse_entered() -> void:
	%IndicatorLabels.show()

func _on_mouse_exited() -> void:
	%IndicatorLabels.hide()
