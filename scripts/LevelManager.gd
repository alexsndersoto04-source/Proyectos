extends Node

# LevelManager - Handles level loading and transitions

signal level_loaded(level_num)

@export var level_scenes: PackedStringArray = [
	"res://levels/Level_01.tscn",
	"res://levels/Level_02.tscn",
	"res://levels/Level_03.tscn",
	"res://levels/Level_04.tscn",
	"res://levels/Level_05.tscn",
	"res://levels/Level_06.tscn",
	"res://levels/Level_07.tscn",
	"res://levels/Level_08.tscn",
	"res://levels/Level_09.tscn",
	"res://levels/Level_10.tscn",
	"res://levels/Level_11.tscn",
	"res://levels/Level_12.tscn",
	"res://levels/Level_13.tscn",
	"res://levels/Level_14.tscn",
	"res://levels/Level_15.tscn",
	"res://levels/Level_16.tscn",
	"res://levels/Level_17.tscn",
	"res://levels/Level_18.tscn",
	"res://levels/Level_19.tscn",
	"res://levels/Level_20.tscn",
]

var current_level_node: Node = null

func _ready():
	# Generate levels if they don't exist
	ensure_levels_exist()

func ensure_levels_exist():
	# Level scenes will be created programmatically
	pass

func load_level(level_num: int):
	if level_num < 1 or level_num > level_scenes.size():
		push_error("Invalid level number: " + str(level_num))
		return
	
	# Clear current level
	if current_level_node:
		current_level_node.queue_free()
		await get_tree().process_frame
	
	# Load new level
	var level_path = level_scenes[level_num - 1]
	var level_scene = load(level_path)
	
	if level_scene:
		current_level_node = level_scene.instantiate()
		get_tree().root.add_child(current_level_node)
		level_loaded.emit(level_num)
	else:
		push_error("Failed to load level: " + level_path)

func reload_current_level():
	load_level(GameManager.current_level)

func next_level():
	if GameManager.current_level < level_scenes.size():
		load_level(GameManager.current_level + 1)
	else:
		# Game completed!
		get_tree().change_scene_to_file("res://scenes/GameComplete.tscn")

func get_total_levels() -> int:
	return level_scenes.size()
