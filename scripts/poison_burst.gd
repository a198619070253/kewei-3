extends Node2D

var _life := 0.5
var _max_life := 0.5


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
	for i in range(8):
		var angle := float(i) / 8.0 * TAU
		var dist := (1.0 - alpha) * 18.0 + 4.0
		var offset: Vector2 = Vector2.from_angle(angle) * dist
		draw_circle(offset, 3.0 * alpha, Color(0.35, 0.95, 0.25, alpha * 0.8))
	draw_circle(Vector2.ZERO, 7.0 * alpha, Color(0.2, 0.8, 0.15, alpha * 0.45))
