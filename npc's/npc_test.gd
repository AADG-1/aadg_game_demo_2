extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $Sprite2D
@onready var speech_sound = preload("res://assets/vadim_makes_sound-soft-app-button-tap-sound-5-547873 (1).mp3")

signal energy_changed(amount: float)

@export_group("Настройки за Енергия")
@export var reward_amount: float = 20.0
@export var penalty_amount: float = 10.0

# Настройки за височината на балончето над главите им
@export_group("Позиция на диалога (Офсет)")
@export var npc_offset: Vector2 = Vector2(0, -50)
@export var player_offset: Vector2 = Vector2(0, -40)

# 1. Реплики за начален разговор
const npc_intro: Array[String] = ["Здравей! Изглеждаш изтощен."]
const player_intro: Array[String] = ["Да, нямам никаква енергия..."]
const npc_question: Array[String] = ["Имаш ли нужда от помощ? [Y] Да / [N] Не"]

# 2. Реплики при избор "ДА"
const player_yes_reply: Array[String] = ["Да, благодаря ти!"]
const npc_yes_reply: Array[String] = ["Заповядай малко енергия!"]

# 3. Реплики при избор "НЕ"
const player_no_reply: Array[String] = ["Не, благодаря, оправям се сам."]
const npc_no_reply: Array[String] = ["Тогава си върви по пътя!"]

enum DialogueState { IDLE, WAITING_FOR_CHOICE }
var current_state: DialogueState = DialogueState.IDLE

var player_node: Node2D = null

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if current_state != DialogueState.IDLE:
		return

	var bodies = interaction_area.get_overlapping_bodies()
	if bodies.size() > 0:
		player_node = bodies[0]
		sprite.flip_h = player_node.global_position.x < global_position.x

	# 1. NPC говори над неговата глава
	var npc_pos = global_position + npc_offset
	DialogManager.start_dialog(npc_pos, npc_intro, speech_sound)
	await DialogManager.dialog_finished

	# 2. Героят говори над неговата глава
	if is_instance_valid(player_node):
		var player_pos = player_node.global_position + player_offset
		DialogManager.start_dialog(player_pos, player_intro, speech_sound)
		await DialogManager.dialog_finished

	# 3. NPC показва въпроса
	DialogManager.start_dialog(npc_pos, npc_question, speech_sound)
	current_state = DialogueState.WAITING_FOR_CHOICE

func _unhandled_input(event: InputEvent) -> void:
	if current_state != DialogueState.WAITING_FOR_CHOICE:
		return

	if Input.is_action_just_pressed("press_y"):
		_make_choice(true)
	elif Input.is_action_just_pressed("press_n"):
		_make_choice(false)

func _make_choice(is_yes: bool) -> void:
	current_state = DialogueState.IDLE
	
	# Изчакваме 0.15 секунди за чисто затваряне на въпроса
	await get_tree().create_timer(0.15).timeout
	
	var npc_pos = global_position + npc_offset
	
	if is_yes:
		# Подаваме енергия към ProgressBar
		energy_changed.emit(reward_amount)
		
		# Първо говори Героят, после NPC
		if is_instance_valid(player_node):
			var player_pos = player_node.global_position + player_offset
			DialogManager.start_dialog(player_pos, player_yes_reply, speech_sound)
			await DialogManager.dialog_finished
		
		DialogManager.start_dialog(npc_pos, npc_yes_reply, speech_sound)
		
	else:
		# Отнемаме енергия от ProgressBar
		energy_changed.emit(-penalty_amount)
		
		# Първо говори Героят, после NPC
		if is_instance_valid(player_node):
			var player_pos = player_node.global_position + player_offset
			DialogManager.start_dialog(player_pos, player_no_reply, speech_sound)
			await DialogManager.dialog_finished
			
		DialogManager.start_dialog(npc_pos, npc_no_reply, speech_sound)
