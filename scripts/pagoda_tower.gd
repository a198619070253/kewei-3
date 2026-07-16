extends Node2D

enum TowerKind { BASIC, CANNON, RAPID, SNIPER, FROST, SPLASH }

@export var tower_kind: TowerKind = TowerKind.BASIC

var level := 1
var max_level := 5

var _damage := 15.0
var _range := 130.0
var _fire_rate := 0.9
var _cooldown := 0.0
var _splash_radius := 0.0
var _slow_factor := 1.0
var _slow_duration := 0.0
var _projectile_scene := preload("res://scenes/projectile.tscn")


func _ready() -> void:
	_apply_kind_stats()
	queue_redraw()


func _process(delta: float) -> void:
	if not GameManager.game_running or GameManager.game_over:
		return
	_cooldown = maxf(_cooldown - delta, 0.0)
	var target := _find_target()
	if target and _cooldown <= 0.0:
		_shoot(target)
		_cooldown = _fire_rate
	queue_redraw()


func setup(kind: TowerKind) -> void:
	tower_kind = kind
	level = 1
	_apply_kind_stats()
	queue_redraw()


func upgrade() -> bool:
	if level >= max_level:
		return false
	var cost := GameManager.get_upgrade_cost(level)
	if not GameManager.spend_gold(cost):
		return false
	level += 1
	_damage *= 1.35
	_range += 12.0
	_fire_rate = maxf(_fire_rate * 0.88, 0.15)
	if _splash_radius > 0.0:
		_splash_radius += 6.0
	queue_redraw()
	return true


func get_upgrade_cost() -> int:
	if level >= max_level:
		return -1
	return GameManager.get_upgrade_cost(level)


func _apply_kind_stats() -> void:
	_splash_radius = 0.0
	_slow_factor = 1.0
	_slow_duration = 0.0
	match tower_kind:
		TowerKind.BASIC:
			_damage = 18.0
			_range = 135.0
			_fire_rate = 0.85
		TowerKind.CANNON:
			_damage = 45.0
			_range = 115.0
			_fire_rate = 1.6
		TowerKind.RAPID:
			_damage = 8.0
			_range = 120.0
			_fire_rate = 0.25
		TowerKind.SNIPER:
			_damage = 58.0
			_range = 195.0
			_fire_rate = 2.0
		TowerKind.FROST:
			_damage = 14.0
			_range = 128.0
			_fire_rate = 0.95
			_slow_factor = 0.55
			_slow_duration = 1.8
		TowerKind.SPLASH:
			_damage = 28.0
			_range = 105.0
			_fire_rate = 1.35
			_splash_radius = 48.0


func _find_target() -> Node2D:
	var best: Node2D = null
	var best_progress := -1.0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var dist := global_position.distance_to(enemy.global_position)
		if dist > _range:
			continue
		if enemy.path_progress > best_progress:
			best_progress = enemy.path_progress
			best = enemy
	return best


func _shoot(target: Node2D) -> void:
	var proj := _projectile_scene.instantiate()
	proj.global_position = global_position + Vector2(0, -level * 14.0 - 10.0)
	proj.setup(
		target,
		_damage,
		tower_kind,
		_splash_radius,
		_slow_factor,
		_slow_duration
	)
	get_tree().current_scene.get_node("Projectiles").add_child(proj)


func _draw() -> void:
	var colors := [
		Color(0.7, 0.35, 0.15),
		Color(0.55, 0.25, 0.55),
		Color(0.2, 0.55, 0.65),
		Color(0.25, 0.35, 0.75),
		Color(0.45, 0.75, 0.95),
		Color(0.85, 0.45, 0.15),
	]
	_draw_pagoda(level, colors[tower_kind])
	draw_arc(Vector2.ZERO, _range, 0, TAU, 64, Color(1, 1, 1, 0.06), 1.0)


func _draw_pagoda(levels: int, color: Color) -> void:
	for i in range(levels):
		var floor_y := -float(i) * 16.0
		var shrink := float(i) * 2.0
		var hw := 16.0 - shrink
		var body_color := color.lerp(Color(0.95, 0.75, 0.25), float(i) / float(levels))
		draw_rect(Rect2(-hw, floor_y - 14.0, hw * 2.0, 14.0), body_color)
		draw_rect(Rect2(-hw, floor_y - 14.0, hw * 2.0, 14.0), Color(0.2, 0.1, 0.05, 0.4), false, 1.0)
		var roof_w := hw + 5.0
		var roof := PackedVector2Array([
			Vector2(-roof_w, floor_y - 14.0),
			Vector2(roof_w, floor_y - 14.0),
			Vector2(0, floor_y - 24.0),
		])
		draw_colored_polygon(roof, body_color.darkened(0.3))

	if level < max_level:
		draw_string(ThemeDB.fallback_font, Vector2(-20, 24), "Lv.%d" % level, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(1, 0.95, 0.7))
