extends Node2D
func _draw():
	for i in range(50):
		var x = fmod(i * 137.5 + Time.get_ticks_msec() * 0.001 * 10.0, 1200)
		var y = fmod(i * 73.3, 500)
		draw_circle(Vector2(x, y), 1.0, Color(1,1,1,0.5))
func _process(_d): queue_redraw()
