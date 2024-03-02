extends Area2D

func _on_body_entered(body: PhysicsBody2D):
	body.global_position = %TeleportPoint.global_position
