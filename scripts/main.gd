extends Node2D
var score: float = 0
var game_over: bool = false
var is_playing: bool = false
var coins: int = 0
@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D = $Spawner
@onready var ui_score: Label = $CanvasLayer/UI/ScoreLabel
@onready var game_over_panel: Panel = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score: Label = $CanvasLayer/UI/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBoxContainer/RestartButton
@onready var obstacles: Node2D = $Obstacles
@onready var powerups: Node2D = $PowerUps
func _ready():
	game_over_panel.visible = false
	if player: player.died.connect(_on_died)
	if spawner: 
		spawner.obstacle_spawned.connect(_on_obstacle)
		spawner.powerup_spawned.connect(_on_powerup)
	if restart_button: restart_button.pressed.connect(_on_restart)
func _process(delta):
	if game_over: return
	if not is_playing:
		if Input.is_action_just_pressed("jump"): _start()
		return
	score += 10 * delta
	if ui_score: ui_score.text = "Score: %d Coins: %d" % [int(score), coins]
func _start():
	is_playing = true
	game_over = false
	score = 0
	coins = 0
	if spawner:
		spawner.reset()
		spawner.start_spawning()
	if player: player.reset_player()
func _on_died():
	game_over = true
	is_playing = false
	if spawner: spawner.stop_spawning()
	game_over_score.text = "Score: %d Coins: %d" % [int(score), coins]
	game_over_panel.visible = true
func _on_restart():
	game_over_panel.visible = false
	for c in obstacles.get_children(): c.queue_free()
	for c in powerups.get_children(): c.queue_free()
	_start()
func _on_obstacle(o):
	o.passed.connect(func(): if not game_over: score += 15)
func _on_powerup(p):
	p.collected.connect(_on_collected)
func _on_collected(t):
	match t:
		"shield": player.give_shield(); score += 30
		"slow": player.activate_slow(3.0); score += 20
		"coin": coins += 1; score += 50
func is_game_over(): return game_over
func _input(e):
	if e is InputEventScreenTouch and e.pressed:
		if not is_playing and not game_over: _start()
