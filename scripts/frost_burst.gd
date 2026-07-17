extends Node2D

var _life := 0.55
var _max_life := 0.55
var _particles: Array[Dictionary] = []


func setup(pos: Vector2) -> void:
	global_position = pos
	for i in range(10):
		var angle := float(i) / 10.0 * TAU + randf_range(-0.2, 0.2)
		_particles.append({
			"angle": angle,
			"speed": randf_range(40.0, 90.0),
			"dist": 0.0,
			"size": randf_range(2.0, 4.0),
		})
	queue_redraw()


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return
	for p in _particles:
		p["dist"] += p["speed"] * delta
	queue_redraw()


func _draw() -> void:
	var alpha := clampf(_life / _max_life, 0.0, 1.0)
	var ring_r := (1.0 - alpha) * 28.0 + 8.0
	draw_arc(Vector2.ZERO, ring_r, 0, TAU, 24, Color(0.55, 0.9, 1.0, alpha * 0.7), 2.5)
	draw_circle(Vector2.ZERO, 6.0 * alpha, Color(0.8, 0.95, 1.0, alpha * 0.5))
	for p in _particles:
		var offset: Vector2 = Vector2.from_angle(p["angle"]) * p["dist"]
		draw_circle(offset, p["size"] * alpha, Color(0.7, 0.92, 1.0, alpha * 0.85))
