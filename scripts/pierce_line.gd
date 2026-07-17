extends Node2D

var _life := 0.2
var _max_life := 0.2
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
	draw_line(_from, _to, Color(1.0, 0.85, 0.35, alpha * 0.45), 8.0)
	draw_line(_from, _to, Color(1.0, 0.95, 0.6, alpha), 2.5)
