extends Draggable
class_name Bottle

@onready var spill_point : Node2D = get_node("SpillPoint")

var was_spilling : bool = false

func _process(delta):
	super._process(delta)
	if is_held:
		var should_spill = is_tilting and rotation_degrees < -100 or rotation_degrees > 100
		if should_spill and not was_spilling:
			was_spilling = true
			spill_point.set_spilling(true)
		elif not should_spill and was_spilling:
			was_spilling = false
			spill_point.set_spilling(false)
		was_spilling = should_spill
