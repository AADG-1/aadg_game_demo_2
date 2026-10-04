extends Node2D
@export_file("*.tscn") var target_scene: String

@onready var interaction_area: InteractionArea = $InteractionArea


func _ready():
	interaction_area.interacted.connect(_on_interacted)


func _on_interacted():
	if target_scene != "":
		get_tree().change_scene_to_file(target_scene)
