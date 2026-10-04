extends Area2D

signal interacted_with_the_appartment_door

var player_inside := false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false

func _unhandled_input(event):
	if event.is_action_pressed("interact") and player_inside:
		interacted_with_the_appartment_door.emit()
