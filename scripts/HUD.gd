extends Control

# HUD - Heads Up Display

@onready var score_label: Label = $ScoreLabel
@onready var lives_label: Label = $LivesLabel
@onready var time_label: Label = $TimeLabel
@onready var level_label: Label = $LevelLabel
@onready var coins_label: Label = $CoinsLabel
@onready var powerup_container: HBoxContainer = $PowerupContainer

func _ready():
	# Connect to GameManager signals
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	
	# Initial update
	update_score(GameManager.score)
	update_lives(GameManager.lives)

func update_score(score: int):
	if score_label:
		score_label.text = "SCORE: " + str(score)

func update_lives(lives: int):
	if lives_label:
		lives_label.text = "LIVES: " + str(lives)

func update_time(time: int):
	if time_label:
		var minutes = time / 60
		var seconds = time % 60
		time_label.text = "TIME: " + "%02d:%02d" % [minutes, seconds]
		
		# Flash red when low time
		if time <= 30:
			time_label.modulate = Color.RED
		else:
			time_label.modulate = Color.WHITE

func update_level(level: int):
	if level_label:
		level_label.text = "LEVEL " + str(level)

func update_coins(coins: int):
	if coins_label:
		coins_label.text = "COINS: " + str(coins)

func _on_score_changed(new_score):
	update_score(new_score)

func _on_lives_changed(new_lives):
	update_lives(new_lives)

func show_powerup(icon: Texture2D, active: bool):
	# Show/hide powerup indicators
	pass
