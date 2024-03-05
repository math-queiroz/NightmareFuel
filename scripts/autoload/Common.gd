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

	func _to_string() -> String:
		return "Content: [%d,%d,%d,%d], Capacity: %d, IceCubes: %d" \
			% [contents[0], contents[1], contents[2], contents[3], cup_capacity, ice_cubes]

class CycleStats:
	var customers_served : int = 0
	var sanity_replenished : int = 0
	var correct_orders_served : int = 0

	var wrong_orders_served : int = 0
	var sanity_lost_to_spill : int = 0

	var special_order_delivered : bool = false
