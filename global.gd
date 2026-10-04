extends Node

# Variable to hold a reference position (e.g., player's position)
var player_global_position: Vector2 = Vector2.ZERO

# Helper function to get distance between any two global positions
func get_distance_between(pos1: Vector2, pos2: Vector2) -> float:
	return pos1.distance_to(pos2)
