extends Node2D

enum EnemyKind { NORMAL, FAST, TANK, BOSS }

var path_points: PackedVector2Array = PackedVector2Array()
var path_index := 0
var path_progress := 0.0
var speed := 70.0
var health := 40.0
var max_health := 40.0
var reward := 10
var reached_end := false
var enemy_kind := EnemyKind.NORMAL
var _total_length := 0.0
var _slow_multiplier := 1.0
var _slow_timer := 0.0
var _poison_dps := 0.0
var _poison_timer := 0.0
var _poison_pulse := 0.0
var _base_damage := 1
var _frost_pulse := 0.0


func setup(
	points: PackedVector2Array,
	hp: float,
	move_speed: float,
	wave: int,
	kind: int = EnemyKind.NORMAL,
	kind_reward: int = 0
) -> void:
	path_points = points
	path_index = 0
	global_position = points[0]
	health = hp
	max_health = hp
	speed = move_speed
	enemy_kind = kind
	reward = 8 + wave * 3 + kind_reward
	reached_end = false
	_base_damage = 1 if kind != EnemyKind.BOSS else 2
	_slow_multiplier = 1.0
	_slow_timer = 0.0
	_poison_dps = 0.0
	_poison_timer = 0.0
	_poison_pulse = 0.0
	add_to_group("enemies")
	_calc_total_length()
	queue_redraw()


func _calc_total_length() -> void:
	_total_length = 0.0
	for i in range(path_points.size() - 1):
		_total_length += path_points[i].distance_to(path_points[i + 1])


func is_slowed() -> bool:
	return _slow_timer > 0.0


func is_poisoned() -> bool:
	return _poison_timer > 0.0


func apply_slow(factor: float, duration: float) -> void:
	var was_slowed := is_slowed()
	_slow_multiplier = minf(_slow_multiplier, factor)
	_slow_timer = maxf(_slow_timer, duration)
	modulate = _get_status_modulate()
	if not was_slowed:
		VFX.spawn_frost_burst(global_position)


func apply_poison(dps: float, duration: float) -> void:
	_poison_dps = maxf(_poison_dps, dps)
	_poison_timer = maxf(_poison_timer, duration)
	modulate = _get_status_modulate()
	VFX.spawn_poison_burst(global_position)


func _get_slow_modulate() -> Color:
	return Color(0.62, 0.82, 1.12)


func _get_poison_modulate() -> Color:
	return Color(0.62, 1.08, 0.52)


func _get_status_modulate() -> Color:
	if is_slowed() and is_poisoned():
		return Color(0.55, 0.92, 0.78)
	if is_slowed():
		return _get_slow_modulate()
	if is_poisoned():
		return _get_poison_modulate()
	return Color.WHITE


func _process(delta: float) -> void:
	if reached_end or path_points.is_empty():
		return
	if path_index >= path_points.size() - 1:
		_reach_base()
		return

	if _slow_timer > 0.0:
		_slow_timer -= delta
		_frost_pulse += delta * 6.0
		if _slow_timer <= 0.0:
			_slow_multiplier = 1.0
			_frost_pulse = 0.0

	if _poison_timer > 0.0:
		_poison_timer -= delta
		_poison_pulse += delta * 5.0
		health -= _poison_dps * delta
		if health <= 0.0:
			VFX.spawn_poison_burst(global_position)
			if is_slowed():
				VFX.spawn_frost_burst(global_position)
			GameManager.enemy_killed(reward)
			queue_free()
			return
		if _poison_timer <= 0.0:
			_poison_dps = 0.0
			_poison_pulse = 0.0

	modulate = _get_status_modulate()

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
	tween.tween_property(self, "modulate", _get_status_modulate(), 0.1)
	if health <= 0.0:
		if is_slowed():
			VFX.spawn_frost_burst(global_position)
		if is_poisoned():
			VFX.spawn_poison_burst(global_position)
		GameManager.enemy_killed(reward)
		queue_free()


