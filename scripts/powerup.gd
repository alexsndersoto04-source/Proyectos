extends Area2D
var speed: float = 400.0
var type: String = "shield"
signal collected(t: String)
func _ready(): body_entered.connect(_on_enter)
func _process(delta):
	if get_parent() and get_parent().has_method("is_game_over") and get_parent().is_game_over(): return
	position.x -= speed * delta
	if position.x < -200: queue_free()
func _on_enter(b):
	if b.is_in_group("player"):
		collected.emit(type)
		queue_free()
func set_speed(s): speed = s
