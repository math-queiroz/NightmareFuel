extends Node
class_name Level

@export var cycle : int

var held_object : Draggable

func _ready():
	DisplayServer.window_set_size(Vector2i(1200, 800))
	%LevelTimer.connect("timeout", _end_time)
	_start_cycle()

func _start_cycle():
	%IndicatorFrame.set_cycle_number(cycle)
	%LevelTimer.start()
	%AnimatedBG.material.set("shader_parameter/RandomSeed", randf())

func _end_time():
	print_debug("Timeout!")
