extends Node
class_name Level

# Chaning this values has no effects on actual parameters
# they are just labels to "magic number" used on sanity_drain
const MAX_SANITY : int = 16
const CYCLE_DURATION_SECONDS : int = 120

@export_category("Level parameters")
@export var cycle : int = 1
@export var monster_pool : Array[PackedScene]
@export var special_monster : PackedScene
@export var next_level : PackedScene

@export_category("Level difficulty")
@export var minimum_needed_sanity : int = 6
@export var avaliable_cups : int = 1
@export var avaliable_bottles : int = 2
@export var is_ice_avaliable : bool = false
@export var correct_order_sanity_gain: float = 2.0
@export var wrong_order_sanity_drain : float = 2.0
@export var spill_sanity_drain : float = 0.1

@onready var passive_sanity_drain_per_second : float = float(MAX_SANITY + minimum_needed_sanity) / CYCLE_DURATION_SECONDS
@onready var timer : Timer = %LevelTimer
@onready var client_manager : CustomerManager = $CustomerManager
@onready var music : AnimationPlayer = $AnimationPlayerMusic
@onready var level_ui : LevelUI = $LevelUI

var sanity : float = 16 : set = set_sanity
var held_object : Draggable

var cycle_started : bool = false
var cycle_finished : bool = false

func set_sanity(value):
	%SanityBar.value = ceil(sanity)
	if sanity <= 0: _on_sanity_depleted()
	sanity = value

func _ready():
	%ScreenFader.play_backwards("fade")
	if cycle == 1:
		%Book.set_open(true, true)
	timer.connect("timeout", _on_time_depleted)
	%IndicatorFrame.set_cycle_number(cycle)
	%AnimatedBG.material.set("shader_parameter/RandomSeed", randf())

func _process(delta):
	if cycle_started and not cycle_finished:
		sanity -= passive_sanity_drain_per_second * delta

func start_cycle():
	if not cycle_started:
		%IndicatorFrame.on_cycle_start()
		cycle_started = true
		timer.start()
		music.play("level_music")
		client_manager.summon_random_customer()

func finish_level():
	%Book.set_open(false)

func _on_sanity_depleted():
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_time_depleted():
	cycle_finished = true
	client_manager.on_timeout()
