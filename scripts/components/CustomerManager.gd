extends Node2D
class_name CustomerManager

const deliver_score_treshold = 0.9

const swapm_agregators = ["Aa", "Rh", "Agr", "Rrh", "Hgsr", "Rrrhg", "Ahhhrgs", "Shhshrg"]
const swamp_min_max_agregators = Vector2i(1, 6)
const swapm_drink_words = [["Arhg","Hrhar"],["Aahhrgh","Hrurg"],["Arhrr","Rrrrh"],["Ahrggru","Rhhgj"]]
const swapm_cups_size_words = {
	Common.CupCapacity.SMALL: "Alhgr",
	Common.CupCapacity.MEDIUM: "Jhrgr",
	Common.CupCapacity.LARGE: "Urrgr",
}

@onready var level_node : Level = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1) as Level

var spawned_special : bool = false

var monster : Monster
var order : Common.Order

func _ready() -> void:
	randomize()
	# Mass test order generator
	#for i in 100:
	#	var o = new_swamp_order()
	#	print(o)

func _on_monster_departed() -> void:
	if not %LevelTimer.is_stopped():
		summon_random_customer()
	elif not spawned_special:
		spawned_special = true
		summon_customer(level_node.special_monster)
	else:
		level_node.finish_level()

func _on_area_2d_customer_interaction_input_event(_viewport, event, _shape_idx) -> void:
	var is_left_mouse = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var obj = level_node.held_object
	if  is_left_mouse and event.pressed and order != null and obj is Cup and obj.get_contents_sum() > 0:
		if not spawned_special:
			var delivered = Common.Order.new()
			delivered.cup_capacity = obj.cup_capacity
			delivered.ice_cubes = obj.ice_cubes
			delivered.has_teleported_ice = obj.has_teleported_ice
			delivered.contents = obj.contents
			var deliver_score = evaluate_order_deliver(delivered)

			if deliver_score >= deliver_score_treshold:
				var s = Common.base_correct_order_sanity_gain * level_node.correct_order_sanity_multiplier
				monster.on_correct_deliver()
				level_node.set_sanity(level_node.sanity + s)
			else:
				var s = Common.base_wrong_order_sanity_drain * level_node.wrong_order_sanity_multiplier
				monster.on_wrong_deliver()
				level_node.set_sanity(level_node.sanity - s)
		else:
			monster.depart()
		obj.on_deliver()
		order = null

func on_timeout() -> void:
	monster._on_timeout()
	monster = null

func evaluate_order_deliver(delivered) -> float:
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
	print_debug("Delivered a score of %.2f" % (score * 100))
	return score

func summon_random_customer() -> void:
	summon_customer(level_node.monster_pool[randi_range(0, len(level_node.monster_pool)-1)])

func summon_customer(customer: PackedScene):
	monster = customer.instantiate()
	monster.connect("tree_exited", _on_monster_departed)
	add_child(monster)
	place_order(monster.realm)
	var request = generate_order_request(monster.realm)
	print_debug(request)
	monster.set_order_request(request)

func place_order(realm: Common.Realm) -> void:
	match realm:
		Common.Realm.SWAMP:
			order = new_swamp_order()
	print_debug("Placed order ", order)

func generate_order_request(realm: Common.Realm) -> String:
	match realm:
		Common.Realm.SWAMP:
			return swamp_order_to_text(order)
	push_warning("No text found for monster realm")
	return "..."

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
		var r2 = r1+randi_range(1,level_node.avaliable_bottles - 1)
		r2 -= level_node.avaliable_bottles if r2 > level_node.avaliable_bottles else 0
		o.contents[r1-1] = o.cup_capacity/2
		o.contents[r2-1] = o.cup_capacity/2

	o.ice_cubes = 0 if not level_node.is_ice_avaliable else randi_range(0, Common.ice_capacity_order[size_index])

	return o

func swamp_order_to_text(o: Common.Order) -> String:
	var tokens = []

	for i in len(o.contents):
		if o.contents[i] > 0:
			tokens.append(swapm_drink_words[i][randi_range(0,1)])
	tokens.append(swapm_cups_size_words[o.cup_capacity])
	if o.ice_cubes > 0:
		var letters = "arshug"
		tokens.append("Msghh %s" % range(o.ice_cubes)
			.reduce(func(a,i): return a + letters[i], ""))
	for i in randi_range(swamp_min_max_agregators.x, swamp_min_max_agregators.y):
		tokens.append(swapm_agregators.pick_random())

	return " ".join(tokens)
