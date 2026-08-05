extends CharacterBody2D

# Base Enemy Class - Different enemy types with unique behaviors

enum EnemyType = {
	PATROL,      # Walks back and forth
	FLYING,      # Flies in patterns
	CHASER,      # Chases player when close
	STATIC,      # Stays in place (turret-like)
	JUMPER,      # Jumps periodically
	BOSS         # Large enemy with multiple attacks
}

@export var enemy_type: int = EnemyType.PATROL
@export var move_speed: float = 100.0
@export var patrol_distance: float = 200.0
@export var health: int = 1
@export var damage: int = 1
@export var score_value: int = 100

var start_position: Vector2
var direction: float = 1.0
var is_alive: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	start_position = position
	add_to_group("enemies")

func _physics_process(delta):
	if not is_alive:
		return
	
	match enemy_type:
		EnemyType.PATROL:
			patrol_behavior(delta)
		EnemyType.FLYING:
			flying_behavior(delta)
		EnemyType.CHASER:
			chaser_behavior(delta)
		EnemyType.STATIC:
			static_behavior(delta)
		EnemyType.JUMPER:
			jumper_behavior(delta)
		EnemyType.BOSS:
			boss_behavior(delta)
	
	move_and_slide()

func patrol_behavior(delta):
	velocity.x = move_speed * direction
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	# Check patrol bounds
	if position.x > start_position.x + patrol_distance:
		direction = -1
	elif position.x < start_position.x - patrol_distance:
		direction = 1
	
	# Flip sprite
	if sprite:
		sprite.flip_h = direction < 0

func flying_behavior(delta):
	# Sinusoidal flying pattern
	var time = Time.get_time_dict_from_system().second
	velocity.x = move_speed * direction
	velocity.y = sin(time * 3) * 50
	
	if position.x > start_position.x + patrol_distance:
		direction = -1
	elif position.x < start_position.x - patrol_distance:
		direction = 1

func chaser_behavior(delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = position.distance_to(player.position)
		if distance < 300:
			# Chase player
			var direction_to_player = (player.position - position).normalized()
			velocity = direction_to_player * move_speed * 1.5
		else:
			# Patrol
			patrol_behavior(delta)

func static_behavior(delta):
	# Just sits there, maybe rotates to face player
	velocity.x = 0
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

func jumper_behavior(delta):
	velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta
	
	if is_on_floor():
		velocity.y = -400
		velocity.x = move_speed * direction

func boss_behavior(delta):
	# Complex boss behavior - moves and attacks
	velocity.x = move_speed * direction * 0.5
	
	# Change direction periodically
	if randf() < 0.01:
		direction *= -1
	
	# Jump occasionally
	if is_on_floor() and randf() < 0.02:
		velocity.y = -350

func take_damage(amount: int = 1):
	health -= amount
	if health <= 0:
		die()
	else:
		# Flash effect
		if sprite:
			sprite.modulate = Color.RED
			await get_tree().create_timer(0.1).timeout
			sprite.modulate = Color.WHITE

func die():
	if not is_alive:
		return
	
	is_alive = false
	GameManager.add_score(score_value)
	
	# Death animation
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.velocity.y > 0 and body.position.y < position.y - 20:
			# Player stomped on enemy
			take_damage()
			body.stomp_enemy()
		else:
			# Player touched enemy
			body.take_damage()
