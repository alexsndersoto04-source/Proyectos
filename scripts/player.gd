extends CharacterBody2D
@export var jump_force: float = -650.0
@export var gravity: float = 1800.0
var is_dead: bool = false
var jumps_left: int = 2
var has_shield: bool = false
@onready var shield_visual: ColorRect = $ShieldVisual
signal died
signal shield_changed(a: bool)
func _physics_process(delta):
	if is_dead: return
	if not is_on_floor(): velocity.y += gravity * delta
	else: jumps_left = 2
	if Input.is_action_just_pressed("jump"): try_jump()
	move_and_slide()
func try_jump():
	if is_dead: return
	if is_on_floor():
		velocity.y = jump_force
		jumps_left = 1
	elif jumps_left > 0:
		velocity.y = jump_force * 0.9
		jumps_left -= 1
func die():
	if is_dead: return
	if has_shield:
		has_shield = false
		if shield_visual: shield_visual.visible = false
		shield_changed.emit(false)
		return
	is_dead = true
	died.emit()
func give_shield():
	has_shield = true
	if shield_visual: shield_visual.visible = true
	shield_changed.emit(true)
func activate_slow(d: float): Engine.time_scale = 0.5; await get_tree().create_timer(d).timeout; Engine.time_scale = 1.0
func add_coin(): pass
func reset_player():
	is_dead = false
	has_shield = false
	Engine.time_scale = 1.0
	if shield_visual: shield_visual.visible = false
	velocity = Vector2.ZERO
	shield_changed.emit(false)
