extends Area2D

func _on_body_entered(body: PhysicsBody2D):
	print("Teleporting")
	body.global_position = %TeleportPoint.global_position
