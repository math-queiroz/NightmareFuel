extends CharacterBody2D
class_name Draggable

const follow_force : float = 20
const drop_dist : float = 5
const tilt_dist : float = 40

@export var collision_sound : AudioStream
@export var hold_sound : AudioStream
@export var hold_texture : Texture2D

var default_texture : Texture2D
var audio_player : AudioStreamPlayer

var is_held : bool = false : set = _set_is_held
var is_held_echo : bool = false
var is_tilting : bool = false

var last_press_pos : Vector2 = Vector2.ZERO

func _set_is_held(value):
	if hold_sound and value:
		audio_player.pitch_scale = randf_range(0.8,1.2)
		audio_player.play()
	if hold_texture:
		$Sprite2D.set_texture(hold_texture if value else default_texture)
	is_held = value

func _ready():
	var sprite = get_node("Sprite2D");
	if sprite != null:
		default_texture = sprite.get_texture()
	if hold_sound:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_player.set_stream(hold_sound)

func _physics_process(delta):
	rotation = lerp(rotation, 0.0, 3 * delta)
	if is_tilting:
		rotation = PI * clamp(_get_hold_delta().x / tilt_dist, -1, 1)
	elif is_held:
		global_position = lerp(global_position, get_global_mouse_position(), follow_force * delta)
	else:
		velocity += Vector2.DOWN * ProjectSettings.get_setting("physics/2d/default_gravity") * delta
		move_and_slide()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == 1 and not event.pressed:
		is_tilting = false

func _input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1:
		if event.pressed:
			last_press_pos = get_global_mouse_position()
			if not is_held:
				is_held = true
				is_held_echo = true
			else:
				is_tilting = true
		else:
			if is_held_echo:
				is_held_echo = false
				return
			if _get_hold_delta().length() <= drop_dist:
				is_held = false
	get_tree().get_root().set_input_as_handled()

func _get_hold_delta():
	return get_global_mouse_position() - last_press_pos
