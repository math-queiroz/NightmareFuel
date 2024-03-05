extends HSlider

@export_enum("Master", "Audio", "Music") var bus_id

func _ready() -> void:
	value = db_to_linear(AudioServer.get_bus_volume_db(bus_id))
	connect("value_changed", _change_bus_volume)

func _change_bus_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(volume))

