extends Sprite2D

var number_array = [
	load("res://sprites/number_1.png"),
	load("res://sprites/number_2.png"),
	load("res://sprites/number_3.png"),
	load("res://sprites/number_4.png"),
	load("res://sprites/number_5.png")
]

func _ready():
	set_process(false)

func set_cycle_number(number: int):
	$Sprite2D.set_texture(number_array[number - 1])

func on_cycle_start():
	set_process(true)

func _process(_delta):
	%TimeBar.value = %LevelTimer.time_left / %LevelTimer.wait_time * %TimeBar.max_value
