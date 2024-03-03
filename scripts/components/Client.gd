extends Node2D
class_name CustomerManager

const deliver_score_treshold = 0.9
const monster_pool = [
	preload("res://scenes/monsters/sproutling.tscn"),
	preload("res://scenes/monsters/anglerslug.tscn")
]

@onready var level_node : Level = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1) as Level

var monster : Monster
var order : Common.Order

func _ready():
	# Mass test order generator
	#for i in 100:
	#	var o = new_swamp_order()
	#	print(o.contents," ",o.cup_capacity," ",o.ice_cubes)
	pass

func _on_area_2d_customer_interaction_input_event(_viewport, event, _shape_idx):
	var is_left_mouse =event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var cup = level_node.held_object
	if  is_left_mouse and event.pressed and cup is Cup and cup.get_contents_sum() > 0:
		var delivered = Common.Order.new()
		delivered.cup_capacity = cup.cup_capacity
		delivered.ice_cubes = cup.ice_cubes
		delivered.has_teleported_ice = cup.has_teleported_ice
		delivered.contents = cup.contents
		var deliver_score = evaluate_order_deliver(delivered)
		
		if deliver_score >= deliver_score_treshold:
			var s = Common.base_correct_order_sanity_gain * level_node.correct_order_sanity_multiplier
			monster.on_correct_deliver()
			level_node.set_sanity(level_node.sanity + s)
		else:
			var s = Common.base_wrong_order_sanity_drain * level_node.wrong_order_sanity_multiplier
			monster.on_wrong_deliver()
			level_node.set_sanity(level_node.sanity - s)
			
		cup.on_deliver()
		order = null

func evaluate_order_deliver(delivered):
	var features = 1
	var cup_capacity_error = 0
	var ice_cubes_error = 0
	features += max(0, level_node.avaliable_bottles - 2)
	
	if level_node.avaliable_cups > 1:
		features += 1
		var max_cup_delta = 15 if order.cup_capacity == Common.CupCapacity.MEDIUM else 30
		cup_capacity_error = abs(float(delivered.cup_capacity - order.cup_capacity) / max_cup_delta)
	
	if level_node.is_ice_avaliable:
		features += 1
		var max_ice_cube_delta = 3 if order.ice_cubes == 0 or order.ice_cubes == 3 else 2
		ice_cubes_error = abs(float(delivered.ice_cubes - order.ice_cubes) / max_ice_cube_delta)		
	
	var contents_error : float = 0
	contents_error += 0.50 * abs(float(delivered.contents[0] - order.contents[0]) / order.cup_capacity)
	contents_error += 0.50 * abs(float(delivered.contents[1] - order.contents[1]) / order.cup_capacity)
	contents_error += abs(float(delivered.contents[2] - order.contents[2]) / order.cup_capacity)
	contents_error += abs(float(delivered.contents[3] - order.contents[3]) / order.cup_capacity)
	
	var score = 1.0 - (float(cup_capacity_error + ice_cubes_error + contents_error) / features)
	print_debug("Delivered a score of ", score * 100, "%")
	return score

func summon_random_customer():
	summon_customer(monster_pool[randi_range(0, len(monster_pool)-1)])

func summon_customer(customer: PackedScene):
	monster = customer.instantiate()
	monster.connect("tree_exited", _on_monster_departed)
	add_child(monster)
	place_order(monster.realm)
	
func place_order(realm: Common.Realm):
	match realm:
		Common.Realm.SWAMP:
			order = new_swamp_order()
		_:
			order = new_generic_order()
	print_debug("Placed order ", order)
	
func on_timeout():
	monster._on_timeout()
	monster = null

func _on_monster_departed():
	summon_random_customer()

func new_swamp_order():
	var o = Common.Order.new()
	
	var size_index = randi_range(0, level_node.avaliable_cups-1)
	o.cup_capacity = Common.cup_unlock_order[size_index]
	
	var single_drink = randi_range(0, 1) > 0
	o.contents = [0,0,0,0]
	if single_drink:
		o.contents[randi_range(0,level_node.avaliable_bottles-1)] = o.cup_capacity
	else:
		# pick two distinct random drink ids
		var r1 = randi_range(1,level_node.avaliable_bottles)
		var r2 = ((r1+randi_range(1,level_node.avaliable_bottles-1)+1) % level_node.avaliable_bottles) + 1
		o.contents[r1-1] = o.cup_capacity/2
		o.contents[r2-1] = o.cup_capacity/2
		
	o.ice_cubes = 0 if not level_node.is_ice_avaliable else randi_range(0, Common.ice_capacity_order[size_index])
	
	return o

func new_generic_order():
	pass
