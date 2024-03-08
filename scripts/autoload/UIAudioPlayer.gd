extends AudioStreamPlayer

func _ready():
	set_max_polyphony(4)
	set_bus("UI")
