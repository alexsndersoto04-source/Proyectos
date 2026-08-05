extends Area2D
var speed: float = 400.0
var type: String = "spike"
var scored: bool = false
signal passed
func _ready(): body_entered.connect(_on_enter)
func _process(delta):
	if get_parent() and get_parent().has_method("is_game_over") and get_parent().is_game_over(): return
	position.x -= speed * delta
	if position.x < -200: queue_free()
	if not scored and position.x < 180:
		scored = true
		passed.emit()
func _on_enter(b):
	if b.is_in_group("player") and b.has_method("die"): b.die()
func set_speed(s): speed = s
