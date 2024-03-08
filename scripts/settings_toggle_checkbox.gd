extends CheckBox

@export var setting_name = ""

func _ready():
	connect("toggled", on_value_changed)
	Settings.connect("boolean_changed", on_setting_changed)
	button_pressed = Settings.call("get_%s" % setting_name)

func on_value_changed(value):
	Settings.call("set_%s" % setting_name, value)

func on_setting_changed(setting, state):
	if setting == setting_name:
		button_pressed = state