func _reach_base() -> void:
	if reached_end:
		return
	reached_end = true
	GameManager.enemy_reached_base(_base_damage)
	queue_free()


func _get_radius() -> float:
	match enemy_kind:
		EnemyKind.FAST:
			return 11.0
		EnemyKind.TANK:
			return 20.0
		EnemyKind.BOSS:
			return 24.0
		_:
			return 16.0


func _draw_frost_overlay(radius: float) -> void:
	var pulse := 0.5 + sin(_frost_pulse) * 0.15
	var ring_r := radius + 8.0 + sin(_frost_pulse * 1.3) * 2.0
	draw_arc(Vector2.ZERO, ring_r, 0, TAU, 24, Color(0.45, 0.82, 1.0, 0.55 * pulse), 2.0)
	for i in range(6):
		var angle := _frost_pulse + float(i) / 6.0 * TAU
		var dist := radius + 4.0
		var shard := Vector2.from_angle(angle) * dist
		var tip := shard + Vector2.from_angle(angle) * 5.0
		draw_line(shard, tip, Color(0.75, 0.95, 1.0, 0.8), 2.0)
	draw_circle(Vector2.ZERO, radius + 3.0, Color(0.55, 0.85, 1.0, 0.12))


func _draw_poison_overlay(radius: float) -> void:
	var pulse := 0.5 + sin(_poison_pulse) * 0.18
	for i in range(5):
		var angle := _poison_pulse * 1.2 + float(i) / 5.0 * TAU
		var bubble := Vector2.from_angle(angle) * (radius + 6.0 + sin(_poison_pulse + i) * 2.0)
		draw_circle(bubble, 3.0 + pulse, Color(0.35, 0.95, 0.2, 0.65 * pulse))
	draw_arc(Vector2.ZERO, radius + 6.0, 0, TAU, 20, Color(0.3, 0.9, 0.15, 0.35 * pulse), 2.0)


func _draw() -> void:
	var radius := _get_radius()
	var body_color := Color(0.75, 0.2, 0.2)
	var inner_color := Color(0.9, 0.35, 0.35)
	match enemy_kind:
		EnemyKind.FAST:
			body_color = Color(0.85, 0.45, 0.15)
			inner_color = Color(1.0, 0.6, 0.25)
		EnemyKind.TANK:
			body_color = Color(0.45, 0.15, 0.15)
			inner_color = Color(0.65, 0.25, 0.25)
		EnemyKind.BOSS:
			body_color = Color(0.55, 0.1, 0.55)
			inner_color = Color(0.85, 0.2, 0.85)

	if is_slowed():
		body_color = body_color.lerp(Color(0.45, 0.75, 0.95), 0.45)
		inner_color = inner_color.lerp(Color(0.65, 0.9, 1.0), 0.45)
		_draw_frost_overlay(radius)
	if is_poisoned():
		body_color = body_color.lerp(Color(0.35, 0.85, 0.25), 0.4)
		inner_color = inner_color.lerp(Color(0.5, 0.95, 0.35), 0.4)
		_draw_poison_overlay(radius)

	draw_circle(Vector2.ZERO, radius, body_color)
	draw_circle(Vector2.ZERO, radius * 0.75, inner_color)
	if enemy_kind == EnemyKind.BOSS:
		draw_line(Vector2(-radius * 0.5, 0), Vector2(radius * 0.5, 0), Color(1, 0.85, 0.3), 3.0)
	else:
		draw_line(Vector2(-6, -4), Vector2(6, -4), Color(0.5, 0.1, 0.1), 2.0)
		draw_line(Vector2(-6, 4), Vector2(6, 4), Color(0.5, 0.1, 0.1), 2.0)

	var bar_w := radius * 1.5
	var ratio := health / max_health
	draw_rect(Rect2(-bar_w * 0.5, -radius - 8.0, bar_w, 4.0), Color(0.2, 0.2, 0.2, 0.7))
	draw_rect(Rect2(-bar_w * 0.5, -radius - 8.0, bar_w * ratio, 4.0), Color(0.3, 0.9, 0.3))
