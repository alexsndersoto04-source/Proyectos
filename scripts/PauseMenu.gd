extends Control

# Pause Menu

@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton

var is_paused: bool = false

func _ready():
	visible = false
	
	resume_button.pressed.connect(_on_resume_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Listen for pause input
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	is_paused = not is_paused
	visible = is_paused
	get_tree().paused = is_paused

func _on_resume_pressed():
	toggle_pause()

func _on_restart_pressed():
	toggle_pause()
	LevelManager.reload_current_level()

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_main_menu_pressed():
	toggle_pause()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
