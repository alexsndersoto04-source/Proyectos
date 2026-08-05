extends Node2D

# Level base class - Handles level logic

signal level_complete

@export var level_number: int = 1
@export var level_name: String = "Level"
@export var time_limit: int = 300  # seconds
@export var next_level_path: String = ""

var time_remaining: int
var is_complete: bool = false

@onready var player_spawn: Marker2D = $PlayerSpawn
@onready var level_exit: Area2D = $LevelExit
@onready var hud: Control = $HUD
@onready var background: ParallaxBackground = $ParallaxBackground

func _ready():
	time_remaining = time_limit
	
	# Connect level exit
	if level_exit:
		level_exit.body_entered.connect(_on_exit_reached)
	
	# Start timer
	start_timer()
	
	# Update HUD
	update_hud()

func start_timer():
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	if not is_complete:
		time_remaining -= 1
		update_hud()
		
		if time_remaining <= 0:
			# Time's up - player loses
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.die()

func update_hud():
	if hud:
		hud.update_time(time_remaining)
		hud.update_level(level_number)
		hud.update_score(GameManager.score)
		hud.update_lives(GameManager.lives)

func _on_exit_reached(body):
	if body.is_in_group("player") and not is_complete:
		complete_level()

func complete_level():
	is_complete = true
	GameManager.complete_level()
	
	# Show completion effect
	var tween = create_tween()
	tween.tween_property(background, "modulate", Color.GREEN, 0.5)
	
	# Load next level after delay
	await get_tree().create_timer(1.5).timeout
	LevelManager.next_level()

func _process(delta):
	# Update any level-specific logic
	pass
