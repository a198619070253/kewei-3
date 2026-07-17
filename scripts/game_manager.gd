extends Node

signal gold_changed(gold: int)
signal lives_changed(lives: int)
signal wave_changed(wave: int, total: int)
signal level_changed(level: int, total: int, level_name: String)
signal game_over_signal(victory: bool)
signal tower_selected(type: int)

enum TowerType { BASIC, CANNON, RAPID, SNIPER, FROST, SPLASH, POISON, LIGHTNING, LASER, NONE = -1 }
enum EnemyKind { NORMAL, FAST, TANK, BOSS }

const TOWER_COSTS := {
	TowerType.BASIC: 50,
	TowerType.CANNON: 100,
	TowerType.RAPID: 75,
	TowerType.SNIPER: 120,
	TowerType.FROST: 90,
	TowerType.SPLASH: 110,
	TowerType.POISON: 95,
	TowerType.LIGHTNING: 130,
	TowerType.LASER: 140,
}
const TOWER_NAMES := {
	TowerType.BASIC: "Basic",
	TowerType.CANNON: "Cannon",
	TowerType.RAPID: "Rapid",
	TowerType.SNIPER: "Sniper",
	TowerType.FROST: "Frost",
	TowerType.SPLASH: "Splash",
	TowerType.POISON: "Poison",
	TowerType.LIGHTNING: "Lightning",
	TowerType.LASER: "Laser",
}
const TOWER_DESCRIPTIONS := {
	TowerType.BASIC: "Balanced, good range",
	TowerType.CANNON: "High damage, slow fire rate",
	TowerType.RAPID: "Fast fire rate, low damage",
	TowerType.SNIPER: "Long range, high damage",
	TowerType.FROST: "Attacks slow enemies",
	TowerType.SPLASH: "Splash damage on hit",
	TowerType.POISON: "Poison damage over time",
	TowerType.LIGHTNING: "Chains to nearby enemies",
	TowerType.LASER: "Instant laser beam attack",
}
const ALL_TOWER_TYPES := [
	TowerType.BASIC,
	TowerType.CANNON,
	TowerType.RAPID,
	TowerType.SNIPER,
	TowerType.FROST,
	TowerType.SPLASH,
	TowerType.POISON,
	TowerType.LIGHTNING,
	TowerType.LASER,
]

const WAVES_PER_LEVEL := LevelConfig.WAVES_PER_LEVEL
const TOTAL_LEVELS := LevelConfig.TOTAL_LEVELS
const TOTAL_WAVES := LevelConfig.WAVES_PER_LEVEL * LevelConfig.TOTAL_LEVELS

var gold := 300
var lives := 20
var level := 1
var wave := 0
var selected_tower_type := TowerType.BASIC
var game_running := false
var game_over := false

var path_points: PackedVector2Array = PackedVector2Array()
var enemies_container: Node2D
var projectiles_container: Node2D
var spawn_timer: Timer
var wave_timer: Timer
var main_scene: Node2D

var _enemies_to_spawn := 0
var _spawn_interval := 1.0
var _spawn_health := 40.0
var _spawn_speed := 70.0
var _enemies_alive := 0
var _wave_in_progress := false
var _waiting_next_wave := false
var _is_setup := false
var _spawn_queue: Array[int] = []

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")


func setup(main: Node2D) -> void:
	_is_setup = false
	main_scene = main
	enemies_container = main.get_node("Enemies")
	projectiles_container = main.get_node("Projectiles")
	spawn_timer = main.get_node("SpawnTimer")
	wave_timer = main.get_node("WaveTimer")

	spawn_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	wave_timer.process_mode = Node.PROCESS_MODE_ALWAYS

	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if not wave_timer.timeout.is_connected(_on_wave_timer_timeout):
		wave_timer.timeout.connect(_on_wave_timer_timeout)

	_apply_level(1, true)
	_is_setup = true


func start_game() -> void:
	if not _is_setup:
		push_error("GameManager is not initialized yet. Please try again.")
		return
	gold = 300
	lives = 20
	level = 0
	wave = 0
	game_running = true
	game_over = false
	_enemies_alive = 0
	_wave_in_progress = false
	_waiting_next_wave = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)
	select_tower(TowerType.BASIC)
	_advance_level()


func select_tower(type: int) -> void:
	selected_tower_type = type
	tower_selected.emit(type)


func can_afford(type: int) -> bool:
	return gold >= TOWER_COSTS.get(type, 9999)


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func enemy_killed(reward: int) -> void:
	add_gold(reward)
	_enemies_alive -= 1
	_check_wave_complete()


func enemy_reached_base(damage: int) -> void:
	lives -= damage
	lives_changed.emit(lives)
	_enemies_alive -= 1
	if lives <= 0:
		_end_game(false)
	else:
		_check_wave_complete()


func get_upgrade_cost(level_num: int) -> int:
	return level_num * 45


func get_current_level_name() -> String:
	return LevelConfig.get_level(level - 1).get("name", "Unknown")


