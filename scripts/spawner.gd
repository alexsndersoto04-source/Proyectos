extends Node2D
@export var obstacle_scene: PackedScene
@export var powerup_scene: PackedScene
var current_speed: float = 420.0
var timer: Timer
var is_spawning: bool = false
@onready var obstacles_container: Node2D = $"../Obstacles"
@onready var powerups_container: Node2D = $"../PowerUps"
signal obstacle_spawned(o)
signal powerup_spawned(p)
func _ready():
	current_speed = 420.0
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timeout)
func start_spawning():
	is_spawning = true
	_schedule()
func stop_spawning():
	is_spawning = false
	timer.stop()
func _schedule():
	if not is_spawning: return
	timer.wait_time = randf_range(0.9, 1.8)
	timer.start()
func _on_timeout():
	if randf() < 0.15 and powerup_scene:
		spawn_powerup()
	else:
		spawn_obstacle()
	_schedule()
func spawn_obstacle():
	if not obstacle_scene or not obstacles_container: return
	var o = obstacle_scene.instantiate()
	o.position = Vector2(1300, 528)
	o.type = ["spike","block","void_orb"].pick_random()
	if o.type == "void_orb": o.position.y = randf_range(380, 500)
	o.set_speed(current_speed)
	obstacles_container.add_child(o)
	obstacle_spawned.emit(o)
func spawn_powerup():
	if not powerup_scene: return
	var c = powerups_container if powerups_container else obstacles_container
	var p = powerup_scene.instantiate()
	p.position = Vector2(1300, randf_range(380, 500))
	p.type = ["shield","slow","coin"].pick_random()
	p.set_speed(current_speed)
	c.add_child(p)
	powerup_spawned.emit(p)
func increase_difficulty(a): current_speed = min(900, current_speed + a)
func reset():
	current_speed = 420.0
	for x in obstacles_container.get_children(): x.queue_free()
	if powerups_container:
		for x in powerups_container.get_children(): x.queue_free()
