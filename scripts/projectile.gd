extends Node2D

var _target: Node2D
var _damage := 10.0
var _speed := 400.0
var _tower_kind := 0
var _splash_radius := 0.0
var _slow_factor := 1.0
var _slow_duration := 0.0
var _poison_dps := 0.0
var _poison_duration := 0.0
var _chain_count := 0
var _trail_timer := 0.0
var _hit_pos := Vector2.ZERO


func setup(
	target: Node2D,
	damage: float,
	tower_kind: int = 0,
	splash_radius: float = 0.0,
	slow_factor: float = 1.0,
	slow_duration: float = 0.0,
	poison_dps: float = 0.0,
	poison_duration: float = 0.0,
	chain_count: int = 0
) -> void:
	_target = target
	_damage = damage
	_tower_kind = tower_kind
	_splash_radius = splash_radius
	_slow_factor = slow_factor
	_slow_duration = slow_duration
	_poison_dps = poison_dps
	_poison_duration = poison_duration
	_chain_count = chain_count
	match tower_kind:
		1: # CANNON
			_speed = 320.0
		3: # SNIPER
			_speed = 620.0
		4: # FROST
			_speed = 440.0
		5: # SPLASH
			_speed = 360.0
		6: # POISON
			_speed = 400.0
		7: # LIGHTNING
			_speed = 680.0
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

	if _tower_kind == 4:
		_trail_timer += delta
		if _trail_timer >= 0.04:
			_trail_timer = 0.0
			VFX.spawn_hit_spark(global_position, Color(0.55, 0.85, 1.0, 0.45))
	elif _tower_kind == 6:
		_trail_timer += delta
		if _trail_timer >= 0.06:
			_trail_timer = 0.0
			VFX.spawn_hit_spark(global_position, Color(0.35, 0.9, 0.25, 0.5))
	elif _tower_kind == 7:
		_trail_timer += delta
		if _trail_timer >= 0.03:
			_trail_timer = 0.0
			VFX.spawn_hit_spark(global_position, Color(0.6, 0.9, 1.0, 0.55))

	if global_position.distance_to(_target.global_position) < 14.0:
		_hit_pos = _target.global_position
		_apply_hit(_target)
		queue_free()


func _apply_hit(primary: Node2D) -> void:
	if _splash_radius > 0.0:
		VFX.spawn_explosion(global_position, _splash_radius)
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy):
				continue
			if global_position.distance_to(enemy.global_position) <= _splash_radius:
				_damage_enemy(enemy, false)
	else:
		_damage_enemy(primary, true)
		if _chain_count > 0:
			_chain_lightning(primary)


func _chain_lightning(origin_enemy: Node2D) -> void:
	var hit: Array[Node2D] = [origin_enemy]
	var current := origin_enemy
	var remaining := _chain_count - 1
	var chain_damage := _damage * 0.75

	while remaining > 0:
		var next: Node2D = null
		var best_dist := 99999.0
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if not is_instance_valid(enemy) or hit.has(enemy):
				continue
			var dist := current.global_position.distance_to(enemy.global_position)
			if dist <= 90.0 and dist < best_dist:
				best_dist = dist
				next = enemy
		if next == null:
			break
		VFX.spawn_lightning_arc(current.global_position, next.global_position)
		if next.has_method("take_damage"):
			next.take_damage(chain_damage)
		VFX.spawn_hit_spark(next.global_position, Color(0.7, 0.9, 1.0))
		hit.append(next)
		current = next
		remaining -= 1


func _damage_enemy(enemy: Node2D, spawn_fx: bool) -> void:
	if enemy.has_method("take_damage"):
		enemy.take_damage(_damage)
	if _slow_duration > 0.0 and enemy.has_method("apply_slow"):
		enemy.apply_slow(_slow_factor, _slow_duration)
	if _poison_duration > 0.0 and enemy.has_method("apply_poison"):
		enemy.apply_poison(_poison_dps, _poison_duration)
	if spawn_fx:
		_spawn_hit_fx()


func _spawn_hit_fx() -> void:
	match _tower_kind:
		4: # FROST
			VFX.spawn_frost_burst(_hit_pos)
		6: # POISON
			VFX.spawn_poison_burst(_hit_pos)
		7: # LIGHTNING
			VFX.spawn_lightning_arc(global_position, _hit_pos)
			VFX.spawn_hit_spark(_hit_pos, Color(0.75, 0.95, 1.0))
		1: # CANNON
			VFX.spawn_hit_spark(_hit_pos, Color(1.0, 0.55, 0.1))
		3: # SNIPER
			VFX.spawn_hit_spark(_hit_pos, Color(0.7, 0.85, 1.0))
		_:
			VFX.spawn_hit_spark(_hit_pos, Color(1.0, 0.9, 0.3))


func _draw() -> void:
	var color := Color(1.0, 0.9, 0.3)
	var radius := 4.0
	match _tower_kind:
		1: # CANNON
			color = Color(1.0, 0.6, 0.1)
			radius = 6.0
		3: # SNIPER
			color = Color(0.7, 0.85, 1.0)
			draw_line(Vector2(-8, 0), Vector2(8, 0), color, 2.0)
			return
		4: # FROST
			color = Color(0.6, 0.9, 1.0)
			radius = 5.0
			draw_circle(Vector2.ZERO, radius + 2.0, Color(0.5, 0.85, 1.0, 0.35))
		5: # SPLASH
			color = Color(1.0, 0.5, 0.15)
			radius = 7.0
		6: # POISON
			color = Color(0.4, 0.95, 0.25)
			radius = 5.0
			draw_circle(Vector2.ZERO, radius + 2.0, Color(0.25, 0.85, 0.15, 0.35))
		7: # LIGHTNING
			color = Color(0.75, 0.95, 1.0)
			radius = 4.0
			draw_line(Vector2(-6, -3), Vector2(6, 3), color, 2.0)
			return
	draw_circle(Vector2.ZERO, radius, color)
