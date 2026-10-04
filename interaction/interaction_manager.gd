class_name InteractionArea
extends Area2D

@onready var player = get_tree().get_first_node_in_group("player")
@onready var label = $Label

const base_text = "[E] to "

var active_areas = []
var can_interact = true
var interact: Callable = func(): pass

func registar_area(area: InteractionArea):
	active_areas.push_back(area)


func unregistar_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta):
	if active_areas.size() > 0 && can_interact:
		active_areas.sort_custom(_sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 36
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()


func _sort_by_distance_to_player(area1, area2):
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	return area1_to_player < area2_to_player


func _input(event):
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0:
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
@export_group("Настройки за Монолога")
# Текстът на монолога (мислите на героя)
@export var monologue_lines: Array[String] = [
	"Got to get to work. An engineer should not be late… or at least that is what people say… I think at least… I haven’t talked to anyone in a long while… Why do I talk to myself again?  Maybe a side effet…",
	"Трябва да си почина малко преди да изляза отново."
]

@export var speech_sound: AudioStream = preload("res://assets/vadim_makes_sound-soft-app-button-tap-sound-5-547873 (1).mp3")
@export var player_offset: Vector2 = Vector2(0, -40) # Височина над главата

var has_triggered: bool = false # За да се пусне само веднъж

func _ready() -> void:
	# Свързваме сигнала за влизане в зоната
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	# Проверяваме дали това е играчът и дали монологът вече се е пускал
	if has_triggered:
		return
		
	# Ако нодът е играчът (проверка по име или клас)
	if body.name == "CharacterBody2D" or body is CharacterBody2D:
		has_triggered = true
		_play_monologue(body)

func _play_monologue(player: Node2D) -> void:
	# Изчакваме 1 кадър за стабилност
	await get_tree().process_frame
	
	# Пускаме балончето с мислите директно над главата на играча
	var player_pos = player.global_position + player_offset
	DialogManager.start_dialog(player_pos, monologue_lines, speech_sound)
