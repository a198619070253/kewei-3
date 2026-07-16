extends Node2D

var path_points: PackedVector2Array = PackedVector2Array()
var path_index := 0
var path_progress := 0.0
var speed := 70.0
var health := 40.0
var max_health := 40.0
var reward := 10
var reached_end := false
var _total_length := 0.0
var _slow_multiplier := 1.0
var _slow_timer := 0.0


func setup(points: PackedVector2Array, hp: float, move_speed: float, wave: int) -> void:
	path_points = points
	path_index = 0
	global_position = points[0]
	health = hp
	max_health = hp
	speed = move_speed
	reward = 8 + wave * 3
	reached_end = false
	add_to_group("enemies")
	_calc_total_length()
	queue_redraw()


func _calc_total_length() -> void:
	_total_length = 0.0
	for i in range(path_points.size() - 1):
		_total_length += path_points[i].distance_to(path_points[i + 1])


func apply_slow(factor: float, duration: float) -> void:
	_slow_multiplier = minf(_slow_multiplier, factor)
	_slow_timer = maxf(_slow_timer, duration)
	modulate = Color(0.7, 0.9, 1.2)


func _process(delta: float) -> void:
	if reached_end or path_points.is_empty():
		return
	if path_index >= path_points.size() - 1:
		_reach_base()
		return

	if _slow_timer > 0.0:
		_slow_timer -= delta
		if _slow_timer <= 0.0:
			_slow_multiplier = 1.0
			modulate = Color.WHITE

	var target := path_points[path_index + 1]
	var dir := (target - global_position).normalized()
	var step := speed * _slow_multiplier * delta
	global_position += dir * step
	_update_progress()

	if global_position.distance_to(target) <= step + 2.0:
		global_position = target
		path_index += 1
		if path_index >= path_points.size() - 1:
			_reach_base()

	queue_redraw()


func _update_progress() -> void:
	var traveled := 0.0
	for i in range(path_index):
		traveled += path_points[i].distance_to(path_points[i + 1])
	if path_index < path_points.size() - 1:
		traveled += path_points[path_index].distance_to(global_position)
	path_progress = traveled / maxf(_total_length, 1.0)


func take_damage(amount: float) -> void:
	health -= amount
	modulate = Color(1.8, 0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.08)
	if health <= 0.0:
		GameManager.enemy_killed(reward)
		queue_free()


func _reach_base() -> void:
	if reached_end:
		return
	reached_end = true
	GameManager.enemy_reached_base(1)
	queue_free()


func _draw() -> void:
	var body_color := Color(0.75, 0.2, 0.2)
	draw_circle(Vector2.ZERO, 16.0, body_color)
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.35, 0.35))
	draw_line(Vector2(-6, -4), Vector2(6, -4), Color(0.5, 0.1, 0.1), 2.0)
	draw_line(Vector2(-6, 4), Vector2(6, 4), Color(0.5, 0.1, 0.1), 2.0)

	var bar_w := 24.0
	var ratio := health / max_health
	draw_rect(Rect2(-bar_w * 0.5, -22.0, bar_w, 4.0), Color(0.2, 0.2, 0.2, 0.7))
	draw_rect(Rect2(-bar_w * 0.5, -22.0, bar_w * ratio, 4.0), Color(0.3, 0.9, 0.3))
