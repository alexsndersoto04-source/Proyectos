extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -380.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()
