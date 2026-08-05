extends Area2D
class_name Player

# Player physics done manually for a simple endless-runner feel.
var velocity := Vector2.ZERO

@export var gravity := 2400.0
@export var jump_velocity := -880.0

# The Y position where the player rests on the ground.
@export var ground_y := 700.0

var is_dead := false

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	velocity.y += gravity * delta
	position.y += velocity.y * delta

	# Clamp to the ground.
	if position.y >= ground_y:
		position.y = ground_y
		velocity.y = 0.0


# Called by the game controller when the player should jump.
func jump() -> void:
	if is_dead:
		return
	velocity.y = jump_velocity
