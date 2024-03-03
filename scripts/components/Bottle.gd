extends Draggable
class_name Bottle

@export var bottle_content_id : Common.LiquidID

@onready var spill_point : SpillPoint = get_node("SpillPoint")
@onready var contents : Array[int] = [0, 0, 0, 0]

var was_spilling : bool = false

func _ready():
	super._ready()
	contents[bottle_content_id] = 1

func _process(delta):
	super._process(delta)
	if is_held:
		var should_spill = is_tilting and rotation_degrees < -100 or rotation_degrees > 100
		if should_spill and not was_spilling:
			was_spilling = true
			spill_point.start_spilling(contents)
		elif not should_spill and was_spilling:
			was_spilling = false
			spill_point.stop_spilling()
		was_spilling = should_spill
