extends Node
class_name Level

var passive_sanity_drain_per_second : float = 0.167
var wrong_order_sanity_multiplier : float = 1.0
var correct_order_sanity_multiplier : float = 1.0
var spill_sanity_multiplier : float = 1.0

@onready var client_manager : CustomerManager = %CustomerManager
@onready var timer : Timer = %LevelTimer

# Setting cycle via export wasn't bringing correct parameters for some reason...
var cycle : int = 5
var avaliable_cups : int = Common.get_avaliable_cups(cycle)
var avaliable_bottles : int = Common.get_avaliable_bottles(cycle)
var is_ice_avaliable : bool = Common.get_is_ice_avaliable(cycle)

var customers_served = 0
var score_sum = 0

var sanity : float = 16 : set = set_sanity
var held_object : Draggable

var cycle_started : bool = false

func set_sanity(value):
	%SanityBar.value = ceil(sanity)
	sanity = value

func _ready():
	if cycle == 1:
		%Sprite2DOverlay.set_visible(true)
		%Sprite2DBook.set_visible(false)
	DisplayServer.window_set_size(Vector2i(1200, 800))
	timer.connect("timeout", _on_time_depleted)
	%IndicatorFrame.set_cycle_number(cycle)
	%AnimatedBG.material.set("shader_parameter/RandomSeed", randf())

func _process(delta):
	if cycle_started:
		sanity -= passive_sanity_drain_per_second * delta
		if sanity == 0:
			_on_sanity_depleted()

func start_cycle():
	if not cycle_started:
		%Sprite2DOverlay.set_visible(false)
		%Sprite2DBook.set_visible(true)
		cycle_started = true
		timer.start()
		client_manager.summon_random_customer()

func _on_sanity_depleted():
	pass

func _on_time_depleted():
	client_manager.on_timeout()
