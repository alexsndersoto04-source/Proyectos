extends CharacterBody2D

const SPEED = 220.0
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Variables para control táctil
var move_left = false
var move_right = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento por botones en pantalla o teclado
	var dir = 0.0
	if move_left:
		dir -= 1.0
	if move_right:
		dir += 1.0
	
	if dir == 0.0:
		dir = Input.get_axis("ui_left", "ui_right")

	if dir != 0.0:
		velocity.x = dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_left_pressed():
	move_left = true

func _on_left_released():
	move_left = false

func _on_right_pressed():
	move_right = true

func _on_right_released():
	move_right = false

func _on_jump_pressed():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
