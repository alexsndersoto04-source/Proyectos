extends Node

# LevelGenerator - Procedurally generates level scenes

const LEVEL_WIDTH = 2000
const LEVEL_HEIGHT = 800
const PLATFORM_COUNT_MIN = 8
const PLATFORM_COUNT_MAX = 15
const ENEMY_COUNT_MIN = 3
const ENEMY_COUNT_MAX = 8
const COIN_COUNT_MIN = 5
const COIN_COUNT_MAX = 12

var platform_scene: PackedScene = preload("res://scenes/Platform.tscn")
var enemy_scene: PackedScene = preload("res://scenes/Enemy.tscn")
var coin_scene: PackedScene = preload("res://scenes/Coin.tscn")
var powerup_scene: PackedScene = preload("res://scenes/Powerup.tscn")

func generate_level(level_num: int) -> Node2D:
	var level = Node2D.new()
	level.name = "Level_%02d" % level_num
	
	# Add background
	var bg = ParallaxBackground.new()
	level.add_child(bg)
	
	var bg_rect = ColorRect.new()
	bg_rect.color = get_level_color(level_num)
	bg_rect.size = Vector2(LEVEL_WIDTH + 1000, LEVEL_HEIGHT + 500)
	bg_rect.position = Vector2(-500, -250)
	bg.add_child(bg_rect)
	
	# Generate ground
	generate_ground(level, level_num)
	
	# Generate platforms
	generate_platforms(level, level_num)
	
	# Generate enemies
	generate_enemies(level, level_num)
	
	# Generate coins
	generate_coins(level, level_num)
	
	# Generate power-ups
	generate_powerups(level, level_num)
	
	# Add player spawn
	var spawn = Marker2D.new()
	spawn.name = "PlayerSpawn"
	spawn.position = Vector2(100, 500)
	level.add_child(spawn)
	
	# Add level exit
	var exit = Area2D.new()
	exit.name = "LevelExit"
	exit.position = Vector2(LEVEL_WIDTH - 100, 300)
	level.add_child(exit)
	
	return level

func generate_ground(level: Node2D, level_num: int):
	var ground = StaticBody2D.new()
	ground.name = "Ground"
	ground.position = Vector2(LEVEL_WIDTH / 2, LEVEL_HEIGHT - 50)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(LEVEL_WIDTH, 32)
	collision.shape = shape
	ground.add_child(collision)
	
	# Visual
	var rect = ColorRect.new()
	rect.size = Vector2(LEVEL_WIDTH, 32)
	rect.position = Vector2(-LEVEL_WIDTH / 2, -16)
	rect.color = get_ground_color(level_num)
	ground.add_child(rect)
	
	level.add_child(ground)
	
	# Add gaps in ground for higher levels
	if level_num > 3:
		add_ground_gaps(level, level_num)

func add_ground_gaps(level: Node2D, level_num: int):
	var gap_count = min(level_num / 3, 5)
	for i in range(gap_count):
		var gap_pos = 300 + i * 300 + randf() * 100
		# Create hazard at gap
		var hazard = Area2D.new()
		hazard.position = Vector2(gap_pos, LEVEL_HEIGHT)
		level.add_child(hazard)

func generate_platforms(level: Node2D, level_num: int):
	var platform_count = PLATFORM_COUNT_MIN + (level_num * 2)
	platform_count = min(platform_count, PLATFORM_COUNT_MAX + level_num)
	
	var platforms_node = Node2D.new()
	platforms_node.name = "Platforms"
	level.add_child(platforms_node)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = level_num * 12345
	
	for i in range(platform_count):
		var platform = StaticBody2D.new()
		platform.name = "Platform_%d" % i
		
		var x = 200 + rng.randf() * (LEVEL_WIDTH - 400)
		var y = 200 + rng.randf() * 400
		platform.position = Vector2(x, y)
		
		var collision = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(80 + rng.randf() * 80, 20)
		collision.shape = shape
		platform.add_child(collision)
		
		# Visual
		var rect = ColorRect.new()
		rect.size = shape.size
		rect.position = -shape.size / 2
		rect.color = get_platform_color(level_num)
		platform.add_child(rect)
		
		platforms_node.add_child(platform)

func generate_enemies(level: Node2D, level_num: int):
	var enemy_count = ENEMY_COUNT_MIN + level_num / 2
	enemy_count = min(enemy_count, ENEMY_COUNT_MAX + level_num / 2)
	
	var enemies_node = Node2D.new()
	enemies_node.name = "Enemies"
	level.add_child(enemies_node)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = level_num * 54321
	
	for i in range(enemy_count):
		var enemy = CharacterBody2D.new()
		enemy.name = "Enemy_%d" % i
		
		var x = 300 + rng.randf() * (LEVEL_WIDTH - 500)
		var y = 200 + rng.randf() * 400
		enemy.position = Vector2(x, y)
		
		# Add enemy script
		var script = load("res://scripts/Enemy.gd")
		enemy.set_script(script)
		
		enemies_node.add_child(enemy)

func generate_coins(level: Node2D, level_num: int):
	var coin_count = COIN_COUNT_MIN + level_num
	coin_count = min(coin_count, COIN_COUNT_MAX + level_num)
	
	var coins_node = Node2D.new()
	coins_node.name = "Coins"
	level.add_child(coins_node)
	
	var rng = RandomNumberGenerator.new()
	rng.seed = level_num * 98765
	
	for i in range(coin_count):
		var coin = Area2D.new()
		coin.name = "Coin_%d" % i
		
		var x = 150 + rng.randf() * (LEVEL_WIDTH - 300)
		var y = 150 + rng.randf() * 500
		coin.position = Vector2(x, y)
		
		coins_node.add_child(coin)

func generate_powerups(level: Node2D, level_num: int):
	if level_num < 3:
		return
	
	var powerups_node = Node2D.new()
	powerups_node.name = "Powerups"
	level.add_child(powerups_node)
	
	# Add double jump at level 3
	if level_num == 3:
		var powerup = Area2D.new()
		powerup.name = "DoubleJump"
		powerup.position = Vector2(LEVEL_WIDTH / 2, 300)
		powerups_node.add_child(powerup)
	
	# Add void dash at level 5
	if level_num == 5:
		var powerup = Area2D.new()
		powerup.name = "VoidDash"
		powerup.position = Vector2(LEVEL_WIDTH / 2, 300)
		powerups_node.add_child(powerup)

func get_level_color(level_num: int) -> Color:
	var colors = [
		Color(0.05, 0.05, 0.12),  # Dark blue
		Color(0.08, 0.02, 0.12),  # Dark purple
		Color(0.02, 0.08, 0.12),  # Dark teal
		Color(0.12, 0.05, 0.05),  # Dark red
		Color(0.05, 0.12, 0.05),  # Dark green
	]
	return colors[level_num % colors.size()]

func get_ground_color(level_num: int) -> Color:
	var colors = [
		Color(0.2, 0.3, 0.5),
		Color(0.3, 0.2, 0.4),
		Color(0.2, 0.4, 0.4),
		Color(0.4, 0.3, 0.3),
		Color(0.3, 0.4, 0.3),
	]
	return colors[level_num % colors.size()]

func get_platform_color(level_num: int) -> Color:
	var colors = [
		Color(0.3, 0.4, 0.6),
		Color(0.4, 0.3, 0.5),
		Color(0.3, 0.5, 0.5),
		Color(0.5, 0.4, 0.4),
		Color(0.4, 0.5, 0.4),
	]
	return colors[level_num % colors.size()]
