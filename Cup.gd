extends Draggable
class_name Cup

const ice_fall_angle : int = 150
const ice_fall_spread : int = 15
const used_ice_scene : PackedScene = preload("res://components/used_ice_cube.tscn")

@export var max_amount : int = 100
@export var max_ice_cubes : int = 2
@export var source_id : int = 0

@onready var spill_point : SpillPoint = $SpillPoint
@onready var liquid_sprite : Sprite2D = $Sprite2DLiquid
@onready var contents_area : Area2D = $Area2DContents
@onready var particle_collider : LightOccluder2D = $ParticleCollider

var contents  : Array[int] = [0, 0, 0, 0]
var ice_cubes : int = 0

var lerp_percentage : float = 0.0

func _get_contents_sum():
	return contents.reduce(func(a,v): return a+v)

func set_is_held(value):
	super.set_is_held(value)
	if value:
		particle_collider.hide()
	elif _get_contents_sum() < max_amount:
		particle_collider.show()		

func _ready():
	super._ready()
	contents_area.connect("body_entered", _on_area_2d_contents_body_entered)

func _process(delta):
	super._process(delta)
	if is_tilting:
		if rotation_degrees > ice_fall_angle || rotation_degrees < -ice_fall_angle:
			for i in range(ice_cubes):
				var cube = used_ice_scene.instantiate()
				cube.global_position = Vector2(
					global_position.x + randi_range(-ice_fall_spread,ice_fall_spread),
					global_position.y + randi_range(-ice_fall_spread,ice_fall_spread)
				)
				get_parent().add_child(cube)
			ice_cubes = 0
		if contents.any(func(v): return v>0):
			var max_holdable = int((1 - (abs(rotation_degrees) / 90)) * max_amount)
			var surplus = _get_contents_sum() - max_holdable
			if surplus > 0:
				var max_equally_spillable_surplus = contents.reduce(func(a,v): return max(a,v), 0)
				var spill_amount = min(surplus, max_equally_spillable_surplus)
				var spill_contents = _drain(spill_amount)
				spill_point.start_spilling(spill_contents, source_id)
				_on_value_updated()

func _drain(drain_amount) -> Array[int]:
	var acc : Array[int] = [0,0,0,0]
	for i in len(contents):
		acc[i] = min(drain_amount, contents[i])
		contents[i] = max(0, contents[i] - drain_amount)
	return acc

func _on_value_updated():
	liquid_sprite.get_material().set("shader_parameter/Percentage", float(_get_contents_sum())/max_amount)
	var weights = Plane(contents[0], contents[1], contents[2], contents[3])
	liquid_sprite.get_material().set("shader_parameter/Weights", weights)

func _on_area_2d_contents_body_entered(body):
	if body is Droplet and body.source_id != source_id and _get_contents_sum() < max_amount:
		for i in len(contents):
			contents[i] += body.contents[i]
		_on_value_updated()
	elif body is IceCube and ice_cubes < max_ice_cubes and not body.is_held:
		ice_cubes += 1
	else:
		particle_collider.hide()
		return
	body.queue_free()
