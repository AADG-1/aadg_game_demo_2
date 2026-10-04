extends Node

@export var npc: Node2D
@export var energy_threshold: float = 30.0
@export var spawn_distance: float = 600.0 
@export var stop_distance: float = 40.0
@export var progress_bar: ProgressBar

var has_triggered: bool = false
var player: Node2D = null

func _ready():
	player = get_tree().get_first_node_in_group("player")

	if is_instance_valid(npc):
		npc.hide()

func _process(_delta):
	if not has_triggered and is_instance_valid(player):
		if progress_bar and progress_bar.value <= energy_threshold:
			trigger_intervention()

func trigger_intervention():
	has_triggered = true 


	player.set_physics_process(false)


	var spawn_pos = player.global_position + Vector2(spawn_distance, 0)
	npc.global_position = spawn_pos
	npc.show()

	var direction = npc.global_position.direction_to(player.global_position)
	var target_position = player.global_position - (direction * stop_distance)
	var distance = npc.global_position.distance_to(target_position)
	var walk_time = distance / 150.0 

	var sprite = npc.get_node("AnimatedSprite2D") 

	if npc.global_position.x < player.global_position.x:
		sprite.play("walk_right") 
	else:
		sprite.play("walk_left")

	var tween = get_tree().create_tween()
	tween.tween_property(npc, "global_position", target_position, walk_time)

	await tween.finished
	sprite.play("idle_DD")


	if npc.has_method("_on_interact"):
		npc._on_interact()


		await npc.cutscene_finished 


		var exit_time = distance / 150.0 

		if spawn_pos.x > npc.global_position.x:
			sprite.play("walk_right_DD")
		else:
			sprite.play("walk_left_DD")

		var exit_tween = get_tree().create_tween()
		exit_tween.tween_property(npc, "global_position", spawn_pos, exit_time)

		await exit_tween.finished


		npc.hide()


		player.set_physics_process(true)
