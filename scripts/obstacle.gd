extends Area2D

@export var speed: float = 400.0
@export var types: Array[String] = ["spike", "block", "void_orb"]

var type: String = "spike"
var scored: bool = false

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

signal passed

func _ready():
	if type == "" or type == "random":
		type = types.pick_random()
	
	setup_type()
	body_entered.connect(_on_body_entered)

func setup_type():
	if visual and visual.has_method("set_type"):
		visual.set_type(type)
	
	if collision:
		match type:
			"spike":
				var rect = RectangleShape2D.new()
				rect.size = Vector2(28, 42)
				collision.shape = rect
				collision.position = Vector2(0, 4)
				modulate = Color(1, 0.35, 0.45)
			"block":
				var rect = RectangleShape2D.new()
				rect.size = Vector2(38, 48)
				collision.shape = rect
				collision.position = Vector2(0, 0)
				modulate = Color(0.4, 0.7, 1.0)
			"void_orb":
				var circle = CircleShape2D.new()
				circle.radius = 20
				collision.shape = circle
				collision.position = Vector2(0, 0)
				modulate = Color(0.7, 0.45, 1.0)
				# flotar
				var tween = create_tween().set_loops()
				tween.tween_property(self, "position:y", position.y - 12, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(self, "position:y", position.y + 12, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _process(delta):
	var parent = get_parent()
	if parent and parent.has_method("is_game_over"):
		if parent.is_game_over():
			return
	position.x -= speed * delta
	
	if position.x < -200:
		queue_free()
	
	if not scored and position.x < 180:
		scored = true
		passed.emit()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("die") and not body.is_dead:
			body.die()

func set_speed(new_speed: float):
	speed = new_speed
