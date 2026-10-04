extends Node2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var sprite = $AnimatedSprite2D
@onready var speech_sound = preload("res://assets/vadim_makes_sound-soft-app-button-tap-sound-5-547873 (1).mp3")

signal energy_changed(amount: float)
signal cutscene_finished 

@export_group("Настройки за Енергия")
@export var reward_amount: float = 20.0
@export var penalty_amount: float = 10.0

# Настройки за височината на балончето над главите им
@export_group("Позиция на диалога (Офсет)")
@export var npc_offset: Vector2 = Vector2(0, -100)
@export var player_offset: Vector2 = Vector2(0, -100)

# 1. Реплики за начален разговор
const npc_intro: Array[String] = ["Mate you are sweating like a pig. You don’t think you will make it this way do you?"]
const player_intro: Array[String] = ["And and how tell me how WOULD YOU KNOW. You, YOU don’t know ME."]
const npc_talk: Array[String] = ["Champ I have seen many like you. They drop, they all drop. You will as wel"]
const player_yes_reply: Array[String] = ["Maybe one more won’t hurt… Would it fix me?"]
const npc_talk1: Array[String] = ["You would be as good as new. I don’t lie to customers, you know that! Come on now"]
const npc_talk2: Array[String] = [" It will restore your energy, you could do your job. You will even have the energy for MUSpok Bockson MORE AFTER!"]
const npc_quet: Array[String]= ["Now what do you say to your old friend? Once more ?”"]

const npc_question: Array[String] = ["But is it too good to be true? [Y] Yes / [N] No"]

# 2. Реплики при избор "ДА"
const npc_yes_reply: Array[String] = ["Now this is my boy! That is why you are my favourite! See you tomorrow again!"]

# 3. Реплики при избор "НЕ"
const player_ring_ring: Array[String] = ["RIng RingRIng RIng"]
const player_no_reply: Array[String] = ["HEY Spok Bockson don’t worry about the job. Joe from the department did it."]
const npc_no_reply: Array[String] = ["You will come tomorrow on your own. I know YOUR KIND BOY"]
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
	DialogManager.start_dialog(npc_pos, npc_intro, speech_sound,)
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
	
	var e_press = InputEventAction.new()
	e_press.action = "interact" 
	e_press.pressed = true
	Input.parse_input_event(e_press)
	
	await get_tree().create_timer(0.2).timeout
	
	var npc_pos = global_position + npc_offset
	
	if is_yes:
		if is_instance_valid(player_node):
			player_node.energy += reward_amount
			var player_pos = player_node.global_position + player_offset
			DialogManager.start_dialog(player_pos, player_yes_reply, speech_sound)
			await DialogManager.dialog_finished
		
		DialogManager.start_dialog(npc_pos, npc_yes_reply, speech_sound)
		await DialogManager.dialog_finished # Чакаме да си изрече репликата
		
	else:
		if is_instance_valid(player_node):
			player_node.energy -= penalty_amount
			var player_pos = player_node.global_position + player_offset
			DialogManager.start_dialog(player_pos, player_no_reply, speech_sound)
			await DialogManager.dialog_finished
			
		DialogManager.start_dialog(npc_pos, npc_no_reply, speech_sound)
		await DialogManager.dialog_finished # Чакаме да си изрече репликата
		
	# 3. ИЗПРАЩАМЕ СИГНАЛ КЪМ МЕНИДЖЪРА, ЧЕ СМЕ ПРИКЛЮЧИЛИ
	cutscene_finished.emit()
