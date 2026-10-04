extends CanvasLayer

# Put your lines of text here! You can add as many as you want.
@export var lines: Array[String] = [
	"Mann again??? My head is killing me from yesterdays’ ….",
	"No last weeks’ … or was it last month …",
	"Does it even matter when the accident was, after all this hell continues.",
	"Ahhh mom is calling… She… doesn’t need to hear from me…",]


var current_line: int = 0
var player: CharacterBody2D

# We grab the Label node so we can change its text
@onready var label = $Panel/Label

func _ready():
	# Find the player and freeze them when the game starts
	player = get_tree().get_first_node_in_group("player")
	if is_instance_valid(player):
		player.set_physics_process(false) 
	
	# Show the very first line of text
	show_text()

# This function listens for keyboard/mouse presses
func _input(event):
	# "ui_accept" is Spacebar or Enter by default
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		next_line()

func show_text():
	label.text = lines[current_line]

func next_line():
	current_line += 1
	
	# If we still have lines left, show the next one
	if current_line < lines.size():
		show_text()
	else:
		finish_monologue()

func finish_monologue():
	# Unfreeze the player so they can walk to the door
	if is_instance_valid(player):
		player.set_physics_process(true)
	
	# Delete the text box so it disappears from the screen
	queue_free()
