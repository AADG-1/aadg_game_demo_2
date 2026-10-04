extends Node

func _on_energy_depleted() -> void:
	# Твоята логика за смяна на нивото тук
	print("Енергията свърши!")
	var current_scene_file = get_tree().current_scene.scene_file_path
	var next_level_number = current_scene_file.to_int() + 1
	
	var next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
	get_tree().change_scene_to_file(next_level_path)

func _process(delta):
	if Input.is_action_just_pressed("change_levels_press_L"):
		print("N key was pressed!")
		
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		
		var next_level_path = "res://levels/level_" + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
