extends Area2D

@onready var level_node : Level = get_tree().get_root().get_child(get_tree().get_root().get_child_count() - 1) as Level

func _on_body_entered(body: PhysicsBody2D) -> void:
	if body is Droplet:
		level_node.set_sanity(level_node.sanity - level_node.spill_sanity_drain)
		return
	elif body.has_method("set_teleported"):
		body.set_teleported(true)
	body.global_position = %TeleportPoint.global_position
