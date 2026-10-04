extends CharacterBody2D
var speed = 250
@onready var animated_sprite = $AnimatedSprite2D
var direction_name = "down"
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	if input_direction.x > 0:
		direction_name = "right"
	elif input_direction.x < 0:
		direction_name = "left"
	elif input_direction.y > 0:
		direction_name = "down"
	elif input_direction.y < 0:
		direction_name = "up"
func _physics_process(_delta):
	get_input()
	move_and_slide()
	if velocity == Vector2.ZERO:
		animated_sprite.play("idle_" + direction_name)
	else:
		animated_sprite.play("move_" + direction_name)
