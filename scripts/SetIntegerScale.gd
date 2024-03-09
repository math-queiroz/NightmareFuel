extends Button

const base_window_size := Vector2i(800, 480)

@export var target_scale : float = 1

func _ready() -> void:
	connect("pressed", set_window_scale)

func set_window_scale() -> void:
	DisplayServer.window_set_size(base_window_size * target_scale)
