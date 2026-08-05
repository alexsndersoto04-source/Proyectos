extends Node

# GameManager - Global game state and utilities

signal score_changed(new_score)
signal lives_changed(new_lives)
signal game_over
signal level_completed

var score: int = 0
var lives: int = 3
var current_level: int = 1
var total_levels: int = 20
var high_score: int = 0

# Power-up states
var has_double_jump: bool = false
var has_void_dash: bool = false
var has_shield: bool = false
var shield_active: bool = false

# Player stats
var coins_collected: int = 0
var enemies_defeated: int = 0
var deaths: int = 0

func _ready():
	load_high_score()

func add_score(points: int):
	score += points
	score_changed.emit(score)
	if score > high_score:
		high_score = score
		save_high_score()

func lose_life():
	lives -= 1
	deaths += 1
	lives_changed.emit(lives)
	if lives <= 0:
		game_over.emit()

func gain_life():
	lives += 1
	lives_changed.emit(lives)

func reset_powerups():
	has_double_jump = false
	has_void_dash = false
	has_shield = false
	shield_active = false

func complete_level():
	level_completed.emit()
	add_score(1000) # Bonus for completing level
	current_level += 1

func reset_game():
	score = 0
	lives = 3
	current_level = 1
	coins_collected = 0
	enemies_defeated = 0
	deaths = 0
	reset_powerups()

func save_high_score():
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	if file:
		file.store_var(high_score)
		file.close()

func load_high_score():
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		if file:
			high_score = file.get_var()
			file.close()
