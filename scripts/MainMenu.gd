extends Control

# Main Menu - Game start screen

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var level_select_button: Button = $VBoxContainer/LevelSelectButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var high_score_label: Label = $HighScoreLabel

func _ready():
	# Connect buttons
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	level_select_button.pressed.connect(_on_level_select_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Update high score
	high_score_label.text = "HIGH SCORE: " + str(GameManager.high_score)
	
	# Hide continue if no save
	continue_button.disabled = GameManager.current_level == 1

func _on_start_pressed():
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/Level_01.tscn")

func _on_continue_pressed():
	LevelManager.load_level(GameManager.current_level)

func _on_level_select_pressed():
	get_tree().change_scene_to_file("res://scenes/LevelSelect.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit_pressed():
	get_tree().quit()
