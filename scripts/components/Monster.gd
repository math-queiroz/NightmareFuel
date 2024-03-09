extends Node2D
class_name Monster

signal departed()

@export var realm : Common.Realm
@export var ignore_order_text : bool = false
@export var has_an_order : bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer

var request : String : set = set_order_request

func set_order_request(value: String) -> void:
	request = value

func _ready() -> void:
	$Speech.hide()
	arrive()

func arrive() -> void:
	animation_player.play("entrance")
	animation_player.connect("animation_changed", func(_arg1, _arg2): say(request), CONNECT_ONE_SHOT)
	animation_player.queue("idle")

func depart() -> void:
	animation_player.play("fade")
	animation_player.connect("animation_finished", func(_name): 
		departed.emit()
		queue_free()
	)

func say(text: String) -> void:
	if not ignore_order_text: $Speech/RichTextLabel.set_text(text)
	$Speech.show()

func on_correct_deliver() -> void:
	print_debug("%s is happy" % name)
	depart()

func on_wrong_deliver() -> void:
	print_debug("%s hates you" % name)
	depart()

func _on_timeout() -> void:
	depart()
