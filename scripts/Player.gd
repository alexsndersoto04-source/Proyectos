extends CharacterBody2D

# Player Controller - Void Runner
# Features: Double jump, wall jump, dash, void dash (teleport)

signal player_died
signal player_respawned

@export var move_speed: float = 300.0
@export var jump_force: float = -500.0
@export var gravity_multiplier: float = 1.5
@export var friction: float = 0.8
@export var air_friction: float = 0.9

# Dash variables
@export var dash_speed: float = 600.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.5

# Void Dash variables
@export var void_dash_distance: float = 200.0
@export var void_dash_cooldown: float = 1.0

# Wall jump variables
@export var wall_slide_speed: float = 100.0
@export var wall_jump_force: Vector2 = Vector2(400, -450)

# State tracking
var can_dash: bool = true
var can_void_dash: bool = true
var is_dashing: bool = false
var is_wall_sliding: bool = false
var jumps_remaining: int = 1
var max_jumps: int = 1
var facing_direction: float = 1.0
var is_alive: bool = true

# Coyote time and jump buffering
var coyote_time: float = 0.1
var coyote_timer: float = 0.0
var jump_buffer_time: float = 0.1
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer
@onready var void_dash_cooldown_timer: Timer = $VoidDashCooldownTimer
@onready var coyote_timer_node: Timer = $CoyoteTimer
@onready var jump_buffer_timer_node: Timer = $JumpBufferTimer
@onready var wall_check_left: RayCast2D = $WallCheckLeft
@onready var wall_check_right: RayCast2D = $WallCheckRight
@onready var void_dash_particles: CPUParticles2D = $VoidDashParticles
@onready var trail: Line2D = $Trail

func _ready():
	dash_timer.wait_time = dash_duration
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	
	dash_cooldown_timer.wait_time = dash_cooldown
	dash_cooldown_timer.one_shot = true
	dash_cooldown_timer.timeout.connect(_on_dash_cooldown_timeout)
	
	void_dash_cooldown_timer.wait_time = void_dash_cooldown
	void_dash_cooldown_timer.one_shot = true
	void_dash_cooldown_timer.timeout.connect(_on_void_dash_cooldown_timeout)
	
	coyote_timer_node.wait_time = coyote_time
	coyote_timer_node.one_shot = true
	coyote_timer_node.timeout.connect(_on_coyote_timeout)
	
	jump_buffer_timer_node.wait_time = jump_buffer_time
	jump_buffer_timer_node.one_shot = true
	jump_buffer_timer_node.timeout.connect(_on_jump_buffer_timeout)
	
	# Setup trail
	if trail:
		trail.clear_points()
		trail.width = 15.0
		trail.default_color = Color(0.2, 0.8, 1.0, 0.6)

func _physics_process(delta):
	if not is_alive:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * gravity_multiplier * delta
	
	# Handle wall sliding
	handle_wall_slide()
	
	# Handle dashing
	if is_dashing:
		move_and_slide()
		update_trail()
		return
	
	# Handle movement
	handle_movement(delta)
	
	# Handle jumping
	handle_jumping()
	
	# Handle dashing input
	handle_dash()
	
	# Handle void dash
	handle_void_dash()
	
	# Apply friction when on floor
	if is_on_floor() and not is_dashing:
		velocity.x *= friction
	
	# Update coyote time
	update_coyote_time()
	
	# Move the character
	move_and_slide()
	
	# Update sprite direction
	update_sprite()
	
	# Update trail
	update_trail()
	
	# Check for death (fall off map)
	if position.y > 1000:
		die()

func handle_movement(delta):
	var input_direction = Input.get_axis("move_left", "move_right")
	
	if input_direction != 0:
		velocity.x = move_speed * input_direction
		facing_direction = input_direction
	else:
		if is_on_floor():
			velocity.x = lerp(velocity.x, 0.0, 0.2)

func handle_jumping():
	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	
	# Execute jump if buffered and can jump
	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			perform_jump()
			jump_buffer_timer = 0
		elif is_wall_sliding:
			perform_wall_jump()
			jump_buffer_timer = 0
		elif jumps_remaining > 0 and GameManager.has_double_jump:
			perform_double_jump()
			jump_buffer_timer = 0
	
	# Variable jump height
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5

func perform_jump():
	velocity.y = jump_force
	jumps_remaining = max_jumps
	coyote_timer = 0

func perform_double_jump():
	velocity.y = jump_force * 0.9
	jumps_remaining -= 1
	# Visual effect
	create_jump_effect()

