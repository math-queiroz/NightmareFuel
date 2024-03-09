extends Node
class_name Level

# Chaning this values has no effects on the actual parameters they reference
# they are just labels to identify "magic number" used on sanity_drain calc
const MAX_SANITY : int = 16
const game_over_scene : PackedScene = preload("res://scenes/game_over.tscn")
const CYCLE_DURATION_SECONDS : int = 120

@export_category("Level parameters")
@export var cycle : int = 1
@export var monster_pool : Array[PackedScene] = []
@export var special_monster : PackedScene
@export var special_monster_item : PackedScene
@export var special_item_order_count : int = 5
@export var next_level : PackedScene

@export_category("Level difficulty")
@export var minimum_needed_sanity : int = 6
@export var avaliable_cups : int = 1
@export var avaliable_bottles : int = 2
@export var is_ice_avaliable : bool = false
@export var correct_order_sanity_gain : float = 2.0
@export var wrong_order_sanity_drain : float = 1.0
@export var spill_sanity_drain : float = 0.1

@onready var passive_sanity_drain_per_second : float = float(MAX_SANITY + minimum_needed_sanity) / CYCLE_DURATION_SECONDS

@onready var client_manager : CustomerManager = $CustomerManager
@onready var music : AnimationPlayer = $AnimationPlayerMusic
@onready var screen_fader : AnimationPlayer = %ScreenFader
@onready var indicator_frame : Node2D = %IndicatorFrame
@onready var cycle_stats : Control = %CycleStats
@onready var animated_bg : Control = %AnimatedBG
@onready var sanity_bar : Control = %SanityBar
@onready var timer : Timer = %LevelTimer
@onready var book : Node2D = %Book

@onready var medium_cup : Node2D = %CupMedium

var sanity : float = 16 : set = set_sanity
var stats : Common.CycleStats = Common.CycleStats.new()
var held_object : Draggable

var cycle_started : bool = false
var cycle_finished : bool = false

func set_sanity(value) -> void:
	sanity_bar.value = ceil(sanity)
	if sanity <= 0: _on_sanity_depleted()
	sanity = value

func _ready() -> void:
	if monster_pool.is_empty(): push_error("Monster pool shouldn't be empty")
	
	timer.connect("timeout", _on_time_depleted)
	cycle_stats.connect("next_level", load_next_level)
	book.set_open(true, true)
	indicator_frame.set_cycle_number(cycle)
	animated_bg.material.set("shader_parameter/RandomSeed", randf())

func _process(delta) -> void:
	if cycle_started and not cycle_finished:
		sanity -= passive_sanity_drain_per_second * delta

func start_cycle() -> void:
	if not cycle_started:
		indicator_frame.on_cycle_start()
		cycle_started = true
		timer.start()
		music.play("level_music")
		client_manager.summon_random_customer()

func finish_level() -> void:
	book.set_open(false)
	cycle_stats.show_stats(stats)

func load_next_level() -> void:
	screen_fader.play("fade")
	screen_fader.connect("animation_finished", func(_name):
		get_tree().change_scene_to_packed(next_level)
	)

func _on_sanity_depleted() -> void:
	Global.cup_position = medium_cup.global_position
	Global.previous_scene_path = scene_file_path
	get_tree().change_scene_to_packed(game_over_scene)

func _on_time_depleted() -> void:
	cycle_finished = true
	client_manager.on_timeout()

func turn_bg_red() -> void:
	%AnimatedBG.turn_red()
