extends Node2D
class_name Monster

@export var realm : Common.Realm

var request : String : set = set_order_request

func set_order_request(value: String) -> void:
	request = value

func arrive() -> void:
	push_error("Not implemented!")

func depart() -> void:
	push_error("Not implemented!")

func say(_text: String) -> void:
	push_error("Not implemented!")

func on_correct_deliver() -> void:
	push_error("Not implemented!")

func on_wrong_deliver() -> void:
	push_error("Not implemented!")

func _on_timeout() -> void:
	push_error("Not implemented!")
