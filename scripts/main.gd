extends Node2D

@export var points_per_second: float = 10.0
@export var difficulty_increase_every: float = 5.0

var score: float = 0.0
var high_score: float = 0.0
var game_over: bool = false
var difficulty_timer: float = 0.0
var is_playing: bool = false

@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D = $Spawner
@onready var ui_score: Label = $CanvasLayer/UI/ScoreLabel
@onready var ui_high_score: Label = $CanvasLayer/UI/HighScoreLabel
@onready var game_over_panel: Panel = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score: Label = $CanvasLayer/UI/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBoxContainer/RestartButton
@onready var floor_parallax: ParallaxBackground = $ParallaxBackground
@onready var obstacles: Node2D = $Obstacles
@onready var tap_to_start: Label = $CanvasLayer/UI/TapToStartLabel
@onready var floor_sprite: Node2D = $Floor

func _ready():
	load_high_score()
	update_ui()
	game_over_panel.visible = false
	tap_to_start.visible = true
	# Conectar señales
	if player:
		player.died.connect(_on_player_died)
	if spawner:
		spawner.obstacle_spawned.connect(_on_obstacle_spawned)
	if restart_button:
		restart_button.pressed.connect(restart_game)
	
	# Pausar inicio
	get_tree().paused = false
	is_playing = false
	if spawner:
		spawner.stop_spawning()

func _process(delta):
	if game_over:
		return
	
	if not is_playing:
		if Input.is_action_just_pressed("jump"):
			start_game()
		return
	
	# Aumentar score
	score += points_per_second * delta * (spawner.current_speed / spawner.initial_speed if spawner else 1.0)
	update_ui()
	
	# Dificultad progresiva
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_every:
		difficulty_timer = 0
		if spawner:
			spawner.increase_difficulty(25)
			points_per_second += 0.5

	# Mover floor parallax manualmente si es necesario (se hace en shader/material)
	# El parallax background se mueve automáticamente si tiene ParallaxLayer con motion

func start_game():
	is_playing = true
	tap_to_start.visible = false
	game_over = false
	score = 0
	if spawner:
		spawner.reset()
		spawner.start_spawning()
	if player:
		player.reset_player()
	update_ui()

func _on_player_died():
	if game_over:
		return
	game_over = true
	is_playing = false
	if spawner:
		spawner.stop_spawning()
	
	if score > high_score:
		high_score = score
		save_high_score()
	
	game_over_score.text = "Score: %d\nBest: %d" % [int(score), int(high_score)]
	game_over_panel.visible = true
	# Animación game over
	game_over_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.4)

func restart_game():
	game_over_panel.visible = false
	for child in obstacles.get_children():
		child.queue_free()
	start_game()

func _on_obstacle_spawned(obstacle):
	obstacle.passed.connect(func(): 
		if not game_over:
			score += 15
	)

func update_ui():
	if ui_score:
		ui_score.text = "Score: %d" % int(score)
	if ui_high_score:
		ui_high_score.text = "Best: %d" % int(high_score)

func is_game_over() -> bool:
	return game_over

func save_high_score():
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.save("user://save.cfg")

func load_high_score():
	var config = ConfigFile.new()
	var err = config.load("user://save.cfg")
	if err == OK:
		high_score = config.get_value("game", "high_score", 0.0)
	else:
		high_score = 0.0

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		if not is_playing and not game_over:
			start_game()
