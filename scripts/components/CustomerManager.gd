extends Node2D
class_name CustomerManager

const deliver_score_treshold = 0.9

# shortening labels
const cap_s = Common.CupCapacity.SMALL
const cap_m = Common.CupCapacity.MEDIUM
const cap_l = Common.CupCapacity.LARGE

const teleported_ice_enjoyers = [Common.Realm.ELDRITCH]
const teleported_ice_sanity_bonus: float = 1.0

const swapm_agregators = ["Aa", "Rh", "Agr", "Rrh", "Hgsr", "Rrrhg", "Ahhhrgs", "Shhshrg"]
const swamp_min_max_agregators = Vector2i(2, 6)
const swapm_drink_words = [["Arhg","Hrhar"],["Aahhrgh","Hrurg"],["Arhrr","Rrrrh"],["Ahrggru","Rhhgj"]]
const swapm_cups_size_words = { cap_s: "Alhgr", cap_m: "Jhrgr", cap_l: "Urrgr" }

const space_order_words = ["You wouldn't hate", "Take you", "Today it isn't", "Your order:", "Bye! So,", "Don't take notes,", "Hate to meet you,"]
const space_drink_words = [["yellow","strong"],["purple","light"],["red","tasteless"],["blue","sparkly"]]
const space_cups_size_words = { cap_s: "shot", cap_m: "glass", cap_l: "mug" }

const eldritch_bottles_thresholds = [0, 3, 6, 9]
const eldritch_cups_thresholds = [3, 6, 9]
const eldritch_drinks_names : Dictionary = {
	"Aiuzaalpir" : {"contents": [cap_m,0,0,0],               "cup_capacity": cap_m},
	"Cnujh'dre"  : {"contents": [0.25*cap_m,0.75*cap_m,0,0], "cup_capacity": cap_m},
	"Ghriodrrus" : {"contents": [0,cap_m,0,0],               "cup_capacity": cap_m},
	"Itril'xo"   : {"contents": [0,0,0.5*cap_l,0],           "cup_capacity": cap_l},
	"Mlullusz"   : {"contents": [0,0.5*cap_m,0.5*cap_m,0],   "cup_capacity": cap_m},
	"Neghast"    : {"contents": [0.75*cap_l,0,0.25*cap_l,0],   "cup_capacity": cap_l},
	"Uz'yxha"    : {"contents": [0,0,0,cap_s],               "cup_capacity": cap_s},
	"Yanaavhi"   : {"contents": [0,0,0.75*cap_m,0.25*cap_m], "cup_capacity": cap_m},
	"Zoggdeg"    : {"contents": [0.5*cap_l,0,0,0.5*cap_l],   "cup_capacity": cap_l},
}

@onready var level_node : Level = get_tree().get_current_scene() as Level

var monster_queue : Array[PackedScene]
var spawned_special : bool = false

var monster : Monster
var order : Common.Order

func _ready() -> void:
	randomize()
	#Mass test order generator
#	for i in 100:
#		var o = new_eldritch_order()
#		print(o)
#		print(eldritch_order_to_text(o))

func _on_monster_departed() -> void:
	if not %LevelTimer.is_stopped():
		summon_random_customer()
	elif level_node.special_monster != null and not spawned_special:
		spawned_special = true
		summon_customer(level_node.special_monster)
	else:
		level_node.finish_level()

func _on_area_2d_customer_interaction_input_event(_viewport, event, _shape_idx) -> void:
	var is_left_mouse = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
	var obj = level_node.held_object
	var has_monster_and_order = monster != null and monster.has_an_order
	if is_left_mouse and event.pressed and order != null and has_monster_and_order and (obj is Item or obj is Cup):
		if spawned_special:
			if obj is Item:
				Global.delivered_items_flag |= (1 << (level_node.cycle-1))
				level_node.stats.special_order_delivered = true
			monster.depart()
		elif obj is Cup and obj.get_contents_sum() > 0:
			level_node.stats.customers_served += 1

			var delivered = Common.Order.new()
			delivered.cup_capacity = obj.cup_capacity
			delivered.ice_cubes = obj.ice_cubes
			delivered.has_teleported_ice = obj.has_teleported_ice
			delivered.contents = obj.contents
			var deliver_score = evaluate_order_deliver(delivered)

			if deliver_score >= deliver_score_treshold:
				$AnimationPlayerScore.play("score_up")
				var s = level_node.correct_order_sanity_gain
				if delivered.has_teleported_ice and teleported_ice_enjoyers.has(monster.realm):
					print_debug("Had teleported ice! Adding %d bonus sanity" % teleported_ice_sanity_bonus)
					s += teleported_ice_sanity_bonus
				monster.on_correct_deliver()
				level_node.set_sanity(level_node.sanity + s)
				level_node.stats.correct_orders_served += 1
				level_node.stats.sanity_replenished += s
				if level_node.stats.correct_orders_served == level_node.special_item_order_count:
					if level_node.special_monster_item != null:
						var item = level_node.special_monster_item.instantiate()
						item.global_position = global_position
						level_node.add_child(item)
			else:
				$AnimationPlayerScore.play("score_down")
				var s = level_node.wrong_order_sanity_drain
				monster.on_wrong_deliver()
				level_node.set_sanity(level_node.sanity - s)
				level_node.stats.wrong_orders_served += 1
		else:
			return
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
	if monster_queue.is_empty():
		monster_queue = level_node.monster_pool.duplicate()
		monster_queue.shuffle()
	summon_customer(monster_queue.pop_back())

