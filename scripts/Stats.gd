extends Control

signal next_level

func show_stats(s: Common.CycleStats) -> void:
	%Book.set_open(false)
	var text = "\n".join([
		s.customers_served, "",
		s.correct_orders_served, s.wrong_orders_served, "",
		s.sanity_replenished, s.sanity_lost_to_spill, "",
		"Yes" if s.special_order_delivered else "No"
	])
	$Container/HBoxContainer/RichTextLabel2.set_text(text)
	$AnimationPlayer.play("show")

func _on_continue_pressed():
	next_level.emit()
