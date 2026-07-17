extends Node2D

var _life := 0.45
var _max_life := 0.45
var _radius := 20.0


func setup(pos: Vector2, radius: float) -> void:
	global_position = pos
	_radius = radius
	queue_redraw()


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := 1.0 - (_life / _max_life)
	var alpha := clampf(_life / _max_life, 0.0, 1.0)
	var current_r := lerpf(_radius * 0.3, _radius, t)
	draw_arc(Vector2.ZERO, current_r, 0, TAU, 32, Color(1.0, 0.55, 0.15, alpha * 0.75), 3.0)
	draw_circle(Vector2.ZERO, current_r * 0.35, Color(1.0, 0.75, 0.2, alpha * 0.35))
