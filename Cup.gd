extends Draggable
class_name Cup

const ice_fall_angle : int = 150
const ice_fall_spread : int = 15
const used_ice_scene : PackedScene = preload("res://components/used_ice_cube.tscn")

@export var max_amount : int = 100
@export var max_ice_cubes : int = 2

@onready var spill_point : SpillPoint = get_node("SpillPoint")
@onready var liquid_sprite : Sprite2D = get_node("Sprite2DLiquid")
@onready var ice_area : Area2D = get_node("Area2DIce")


var contents  : Array[int] = [0, 0, 0, 0]
var ice_cubes : int = 0

func _ready():
	super._ready()
	spill_point.particle_emitter.set_one_shot(true)
	ice_area.connect("body_entered", _on_area_2d_ice_body_entered)

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
		if contents.any(func(v): v>0):
			var max_holdable = int((1 - (abs(rotation_degrees) / 90)) * max_amount)
			var surplus = contents.reduce(func(a,v): return a+v) - max_holdable
			if surplus > 0:
				var max_equally_spillable_surplus = contents.reduce(func(a,v): return max(0,v), 0)
				var spill_amount = min(surplus, max_equally_spillable_surplus)
				var to_spill = range(len(contents)).reduce(
					func(a,i):
						contents[i] -= spill_amount
						a[i] = spill_amount
						return a
				,[0,0,0,0])
				spill_point.queue_spill(contents)

func value_updated(value):
	var sum = contents[0]+contents[1]+contents[2]+contents[3]
	liquid_sprite.get_material().set("shader_parameter/Percentage", float(sum)/max_amount)

func _on_area_2d_ice_body_entered(body):
	if body is IceCube and ice_cubes <= max_ice_cubes:
		ice_cubes += 1
		body.queue_free()
