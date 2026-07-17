extends Node2D

var _life := 0.25
var _max_life := 0.25
var _from := Vector2.ZERO
var _to := Vector2.ZERO
var _points: PackedVector2Array = PackedVector2Array()


func setup(from_pos: Vector2, to_pos: Vector2) -> void:
	_from = from_pos
	_to = to_pos
	global_position = Vector2.ZERO
	_build_points()
	queue_redraw()


func _build_points() -> void:
	_points.clear()
	var segments := 5
	for i in range(segments + 1):
		var t := float(i) / float(segments)
		var p := _from.lerp(_to, t)
		if i > 0 and i < segments:
			var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
			p += offset
		_points.append(p)


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	if _points.size() < 2:
		return
	var alpha := clampf(_life / _max_life, 0.0, 1.0)
	for i in range(_points.size() - 1):
		draw_line(_points[i], _points[i + 1], Color(0.85, 0.95, 1.0, alpha), 3.0)
		draw_line(_points[i], _points[i + 1], Color(0.45, 0.75, 1.0, alpha * 0.6), 6.0)
