extends Node2D

@export var obstacle_scene: PackedScene
@export var min_interval: float = 1.0
@export var max_interval: float = 2.2
@export var initial_speed: float = 400.0
@export var max_speed: float = 900.0

var current_speed: float = 400.0
var timer: Timer
var is_spawning: bool = false

@onready var obstacles_container: Node2D = $"../Obstacles"

signal obstacle_spawned(obstacle)

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
	# Reduce interval based on speed (más difícil)
	var speed_factor = current_speed / initial_speed
	interval = max(0.5, interval / speed_factor)
	timer.wait_time = interval
	timer.start()

func _on_timer_timeout():
	spawn_obstacle()
	_schedule_next()

func spawn_obstacle():
	if not obstacle_scene or not obstacles_container:
		return
	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(1400, 520) # fuera de pantalla a la derecha
	# Variación en Y según tipo
	var type_roll = randf()
	if type_roll < 0.33:
		obstacle.type = "spike"
		obstacle.position.y = 528
	elif type_roll < 0.66:
		obstacle.type = "block"
		obstacle.position.y = 525
	else:
		obstacle.type = "void_orb"
		obstacle.position.y = randf_range(380, 500)
	
	obstacle.set_speed(current_speed)
	obstacles_container.add_child(obstacle)
	obstacle_spawned.emit(obstacle)

func increase_difficulty(amount: float):
	current_speed = min(max_speed, current_speed + amount)
	# Actualizar velocidad de obstáculos existentes
	if obstacles_container:
		for child in obstacles_container.get_children():
			if child.has_method("set_speed"):
				child.set_speed(current_speed)

func reset():
	current_speed = initial_speed
	for child in obstacles_container.get_children():
		child.queue_free()
