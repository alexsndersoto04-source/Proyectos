extends Node2D
@export var star_count: int = 80
@export var speed: float = 10.0
@export var layer: int = 0

func _draw():
	for i in range(star_count):
		var seed_val = i * 137.5 + layer * 1000.0
		var x = fmod(seed_val + Time.get_ticks_msec() * 0.01 * speed * 0.1, 1400) - 100
		var y = fmod(i * 73.3 + layer * 50.0, 520)
		var size = 1.0 + fmod(i * 1.7, 2.5 if layer == 0 else 1.5)
		var brightness = 0.4 + fmod(i * 0.3, 0.6)
		if layer == 0:
			draw_circle(Vector2(x, y), size, Color(brightness, brightness, brightness + 0.1, brightness))
		else:
			draw_circle(Vector2(x, y), size * 1.2, Color(brightness*0.8, brightness*0.8, 1.0, brightness*0.8))
			if i % 7 == 0:
				draw_circle(Vector2(x, y), size * 0.5, Color(1,1,1,0.9))

func _process(_d):
	queue_redraw()