func perform_wall_jump():
	velocity = wall_jump_force
	# Push away from wall
	if wall_check_left.is_colliding():
		velocity.x = abs(velocity.x)
		facing_direction = 1
	elif wall_check_right.is_colliding():
		velocity.x = -abs(velocity.x)
		facing_direction = -1
	
	jumps_remaining = max_jumps
	create_jump_effect()

func handle_wall_slide():
	is_wall_sliding = false
	
	if not is_on_floor() and velocity.y > 0:
		if wall_check_left.is_colliding() and Input.is_action_pressed("move_left"):
			is_wall_sliding = true
			velocity.y = min(velocity.y, wall_slide_speed)
		elif wall_check_right.is_colliding() and Input.is_action_pressed("move_right"):
			is_wall_sliding = true
			velocity.y = min(velocity.y, wall_slide_speed)

func handle_dash():
	if Input.is_action_just_pressed("dash") and can_dash:
		start_dash()

func start_dash():
	is_dashing = true
	can_dash = false
	
	# Dash in facing direction or input direction
	var dash_direction = Input.get_axis("move_left", "move_right")
	if dash_direction == 0:
		dash_direction = facing_direction
	
	velocity = Vector2(dash_direction * dash_speed, 0)
	
	# Start timer
	dash_timer.start()
	dash_cooldown_timer.start()
	
	# Visual effect
	create_dash_effect()

func handle_void_dash():
	if Input.is_action_just_pressed("void_dash") and can_void_dash and GameManager.has_void_dash:
		perform_void_dash()

func perform_void_dash():
	can_void_dash = false
	
	# Calculate void dash target
	var dash_direction = Input.get_axis("move_left", "move_right")
	if dash_direction == 0:
		dash_direction = facing_direction
	
	var target_position = position + Vector2(dash_direction * void_dash_distance, 0)
	
	# Create particles at start
	if void_dash_particles:
		void_dash_particles.emitting = true
	
	# Teleport
	position = target_position
	
	# Create particles at end
	await get_tree().create_timer(0.05).timeout
	if void_dash_particles:
		void_dash_particles.emitting = false
	
	# Start cooldown
	void_dash_cooldown_timer.start()

func update_coyote_time():
	if is_on_floor():
		coyote_timer = coyote_time
		jumps_remaining = max_jumps
		was_on_floor = true
	elif was_on_floor:
		was_on_floor = false
		coyote_timer_node.start()

func update_sprite():
	if sprite:
		sprite.flip_h = facing_direction < 0
		
		# Tilt based on velocity
		var tilt = clamp(velocity.x / move_speed * 0.2, -0.3, 0.3)
		sprite.rotation = lerp(sprite.rotation, tilt, 0.1)

func update_trail():
	if trail:
		trail.add_point(Vector2.ZERO)
		if trail.get_point_count() > 15:
			trail.remove_point(0)
		
		# Fade trail based on speed
		var speed_ratio = velocity.length() / dash_speed
		trail.width = lerp(5.0, 20.0, speed_ratio)

func create_jump_effect():
	# Simple particle burst could go here
	pass

func create_dash_effect():
	# Could instantiate a dash trail effect
	pass

func die():
	if not is_alive:
		return
	
	is_alive = false
	visible = false
	player_died.emit()
	
	# Reset after delay
	await get_tree().create_timer(1.0).timeout
	respawn()

func respawn():
	is_alive = true
	visible = true
	velocity = Vector2.ZERO
	reset_powerups()
	player_respawned.emit()

func reset_powerups():
	can_dash = true
	can_void_dash = true
	jumps_remaining = max_jumps

func set_double_jump(enabled: bool):
	GameManager.has_double_jump = enabled
	max_jumps = 2 if enabled else 1
	jumps_remaining = max_jumps

func set_void_dash(enabled: bool):
	GameManager.has_void_dash = enabled

func set_shield(enabled: bool):
	GameManager.has_shield = enabled
	GameManager.shield_active = enabled

# Signal callbacks
func _on_dash_timer_timeout():
	is_dashing = false

func _on_dash_cooldown_timeout():
	can_dash = true

func _on_void_dash_cooldown_timeout():
	can_void_dash = true

func _on_coyote_timeout():
	coyote_timer = 0

func _on_jump_buffer_timeout():
	jump_buffer_timer = 0

# Damage handling
func take_damage():
	if GameManager.shield_active:
		GameManager.shield_active = false
		return
	
	die()

func stomp_enemy():
	velocity.y = jump_force * 0.7
