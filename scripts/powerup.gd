extends Area2D

@export var speed: float = 400.0
@export var type: String = "shield" # shield, slow, coin

@onready var visual: Node2D = $Visual

signal collected(type: String)

func _ready():
	body_entered.connect(_on_body_entered)
	setup_visual()
	# flotar
	var tween = create_tween().set_loops()
	tween.tween_property(self, "position:y", position.y - 10, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position:y", position.y + 10, 0.7).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func setup_visual():
	if not visual:
		return
	if visual.has_method("set_type"):
		visual.set_type(type)

func _process(delta):
	var parent = get_parent()
	if parent and parent.has_method("is_game_over") and parent.is_game_over():
		return
	position.x -= speed * delta
	if position.x < -200:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		collected.emit(type)
		queue_free()

func set_speed(s: float):
	speed = s
