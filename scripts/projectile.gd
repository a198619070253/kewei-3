extends Node2D

var _target: Node2D
var _damage := 10.0
var _speed := 400.0
var _tower_kind := 0
var _splash_radius := 0.0
var _slow_factor := 1.0
var _slow_duration := 0.0


func setup(
	target: Node2D,
	damage: float,
	tower_kind: int = 0,
	splash_radius: float = 0.0,
	slow_factor: float = 1.0,
	slow_duration: float = 0.0
) -> void:
	_target = target
	_damage = damage
	_tower_kind = tower_kind
	_splash_radius = splash_radius
	_slow_factor = slow_factor
	_slow_duration = slow_duration
	match tower_kind:
		1: # CANNON
			_speed = 320.0
		3: # SNIPER
			_speed = 620.0
		4: # FROST
			_speed = 440.0
		5: # SPLASH
			_speed = 360.0
		_:
			_speed = 480.0
	queue_redraw()


func _process(delta: float) -> void:
	if not is_instance_valid(_target):
		queue_free()
		return
	var dir := (_target.global_position - global_position).normalized()
	global_position += dir * _speed * delta
	rotation = dir.angle()
	if global_position.distance_to(_target.global_position) < 14.0:
		_apply_hit(_target)
		queue_free()


func _apply_hit(primary: Node2D) -> void:
	if _splash_radius > 0.0:
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy):
				continue
			if global_position.distance_to(enemy.global_position) <= _splash_radius:
				_damage_enemy(enemy)
	else:
		_damage_enemy(primary)


func _damage_enemy(enemy: Node2D) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(_damage)
	if _slow_duration > 0.0 and enemy.has_method("apply_slow"):
		enemy.apply_slow(_slow_factor, _slow_duration)


func _draw() -> void:
	var color := Color(1.0, 0.9, 0.3)
	var radius := 4.0
	match _tower_kind:
		1: # CANNON
			color = Color(1.0, 0.6, 0.1)
			radius = 6.0
		3: # SNIPER
			color = Color(0.7, 0.85, 1.0)
			radius = 3.0
			draw_line(Vector2(-8, 0), Vector2(8, 0), color, 2.0)
			return
		4: # FROST
			color = Color(0.6, 0.9, 1.0)
			radius = 5.0
		5: # SPLASH
			color = Color(1.0, 0.5, 0.15)
			radius = 7.0
	draw_circle(Vector2.ZERO, radius, color)