func _apply_level(level_index: int, rebuild_map: bool) -> void:
	var data: Dictionary = LevelConfig.get_level(level_index - 1)
	path_points = data["path"]
	if rebuild_map and main_scene:
		main_scene.get_node("Map").apply_level(data)
		if main_scene.has_method("rebuild_build_slots"):
			main_scene.rebuild_build_slots(data["slots"])
	level_changed.emit(level_index, TOTAL_LEVELS, data.get("name", ""))


func _advance_level() -> void:
	if not game_running or game_over:
		return
	if level >= TOTAL_LEVELS:
		_end_game(true)
		return

	level += 1
	wave = 0
	_clear_battlefield()
	_apply_level(level, true)
	if level > 1:
		add_gold(80 + level * 40)
	_start_next_wave()


func _clear_battlefield() -> void:
	for node in enemies_container.get_children():
		node.queue_free()
	for node in projectiles_container.get_children():
		node.queue_free()
	if main_scene:
		var towers := main_scene.get_node("Towers")
		for node in towers.get_children():
			node.queue_free()
		var slots := main_scene.get_node("BuildSlots")
		for node in slots.get_children():
			node.queue_free()
		if main_scene.has_node("Effects"):
			for node in main_scene.get_node("Effects").get_children():
				node.queue_free()
	_enemies_alive = 0
	_enemies_to_spawn = 0
	_spawn_queue.clear()


func _start_next_wave() -> void:
	if not game_running or game_over:
		return
	wave += 1
	if wave > WAVES_PER_LEVEL:
		_waiting_next_wave = true
		_wait_and_advance_level()
		return

	var global_wave := LevelConfig.global_wave_index(level, wave)
	_enemies_to_spawn = 3 + wave + level
	_spawn_interval = maxf(0.28, 1.15 - global_wave * 0.04)
	_spawn_health = 30.0 + global_wave * 16.0
	_spawn_speed = 62.0 + global_wave * 3.5
	_spawn_queue = _build_spawn_queue(global_wave)
	_wave_in_progress = true
	wave_changed.emit(wave, WAVES_PER_LEVEL)
	_on_spawn_timer_timeout()


func _build_spawn_queue(global_wave: int) -> Array[int]:
	var queue: Array[int] = []
	for i in range(_enemies_to_spawn):
		var kind := EnemyKind.NORMAL
		if wave == WAVES_PER_LEVEL and i == _enemies_to_spawn - 1:
			kind = EnemyKind.BOSS
		elif level >= 2 and i % 4 == 1:
			kind = EnemyKind.FAST
		elif level >= 3 and i % 5 == 2:
			kind = EnemyKind.TANK
		elif global_wave >= 8 and i % 6 == 3:
			kind = EnemyKind.FAST
		queue.append(kind)
	return queue


func _on_wave_timer_timeout() -> void:
	spawn_timer.wait_time = _spawn_interval
	spawn_timer.start()
	_on_spawn_timer_timeout()


func _on_spawn_timer_timeout() -> void:
	if not game_running or game_over:
		return
	if _enemies_to_spawn > 0:
		var kind: int = _spawn_queue.pop_front() if not _spawn_queue.is_empty() else EnemyKind.NORMAL
		_spawn_enemy(kind)
		_enemies_to_spawn -= 1
		if _enemies_to_spawn > 0:
			spawn_timer.wait_time = _spawn_interval
			spawn_timer.start()


func _spawn_enemy(kind: int) -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.global_position = path_points[0]
	var global_wave := LevelConfig.global_wave_index(level, wave)
	var hp := _spawn_health
	var spd := _spawn_speed
	var kind_reward := 0
	match kind:
		EnemyKind.FAST:
			hp *= 0.65
			spd *= 1.45
			kind_reward = 2
		EnemyKind.TANK:
			hp *= 2.2
			spd *= 0.72
			kind_reward = 6
		EnemyKind.BOSS:
			hp *= 4.5
			spd *= 0.85
			kind_reward = 25
	enemy.setup(path_points, hp, spd, global_wave, kind, kind_reward)
	enemies_container.add_child(enemy)
	_enemies_alive += 1


func _check_wave_complete() -> void:
	if not _wave_in_progress or _waiting_next_wave:
		return
	if _enemies_to_spawn <= 0 and _enemies_alive <= 0:
		_wave_in_progress = false
		_waiting_next_wave = true
		add_gold(25 + wave * 8 + level * 12)
		_wait_and_start_next_wave()


func _wait_and_start_next_wave() -> void:
	await get_tree().create_timer(2.5).timeout
	_waiting_next_wave = false
	if game_running and not game_over:
		_start_next_wave()


func _wait_and_advance_level() -> void:
	await get_tree().create_timer(3.0).timeout
	_waiting_next_wave = false
	_wave_in_progress = false
	if game_running and not game_over:
		_advance_level()


func _end_game(victory: bool) -> void:
	game_running = false
	game_over = true
	spawn_timer.stop()
	wave_timer.stop()
	game_over_signal.emit(victory)


func restart_game() -> void:
	get_tree().reload_current_scene()
