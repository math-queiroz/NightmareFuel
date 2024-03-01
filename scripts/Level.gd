extends Node
class_name Level

@export var cycle : int

func _ready():
	_start_cycle()

func _start_cycle():
	%TimeOrb.set_cycle_number(cycle)
	pass
