extends CharacterBody2D
class_name Draggable

const follow_force : float = 36
const drop_dist_sqr : float = 1
const held_z_index : int = 10
const tilt_dist : float = 40

@export var hold_sound : AudioStream
@export var hold_texture : Texture2D

@onready var level_node : Level = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1) as Level
@onready var default_z_index : int = z_index
@onready var audio_player : AudioStreamPlayer
@onready var default_texture : Texture2D = get_node("Sprite2D").get_texture()

var is_held : bool = false : set = set_is_held
var is_held_echo : bool = false
var is_tilting : bool = false

var last_press_pos : Vector2 = Vector2.ZERO
var max_sqr_displace_while_tilting : float = 0.0


func set_is_held(value):
	# Force single held object per Level
	if level_node.held_object == null or level_node.held_object == self:
		level_node.held_object = self if value else null
	else:
		return

	if hold_sound and value:
		audio_player.pitch_scale = randf_range(0.8,1.1)
		audio_player.play()
	if hold_texture:
		$Sprite2D.set_texture(hold_texture if value else default_texture)
	z_index = held_z_index if value else default_z_index
	is_held = value

func _ready():
	if hold_sound != null:
		audio_player = AudioStreamPlayer.new()
		audio_player.set_stream(hold_sound)
		add_child(audio_player)

func _process(delta):
	if is_tilting:
		rotation = PI * clamp(_get_hold_delta().x / tilt_dist, -1, 1)
		max_sqr_displace_while_tilting = max(max_sqr_displace_while_tilting, _get_hold_delta().length_squared())
	else:
		rotation = lerp(rotation, 0.0, 3 * delta)
		if is_held:
			global_position = lerp(global_position, get_global_mouse_position(), follow_force * delta)
		else:
			velocity += Vector2.DOWN * ProjectSettings.get_setting("physics/2d/default_gravity") * delta
			move_and_slide()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_tilting = false

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_press_pos = get_global_mouse_position()
			if not is_held:
				is_held = true
				is_held_echo = true
			else:
				is_tilting = true
				max_sqr_displace_while_tilting = 0.0
		else:
			if is_held_echo:
					is_held_echo = false
			else:
				if max_sqr_displace_while_tilting < drop_dist_sqr:
						is_held = false

func _get_hold_delta():
	return get_global_mouse_position() - last_press_pos
