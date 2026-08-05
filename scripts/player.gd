extends CharacterBody2D

@export var jump_force: float = -650.0
@export var gravity: float = 1800.0
@export var double_jump_enabled: bool = true

var is_dead: bool = false
var jumps_left: int = 1
var on_floor_last: bool = false
var has_shield: bool = false
var slow_timer: float = 0.0

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_particles: GPUParticles2D = $JumpParticles
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var audio_jump: AudioStreamPlayer = $AudioJump
@onready var audio_double: AudioStreamPlayer = $AudioDoubleJump
@onready var audio_death: AudioStreamPlayer = $AudioDeath
@onready var shield_visual: Node2D = $ShieldVisual

signal died
signal shield_changed(active: bool)

func _ready():
	jumps_left = 2 if double_jump_enabled else 1
	if shield_visual:
		shield_visual.visible = false

func _physics_process(delta):
	if is_dead:
		return
	if slow_timer > 0:
		slow_timer -= delta
		if slow_timer <= 0:
			Engine.time_scale = 1.0
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if not on_floor_last:
			anim_sprite.play("run")
			jumps_left = 2 if double_jump_enabled else 1
			if jump_particles:
				jump_particles.emitting = false
	on_floor_last = is_on_floor()
	if Input.is_action_just_pressed("jump"):
		try_jump()
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
		if audio_jump:
			audio_jump.pitch_scale = randf_range(0.9, 1.1)
			audio_jump.play()
		if jump_particles:
			jump_particles.restart()
			jump_particles.emitting = true
	elif jumps_left > 0:
		velocity.y = jump_force * 0.9
		jumps_left -= 1
		anim_sprite.play("double_jump")
		if audio_double:
			audio_double.pitch_scale = randf_range(0.95, 1.15)
			audio_double.play()
		if jump_particles:
			jump_particles.restart()
			jump_particles.emitting = true
		var tween = create_tween()
		tween.tween_property(anim_sprite, "scale", Vector2(1.2, 0.8), 0.05)
		tween.tween_property(anim_sprite, "scale", Vector2(1.0, 1.0), 0.1)

func die():
	if is_dead:
		return
	if has_shield:
		# consumir escudo en vez de morir
		has_shield = false
		if shield_visual:
			shield_visual.visible = false
		shield_changed.emit(false)
		# efecto de escudo roto
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0.2, 0.8, 1.0, 1), 0.05)
		tween.tween_property(self, "modulate", Color(1,1,1,1), 0.2)
		# invulnerabilidad breve
		collision_shape.disabled = true
		await get_tree().create_timer(0.8).timeout
		if not is_dead:
			collision_shape.disabled = false
		return
	is_dead = true
	velocity = Vector2.ZERO
	if audio_death:
		audio_death.play()
	anim_sprite.play("die")
	var tween = create_tween()
	tween.parallel().tween_property(anim_sprite, "modulate", Color(1,0.2,0.2,1), 0.2)
	tween.parallel().tween_property(self, "rotation", deg_to_rad(15), 0.3)
	tween.tween_interval(0.2)
	died.emit()

func give_shield():
	has_shield = true
	if shield_visual:
		shield_visual.visible = true
		shield_visual.scale = Vector2.ZERO
		var tween = create_tween()
		tween.tween_property(shield_visual, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	shield_changed.emit(true)

func activate_slow(duration: float = 3.0):
	Engine.time_scale = 0.5
	slow_timer = duration

func add_coin():
	# efecto visual de moneda
	var tween = create_tween()
	tween.tween_property(anim_sprite, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(anim_sprite, "scale", Vector2.ONE, 0.12)

func reset_player():
	is_dead = false
	has_shield = false
	slow_timer = 0.0
	Engine.time_scale = 1.0
	rotation = 0
	modulate = Color(1,1,1,1)
	if shield_visual:
		shield_visual.visible = false
	anim_sprite.modulate = Color(1,1,1,1)
	anim_sprite.scale = Vector2.ONE
	anim_sprite.play("run")
	velocity = Vector2.ZERO
	jumps_left = 2 if double_jump_enabled else 1
	collision_shape.disabled = false
	shield_changed.emit(false)
