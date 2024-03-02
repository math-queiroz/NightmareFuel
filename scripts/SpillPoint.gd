extends Node2D
class_name SpillPoint

const droplet_scene : PackedScene = preload("res://components/dropplet.tscn")
const particle_speed : float = 50.0

@export var use_alt_spill_point : bool
@export var loop : bool = true
@export var c : Array[VisualShaderNodeColorConstant]

@onready var colors = [c[0].constant, c[1].constant, c[2].constant, c[3].constant]
@onready var alt_spill_point : Node2D = get_node("AltSpillPoint") if use_alt_spill_point else null
@onready var spill_timer : Timer = $Timer
@onready var audio_player : AudioStreamPlayer = $AudioStreamPlayer
@onready var particle_emitter : GPUParticles2D = $GPUParticles2D

var spilling : bool = false : set = _set_spilling
var last_contents : Array[int]
var last_source_id : int

func _set_spilling(value):
	if value:
		if last_contents.is_empty():
			push_warning("Tried to continuous spill null contents!")
			return
		_start_timer()
		if not audio_player.playing:
			audio_player.play()
		if use_alt_spill_point:
			var is_alt_lower = alt_spill_point.global_position.y > global_position.y
			particle_emitter.set_position(alt_spill_point.position if is_alt_lower else Vector2.ZERO)
	else:
		last_contents = []
		audio_player.stop()
	#particle_emitter.set_emitting(value)
	spilling = value

func _ready():
	particle_emitter.set_emitting(false)
	particle_emitter.process_material.initial_velocity_min = particle_speed
	spill_timer.set_wait_time(particle_emitter.lifetime / particle_emitter.amount)
	spill_timer.connect("timeout", _start_timer if loop else stop_spilling)
	
func _start_timer():
	spill_timer.start()
	_emit_droplet(last_contents, last_source_id)
	
func _emit_droplet(contents, source_id):
	var droplet = droplet_scene.instantiate()
	droplet.global_transform = particle_emitter.global_transform
	droplet.source_id = source_id
	for i in len(contents):
		droplet.contents[i] = contents[i]
	%DropletPool.add_child(droplet)
	var particle_velocity = Vector2.UP.rotated(global_rotation) * particle_speed
	droplet.set_linear_velocity(particle_velocity)
	particle_emitter.emit_particle(transform, Vector2.ZERO, Color.WHITE, Color.WHITE, 0)
	
func start_spilling(contents: Array[int], source_id = 0):
	last_contents = contents
	last_source_id = source_id
	particle_emitter.process_material.set_color(_get_contents_color())
	_set_spilling(true)

func stop_spilling():
	spill_timer.stop()
	_set_spilling(false)

func _get_contents_color():
	return (colors[0]*last_contents[0] + colors[1]*last_contents[1] + \
		colors[2]*last_contents[2] + colors[3]*last_contents[3]) / \
		last_contents.reduce(func(a,v): return a+v)

func _sum(a, v):
	return a+v