func summon_customer(customer: PackedScene):
	if Settings.hide_book_on_new_customeer:
		%Book.set_open(false)
	monster = customer.instantiate()
	monster.connect("departed", _on_monster_departed)
	add_child.call_deferred(monster)
	place_order(monster.realm)
	var request = generate_order_request(monster.realm)
	print_debug(request)
	monster.set_order_request(request)

func place_order(realm: Common.Realm) -> void:
	match realm:
		Common.Realm.SWAMP: order = new_swamp_order()
		Common.Realm.SPACE: order = new_space_order()
		Common.Realm.ELDRITCH: order = new_eldritch_order()
	print_debug("Placed order ", order)

func generate_order_request(realm: Common.Realm) -> String:
	match realm:
		Common.Realm.SWAMP: return swamp_order_to_text(order)
		Common.Realm.SPACE: return space_order_to_text(order)
		Common.Realm.ELDRITCH: return eldritch_order_to_text(order)
	push_warning("No text found for monster realm")
	return "..."

func random_contents(cup_capacity: int, max_drinks: int) -> Array:
	var contents = [0,0,0,0]
	match max_drinks:
		1:
			contents[randi_range(0,level_node.avaliable_bottles-1)] = cup_capacity
		2:
			# pick two distinct random drink ids
			var r1 = randi_range(1,level_node.avaliable_bottles)
			var r2 = r1+randi_range(1,level_node.avaliable_bottles - 1)
			r2 -= level_node.avaliable_bottles if r2 > level_node.avaliable_bottles else 0
			contents[r1-1] = 0.5*cup_capacity
			contents[r2-1] = 0.5*cup_capacity
		3:
			var except_index = randi_range(0, level_node.avaliable_bottles - 1)
			for i in level_node.avaliable_bottles - 1:
				if i != except_index:
					contents[i] = 0.337*cup_capacity
		4:
			return [0.25*cup_capacity, 0.25*cup_capacity, 0.25*cup_capacity, 0.25*cup_capacity]
		_: push_error("Random contents must be > 0 and < avaliable_bottles")
	return contents

func new_swamp_order() -> Common.Order:
	var o = Common.Order.new()
	var size_index = randi_range(0, level_node.avaliable_cups-1)
	o.cup_capacity = Common.cup_unlock_order[size_index]
	o.contents = random_contents(o.cup_capacity, randi_range(1, 2))
	o.ice_cubes = 0 if not level_node.is_ice_avaliable else randi_range(0, Common.ice_capacity_order[size_index])
	return o

func swamp_order_to_text(o: Common.Order) -> String:
	var tokens = []
	for i in len(o.contents):
		if o.contents[i] > 0:
			tokens.append(swapm_drink_words[i].pick_random())
	tokens.append(swapm_cups_size_words[o.cup_capacity])
	if o.ice_cubes > 0:
		var letters = "arshug"
		tokens.append("Msghh %s" % range(o.ice_cubes)
			.reduce(func(a,i): return a + letters[i], ""))
	for i in randi_range(swamp_min_max_agregators.x, swamp_min_max_agregators.y):
		tokens.append(swapm_agregators.pick_random())
	tokens.shuffle()
	return " ".join(tokens)
	
func new_space_order() -> Common.Order:
	var o = Common.Order.new()
	var size_index = randi_range(0, level_node.avaliable_cups-1)
	o.cup_capacity = Common.cup_unlock_order[size_index]
	o.contents = random_contents(o.cup_capacity, randi_range(1, min(3, level_node.avaliable_bottles)))
	o.ice_cubes = 0 if not level_node.is_ice_avaliable else randi_range(0, Common.ice_capacity_order[size_index])
	return o

func space_order_to_text(o: Common.Order) -> String:
	var tokens = []
	tokens.append(space_order_words.pick_random())
	var remain_i = len(o.contents.filter(func(v): return v>0))
	for i in len(o.contents):
		if o.contents[i] > 0: 
			remain_i -= 1
			var joiner = "," if remain_i > 1 else " and" if remain_i == 1 else ""
			tokens.append(space_drink_words[i].pick_random() + joiner)
	tokens.append(space_cups_size_words[o.cup_capacity])
	if o.ice_cubes > 0: 
		var plural = "s" if o.ice_cubes != 2 else ""
		tokens.append("with %s ice cube%s" % ["no" if o.ice_cubes==3 else str(3-o.ice_cubes), plural])
	return " ".join(tokens)

func new_eldritch_order() -> Common.EldritchOrder:
	var o = Common.EldritchOrder.new()
	var avaliable_drinks = eldritch_drinks_names.keys().slice(0, min(
		eldritch_cups_thresholds[level_node.avaliable_cups - 1], 
		eldritch_bottles_thresholds[level_node.avaliable_bottles - 1]
	))
	o.drink_name = avaliable_drinks.pick_random()
	o.contents = eldritch_drinks_names.get(o.drink_name).contents
	o.cup_capacity = eldritch_drinks_names.get(o.drink_name).cup_capacity
	var size_index = Common.cup_unlock_order.find(o.cup_capacity)
	o.ice_cubes = 0 if not level_node.is_ice_avaliable else randi_range(0, Common.ice_capacity_order[size_index])
	return o

func eldritch_order_to_text(o: Common.EldritchOrder) -> String:
	return "(It wants a \"%s\" with %s ice cubes)" % [o.drink_name, "no" if o.ice_cubes == 0 else str(o.ice_cubes)]
