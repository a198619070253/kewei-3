extends Node2D

var _life := 0.55
var _max_life := 0.55


func setup(pos: Vector2) -> void:
	global_position = pos
	queue_redraw()


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var alpha := clampf(_life / _max_life, 0.0, 1.0)
	var ring_r := (1.0 - alpha) * 22.0 + 6.0
	draw_arc(Vector2.ZERO, ring_r, 0, TAU, 20, Color(1.0, 0.45, 0.1, alpha * 0.7), 2.5)
	for i in range(10):
		var angle := float(i) / 10.0 * TAU
		var dist := (1.0 - alpha) * 16.0 + 3.0
		var offset: Vector2 = Vector2.from_angle(angle) * dist
		draw_circle(offset, 2.5 * alpha, Color(1.0, 0.65, 0.15, alpha * 0.85))
