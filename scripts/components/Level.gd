extends Node
class_name Level

# 0.087 is enough to lose 21 sanity over 240 seconds (needs to serve at least 3 clients to win)
const passive_sanity_drain_per_second : float = 0.087
const correct_order_sanity_multiplier : float = 1.0
const wrong_order_sanity_multiplier : float = 1.0
const spill_sanity_multiplier : float = 1.0
const monster_pool = [
	preload("res://scenes/monsters/sproutling.tscn"),
	preload("res://scenes/monsters/anglerslug.tscn"),
]

const special_monster = preload("res://scenes/monsters/special_knight.tscn")

@onready var client_manager : CustomerManager = %CustomerManager
@onready var timer : Timer = %LevelTimer

# Setting the cycle via export wasn't bringing correct parameters for some reason...
# so now each level will inherit a base level class and change (along other things)
# these values below
var cycle : int = 5
var avaliable_cups : int = Common.get_avaliable_cups(cycle)
var avaliable_bottles : int = Common.get_avaliable_bottles(cycle)
var is_ice_avaliable : bool = Common.get_is_ice_avaliable(cycle)

var customers_served = 0
var score_sum = 0

var sanity : float = 16 : set = set_sanity
var held_object : Draggable

var cycle_started : bool = false
var cycle_finished : bool = false

func set_sanity(value):
	%SanityBar.value = ceil(sanity)
	if sanity <= 0: _on_sanity_depleted()
	sanity = value

func _ready():
	DisplayServer.window_set_size(Vector2i(1200, 800))
	if cycle == 1:
		%Sprite2DOverlay.set_visible(true)
		%Sprite2DBook.set_visible(false)
	timer.connect("timeout", _on_time_depleted)
	%IndicatorFrame.set_cycle_number(cycle)
	%AnimatedBG.material.set("shader_parameter/RandomSeed", randf())

func _process(delta):
	if cycle_started and not cycle_finished:
		sanity -= passive_sanity_drain_per_second * delta

func start_cycle():
	if not cycle_started:
		%IndicatorFrame.on_cycle_start()
		%Sprite2DOverlay.set_visible(false)
		%Sprite2DBook.set_visible(true)
		cycle_started = true
		timer.start()
		client_manager.summon_random_customer()

func finish_level():
	pass

func _on_sanity_depleted():
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_time_depleted():
	cycle_finished = true
	client_manager.on_timeout()
