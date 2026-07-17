extends Node2D

var _life := 0.35
var _max_life := 0.35
var _from := Vector2.ZERO
var _to := Vector2.ZERO


func setup(from_pos: Vector2, to_pos: Vector2) -> void:
	_from = from_pos
	_to = to_pos
	global_position = Vector2.ZERO
	queue_redraw()


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var alpha := clampf(_life / _max_life, 0.0, 1.0)
	var mid := (_from + _to) * 0.5
	for i in range(3):
		var offset := Vector2(0, float(i - 1) * 3.0)
		draw_line(_from + offset, _to + offset, Color(0.55, 0.75, 1.0, alpha * 0.35), 6.0)
	draw_line(_from, _to, Color(0.85, 0.95, 1.0, alpha), 2.0)
	draw_circle(mid, 5.0 * alpha, Color(1.0, 1.0, 0.8, alpha * 0.6))
