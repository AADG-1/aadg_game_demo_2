extends Area2D

@export var next_level_path: String = "" 
@export var screen_fader: ColorRect

func _on_body_entered(body):
	print("1. Нещо докосна вратата: ", body.name)
	
	if body.is_in_group("player"):
		print("2. Играчът е разпознат успешно!")
		
		if screen_fader == null:
			print("ГРЕШКА: Screen Fader (ColorRect) не е сложен в Inspector!")
			
		if next_level_path == "":
			print("ГРЕШКА: Next Level Path е празен в Inspector!")
			
		body.set_physics_process(false)
		
		if is_instance_valid(screen_fader):
			var tween = get_tree().create_tween()
			tween.tween_property(screen_fader, "color:a", 1.0, 1.0)
			await tween.finished
			
		if next_level_path != "":
			print("Attempting to load: ", next_level_path)
			var status = get_tree().change_scene_to_file(next_level_path)
			print("Load status code: ", status)
		else:
			print("ERROR: The path is empty!")
