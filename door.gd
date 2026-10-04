extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea

# This allows you to set the destination directly in the Inspector
@export var next_scene_path: String = "res://levels/level_1.tscn"

func _ready():
	# Connect to your Interaction Manager
	interaction_area.interact = Callable(self, "_on_interact")
	
	# Change the text on your floating label
	interaction_area.action_name = "go outside"

func _on_interact():
	if next_scene_path != "":
		# Instantly swap out the current scene for the new one
		get_tree().change_scene_to_file(next_scene_path)


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
