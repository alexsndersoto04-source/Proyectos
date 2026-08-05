extends Control

# Settings Menu

@onready var music_slider: HSlider = $VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXSlider
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	
	# Load saved settings
	load_settings()

func _on_back_pressed():
	save_settings()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_music_changed(value: float):
	AudioManager.set_music_volume(value)

func _on_sfx_changed(value: float):
	AudioManager.set_sfx_volume(value)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)
	config.save("user://settings.cfg")

func load_settings():
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") == OK:
		music_slider.value = config.get_value("audio", "music_volume", 0.7)
		sfx_slider.value = config.get_value("audio", "sfx_volume", 0.8)
