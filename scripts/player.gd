extends CharacterBody2D

@export var jump_force: float = -650.0
@export var gravity: float = 1800.0
@export var double_jump_enabled: bool = true

var is_dead: bool = false
var jumps_left: int = 1
var on_floor_last: bool = false

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_particles: GPUParticles2D = $JumpParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

signal died

func _ready():
	jumps_left = 2 if double_jump_enabled else 1

func _physics_process(delta):
	if is_dead:
		return

	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not on_floor_last:
			# Acaba de caer
			anim_sprite.play("run")
			jumps_left = 2 if double_jump_enabled else 1
			if jump_particles:
				jump_particles.emitting = false

	on_floor_last = is_on_floor()

	# Input salto
	if Input.is_action_just_pressed("jump"):
		try_jump()

	# Animación en aire
	if not is_on_floor():
		if velocity.y < 0:
			anim_sprite.play("jump")
		else:
			anim_sprite.play("fall")

	move_and_slide()

func try_jump():
	if is_dead:
		return
	if is_on_floor():
		velocity.y = jump_force
		jumps_left -= 1
		anim_sprite.play("jump")
		if jump_particles:
			jump_particles.restart()
			jump_particles.emitting = true
	elif jumps_left > 0:
		velocity.y = jump_force * 0.9
		jumps_left -= 1
		anim_sprite.play("double_jump")
		if jump_particles:
			jump_particles.restart()
			jump_particles.emitting = true
		# Efecto visual extra en doble salto
		var tween = create_tween()
		tween.tween_property(anim_sprite, "scale", Vector2(1.2, 0.8), 0.05)
		tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.1)

func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	anim_sprite.play("die")
	# Efecto de muerte
	var tween = create_tween()
	tween.parallel().tween_property(anim_sprite, "modulate", Color(1,0.2,0.2,1), 0.2)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(15), 0.3)
	tween.tween_interval(0.2)
	died.emit()

func reset_player():
	is_dead = false
	rotation = 0
	modulate = Color(1,1,1,1)
	anim_sprite.modulate = Color(1,1,1,1)
	anim_sprite.scale = Vector2.ONE
	anim_sprite.play("run")
	velocity = Vector2.ZERO
	jumps_left = 2 if double_jump_enabled else 1
