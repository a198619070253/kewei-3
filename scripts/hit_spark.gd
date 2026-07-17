extends Node2D

var _life := 0.2
var _color := Color.WHITE


func setup(pos: Vector2, color: Color) -> void:
	global_position = pos
	_color = color
	queue_redraw()


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var alpha := clampf(_life / 0.2, 0.0, 1.0)
	var size := (1.0 - alpha) * 10.0 + 4.0
	draw_circle(Vector2.ZERO, size, Color(_color.r, _color.g, _color.b, alpha))
