extends Node2D

# --- References to nodes in the main scene ---------------------------------
@onready var player: Area2D = $Player
@onready var score_label: Label = $UI/ScoreLabel
@onready var hint_label: Label = $UI/HintLabel
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var spawn_timer: Timer = $ObstacleSpawner

# --- Gameplay tuning --------------------------------------------------------
@export var scroll_speed := 340.0
@export var obstacle_size := Vector2(42, 42)
@export var obstacle_y := 700.0

var score := 0.0
var playing := false
var obstacles: Array[Area2D] = []

const OBSTACLE_COLOR := Color(0.85, 0.25, 0.35, 1.0)


func _ready() -> void:
	player.area_entered.connect(_on_player_area_entered)
	spawn_timer.timeout.connect(_spawn_obstacle)
	start_game()


func _process(delta: float) -> void:
	if not playing:
		return

	# Increase the score over time.
	score += delta * 10.0
	score_label.text = "Score: %d" % int(score)

	# Move every obstacle towards the player (to the left).
	for ob in obstacles:
		if is_instance_valid(ob):
			ob.position.x -= scroll_speed * delta

	# Remove obstacles that went off-screen.
	for ob in obstacles.duplicate():
		if not is_instance_valid(ob):
			obstacles.erase(ob)
		elif ob.position.x < -80.0:
			ob.queue_free()
			obstacles.erase(ob)


func start_game() -> void:
	score = 0.0
	playing = true

	game_over_label.visible = false
	hint_label.text = "Toca para saltar"
	hint_label.visible = true
	score_label.text = "Score: 0"

	player.is_dead = false
	player.position = Vector2(120, 400)
	player.velocity = Vector2.ZERO

	# Clear any leftover obstacles from a previous run.
	for ob in obstacles:
		if is_instance_valid(ob):
			ob.queue_free()
	obstacles.clear()

	spawn_timer.start()


func _spawn_obstacle() -> void:
	var ob := Area2D.new()
	ob.collision_layer = 1
	ob.collision_mask = 0
	ob.position = Vector2(760, obstacle_y)

	# Collision shape.
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = obstacle_size
	shape.shape = rect
	ob.add_child(shape)

	# Simple visual.
	var spr := Polygon2D.new()
	spr.polygon = PackedVector2Array([
		Vector2(-obstacle_size.x * 0.5, -obstacle_size.y * 0.5),
		Vector2(obstacle_size.x * 0.5, -obstacle_size.y * 0.5),
		Vector2(obstacle_size.x * 0.5, obstacle_size.y * 0.5),
		Vector2(-obstacle_size.x * 0.5, obstacle_size.y * 0.5),
	])
	spr.color = OBSTACLE_COLOR
	ob.add_child(spr)

	add_child(ob)
	obstacles.append(ob)


func _on_player_area_entered(_area: Area2D) -> void:
	game_over()


func game_over() -> void:
	if not playing:
		return
	playing = false
	spawn_timer.stop()
	player.is_dead = true
	game_over_label.visible = true
	hint_label.text = "Toca para reiniciar"
	hint_label.visible = true


func _unhandled_input(event: InputEvent) -> void:
	# Work for both touch (mobile) and mouse (desktop testing).
	if event is InputEventScreenTouch and event.pressed:
		_handle_tap()
	elif event is InputEventMouseButton and event.pressed:
		_handle_tap()


func _handle_tap() -> void:
	if playing:
		player.jump()
	else:
		start_game()
