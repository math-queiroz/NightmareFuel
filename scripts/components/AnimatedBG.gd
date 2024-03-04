extends ColorRect

const paralax_displacement : float = 30
const paralax_speed : float = 3

@onready var default_pos : Vector2 = global_position

func _process(_delta: float) -> void:
	var percent_pos = get_global_mouse_position() / Vector2(get_viewport().get_visible_rect().size)
	percent_pos = Vector2(clamp(percent_pos.x, 0, 1), clamp(percent_pos.y, 0, 1))
	var target_pos = default_pos + (Vector2(.5, -.5) - percent_pos) * paralax_displacement
	global_position = lerp(global_position, target_pos, _delta * paralax_speed)
