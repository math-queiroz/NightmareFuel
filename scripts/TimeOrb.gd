extends Sprite2D

var number_array = [
	preload("res://sprites/number_1.png"),
	preload("res://sprites/number_2.png"),
	preload("res://sprites/number_3.png"),
	preload("res://sprites/number_4.png"),
	preload("res://sprites/number_5.png")
]

func _ready():
	$Sprite2D.set_texture(number_array[2])

func set_cycle_number(number: int):
	$Sprite2D.set_texture(number_array[number - 1])
