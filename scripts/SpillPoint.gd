extends Node2D
class_name SpillPoint

@export var spill_color : VisualShaderNodeColorConstant
@export var use_alt_spill_point : bool

@onready var alt_spill_point : Node2D = get_node("AltSpillPoint") if use_alt_spill_point else null

@onready var audio_player = $AudioStreamPlayer
@onready var particle_emitter = $CPUParticles2D

var spilling = false : set = set_spilling
var spill_queue : int = 0

func set_spilling(value):
	if value:
		audio_player.play()
		if use_alt_spill_point:
				var is_alt_lower = alt_spill_point.global_position.y > global_position.y
				particle_emitter.set_position(alt_spill_point.position if is_alt_lower else Vector2.ZERO)
	else:
		audio_player.stop()
	particle_emitter.set_emitting(value)
	spilling = value

func _ready():
	particle_emitter.set_emitting(false)
	particle_emitter.process_material.set_color(spill_color.constant)

func queue_spill(amount):
	spill_queue += amount
	if not particle_emitter.emitting:
		emit_queued()

func emit_queued():
	if spill_queue == 0:
		set_spilling(false)
		return
	spill_queue = 0
	particle_emitter.amount = spill_queue
	var emit_time = particle_emitter.lifetime
	get_tree().create_timer(emit_time).connect("timeout", emit_queued)
	set_spilling(true)
