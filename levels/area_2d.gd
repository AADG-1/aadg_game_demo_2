extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

var entered = true;

func _on_body_entered(body: Node2D) -> void:
	entered=true

func _on_body_exited(body: Node2D) -> void:
	entered = false

func _physics_process (_delta):
	if entered == true:
		if Input.is_action_just_pressed("advance_dialog"):
			get_tree().change_scene_to_file("res://levels/level_2.tscn")
