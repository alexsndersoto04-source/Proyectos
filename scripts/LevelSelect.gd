extends Control

# Level Select Screen

@onready var grid_container: GridContainer = $GridContainer
@onready var back_button: Button = $BackButton"

var level_button_scene = preload("res://scenes/LevelButton.tscn")

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	
	# Create level buttons
	for i in range(1, GameManager.total_levels + 1):
		var button = level_button_scene.instantiate()
		button.text = str(i)
		button.level_number = i
		
		# Lock levels beyond current progress
		if i > GameManager.current_level and GameManager.current_level > 1:
			button.disabled = true
		
		button.pressed.connect(_on_level_selected.bind(i))
		grid_container.add_child(button)

func _on_level_selected(level_num: int):
	LevelManager.load_level(level_num)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
