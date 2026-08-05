extends Node2D

@export var points_per_second: float = 10.0
@export var difficulty_increase_every: float = 5.0

var score: float = 0.0
var high_score: float = 0.0
var game_over: bool = false
var difficulty_timer: float = 0.0
var is_playing: bool = false
var coins: int = 0

@onready var player: CharacterBody2D = $Player
@onready var spawner: Node2D = $Spawner
@onready var ui_score: Label = $CanvasLayer/UI/ScoreLabel
@onready var ui_high_score: Label = $CanvasLayer/UI/HighScoreLabel
@onready var ui_coins: Label = $CanvasLayer/UI/CoinsLabel
@onready var ui_shield: Control = $CanvasLayer/UI/ShieldIndicator
@onready var game_over_panel: Panel = $CanvasLayer/UI/GameOverPanel
@onready var game_over_score: Label = $CanvasLayer/UI/GameOverPanel/VBoxContainer/FinalScoreLabel
@onready var restart_button: Button = $CanvasLayer/UI/GameOverPanel/VBoxContainer/RestartButton
@onready var obstacles: Node2D = $Obstacles
@onready var powerups: Node2D = $PowerUps
@onready var tap_to_start: Control = $CanvasLayer/UI/StartPanel
@onready var audio_score: AudioStreamPlayer = $AudioScore
@onready var audio_ambience: AudioStreamPlayer = $AudioAmbience
@onready var audio_powerup: AudioStreamPlayer = $AudioPowerUp

func _ready():
	load_high_score()
	update_ui()
	game_over_panel.visible = false
	tap_to_start.visible = true
	if ui_shield:
		ui_shield.visible = false
	if player:
		player.died.connect(_on_player_died)
		player.shield_changed.connect(_on_shield_changed)
	if spawner:
		spawner.obstacle_spawned.connect(_on_obstacle_spawned)
		spawner.powerup_spawned.connect(_on_powerup_spawned)
	if restart_button:
		restart_button.pressed.connect(restart_game)
	get_tree().paused = false
	is_playing = false
	if spawner:
		spawner.stop_spawning()
	if audio_ambience:
		audio_ambience.play()

func _process(delta):
	if game_over:
		return
	if not is_playing:
		if Input.is_action_just_pressed("jump"):
			start_game()
		return
	score += points_per_second * delta * (spawner.current_speed / spawner.initial_speed if spawner else 1.0)
	update_ui()
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_every:
		difficulty_timer = 0
		if spawner:
			spawner.increase_difficulty(25)
			points_per_second += 0.5

func start_game():
	is_playing = true
	tap_to_start.visible = false
	game_over = false
	score = 0
	coins = 0
	difficulty_timer = 0
	points_per_second = 10.0
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
	game_over_score.text = "Score: %d\nCoins: %d\nBest: %d" % [int(score), coins, int(high_score)]
	game_over_panel.visible = true
	game_over_panel.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(game_over_panel, "modulate:a", 1.0, 0.4)

func restart_game():
	game_over_panel.visible = false
	for child in obstacles.get_children():
		child.queue_free()
	if powerups:
		for child in powerups.get_children():
			child.queue_free()
	start_game()

func _on_obstacle_spawned(obstacle):
	obstacle.passed.connect(func(): 
		if not game_over:
			score += 15
			if audio_score:
				audio_score.pitch_scale = randf_range(0.9, 1.2)
				audio_score.play()
	)

func _on_powerup_spawned(pu):
	pu.collected.connect(_on_powerup_collected)

func _on_powerup_collected(type: String):
	match type:
		"shield":
			if player:
				player.give_shield()
			score += 30
		"slow":
			if player:
				player.activate_slow(3.5)
			score += 20
		"coin":
			coins += 1
			score += 50
			if player:
				player.add_coin()
	if audio_powerup:
		audio_powerup.pitch_scale = randf_range(0.9, 1.2)
		audio_powerup.play()
	update_ui()

func _on_shield_changed(active: bool):
	if ui_shield:
		ui_shield.visible = active
		if active:
			var tween = create_tween()
			ui_shield.scale = Vector2.ZERO
			tween.tween_property(ui_shield, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)

func update_ui():
	if ui_score:
		ui_score.text = "Score: %d" % int(score)
	if ui_high_score:
		ui_high_score.text = "Best: %d" % int(high_score)
	if ui_coins:
		ui_coins.text = "Coins: %d" % coins

func is_game_over() -> bool:
	return game_over

func save_high_score():
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.set_value("game", "coins", coins)
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
