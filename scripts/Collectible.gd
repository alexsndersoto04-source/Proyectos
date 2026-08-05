extends Area2D

# Collectible items - Coins, power-ups, etc.

enum CollectibleType = {
	COIN,
	HEALTH,
	DOUBLE_JUMP,
	VOID_DASH,
	SHIELD,
	STAR,        # Invincibility
	KEY          # For locked areas
}

@export var collectible_type: int = CollectibleType.COIN
@export var value: int = 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	add_to_group("collectibles")
	body_entered.connect(_on_body_entered)
	
	# Start floating animation
	if animation_player:
		animation_player.play("float")

func _on_body_entered(body):
	if body.is_in_group("player"):
		collect(body)

func collect(player):
	match collectible_type:
		CollectibleType.COIN:
			GameManager.add_score(value)
			GameManager.coins_collected += 1
		CollectibleType.HEALTH:
			GameManager.gain_life()
		CollectibleType.DOUBLE_JUMP:
			player.set_double_jump(true)
		CollectibleType.VOID_DASH:
			player.set_void_dash(true)
		CollectibleType.SHIELD:
			player.set_shield(true)
		CollectibleType.STAR:
			# Activate invincibility
			pass
		CollectibleType.KEY:
			# Add key to inventory
			pass
	
	# Collection effect
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)
