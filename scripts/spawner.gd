extends Node2D

@export var obstacle_scene: PackedScene
@export var powerup_scene: PackedScene
@export var min_interval: float = 0.9
@export var max_interval: float = 2.1
@export var initial_speed: float = 420.0
@export var max_speed: float = 900.0
@export var powerup_chance: float = 0.18

var current_speed: float = 420.0
var timer: Timer
var is_spawning: bool = false
var obstacles_spawned: int = 0

@onready var obstacles_container: Node2D = $"../Obstacles"
@onready var powerups_container: Node2D = $"../PowerUps"

signal obstacle_spawned(obstacle)
signal powerup_spawned(powerup)

func _ready():
	current_speed = initial_speed
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)

func start_spawning():
	is_spawning = true
	_schedule_next()

func stop_spawning():
	is_spawning = false
	timer.stop()

func _schedule_next():
	if not is_spawning:
		return
	var interval = randf_range(min_interval, max_interval)
	var speed_factor = current_speed / initial_speed
	interval = max(0.45, interval / speed_factor)
	timer.wait_time = interval
	timer.start()

func _on_timer_timeout():
	# 18% probabilidad de powerup cada 4-5 obstaculos
	if powerup_scene and obstacles_spawned % 5 == 0 and randf() < powerup_chance:
		spawn_powerup()
	else:
		spawn_obstacle()
	_schedule_next()

func spawn_obstacle():
	if not obstacle_scene or not obstacles_container:
		return
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(1400, 520)
	var type_roll = randf()
	if type_roll < 0.35:
		obstacle.type = "spike"
		obstacle.position.y = 528
	elif type_roll < 0.70:
		obstacle.type = "block"
		obstacle.position.y = 525
	else:
		obstacle.type = "void_orb"
		obstacle.position.y = randf_range(380, 500)
	obstacle.set_speed(current_speed)
	obstacles_container.add_child(obstacle)
	obstacles_spawned += 1
	obstacle_spawned.emit(obstacle)

func spawn_powerup():
	if not powerup_scene:
		return
	var container = powerups_container if powerups_container else obstacles_container
	if not container:
		return
	var pu = powerup_scene.instantiate()
	pu.position = Vector2(1400, randf_range(380, 520))
	var r = randf()
	if r < 0.4:
		pu.type = "shield"
	elif r < 0.7:
		pu.type = "slow"
	else:
		pu.type = "coin"
	pu.set_speed(current_speed * 0.95)
	container.add_child(pu)
	powerup_spawned.emit(pu)

func increase_difficulty(amount: float):
	current_speed = min(max_speed, current_speed + amount)
	if obstacles_container:
		for child in obstacles_container.get_children():
			if child.has_method("set_speed"):
				child.set_speed(current_speed)

func reset():
	current_speed = initial_speed
	obstacles_spawned = 0
	if obstacles_container:
		for child in obstacles_container.get_children():
			child.queue_free()
	if powerups_container:
		for child in powerups_container.get_children():
			child.queue_free()
