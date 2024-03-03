extends Node
class_name Common

enum LiquidID {
	ROCK_BOTOM = 0,
	STAR_BURST = 1,
	LIFE_ELIXIR = 2,
	MOON_SHINE = 3
}

enum Realm {
	SWAMP,
	SPACE,
	FANTASY,
	ELDRICH,
	SPECIAL
}

enum CupCapacity {
	SMALL = 20,
	MEDIUM = 35,
	LARGE = 50,
}

const ice_capacity_order = [2,3,1]
const cup_unlock_order = [
	Common.CupCapacity.MEDIUM,
	Common.CupCapacity.LARGE,
	Common.CupCapacity.SMALL
]


class Order:
	var contents : Array
	var ice_cubes : int
	var has_teleported_ice : bool
	var cup_capacity : int
	
	func _to_string():
		return "Content: [%d,%d,%d,%d], Capacity: %d, IceCubes: %d" \
			% [contents[0], contents[1], contents[2], contents[3], cup_capacity, ice_cubes]

static var base_correct_order_sanity_gain : float = 2.0
static var base_wrong_order_sanity_drain : float = 4.0
static var base_spill_sanity_drain : float = 0.1

static func get_avaliable_cups(cycle):
	return 1 if cycle < 2 else 2 if cycle < 5 else 3

static func get_avaliable_bottles(cycle):
	return 2 if cycle < 2 else 3 if cycle < 3 else 4

static func get_is_ice_avaliable(cycle):
	return cycle > 1
