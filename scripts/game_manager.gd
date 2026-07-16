extends Node

signal gold_changed(gold: int)
signal lives_changed(lives: int)
signal wave_changed(wave: int, total: int)
signal game_over_signal(victory: bool)
signal tower_selected(type: int)

enum TowerType { BASIC, CANNON, RAPID, SNIPER, FROST, SPLASH, NONE = -1 }

const TOWER_COSTS := {
	TowerType.BASIC: 50,
	TowerType.CANNON: 100,
	TowerType.RAPID: 75,
	TowerType.SNIPER: 120,
	TowerType.FROST: 90,
	TowerType.SPLASH: 110,
}
const TOWER_NAMES := {
	TowerType.BASIC: "Basic",
	TowerType.CANNON: "Cannon",
	TowerType.RAPID: "Rapid",
	TowerType.SNIPER: "Sniper",
	TowerType.FROST: "Frost",
	TowerType.SPLASH: "Splash",
}
const TOWER_DESCRIPTIONS := {
	TowerType.BASIC: "Balanced, good range",
	TowerType.CANNON: "High damage, slow fire rate",
	TowerType.RAPID: "Fast fire rate, low damage",
	TowerType.SNIPER: "Long range, high damage",
	TowerType.FROST: "Attacks slow enemies",
	TowerType.SPLASH: "Splash damage on hit",
}

const TOTAL_WAVES := 10

var gold := 300
var lives := 20
var wave := 0
var selected_tower_type := TowerType.BASIC
var game_running := false
var game_over := false

var path_points: PackedVector2Array = PackedVector2Array()
var enemies_container: Node2D
var projectiles_container: Node2D
var spawn_timer: Timer
var wave_timer: Timer

var _enemies_to_spawn := 0
var _spawn_interval := 1.0
var _spawn_health := 40.0
var _spawn_speed := 70.0
var _enemies_alive := 0
var _wave_in_progress := false
var _waiting_next_wave := false
var _is_setup := false

const ENEMY_SCENE := preload("res://scenes/enemy.tscn")


func setup(main: Node2D) -> void:
	_is_setup = false
	enemies_container = main.get_node("Enemies")
	projectiles_container = main.get_node("Projectiles")
	spawn_timer = main.get_node("SpawnTimer")
	wave_timer = main.get_node("WaveTimer")
	path_points = main.get_node("Map").path_points

	spawn_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	wave_timer.process_mode = Node.PROCESS_MODE_ALWAYS

	if not spawn_timer.timeout.is_connected(_on_spawn_timer_timeout):
		spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	if not wave_timer.timeout.is_connected(_on_wave_timer_timeout):
		wave_timer.timeout.connect(_on_wave_timer_timeout)

	_is_setup = true


func start_game() -> void:
	if not _is_setup:
		push_error("GameManager is not initialized yet. Please try again.")
		return
	gold = 300
	lives = 20
	wave = 0
	game_running = true
	game_over = false
	_enemies_alive = 0
	_wave_in_progress = false
	_waiting_next_wave = false
	gold_changed.emit(gold)
	lives_changed.emit(lives)
	select_tower(TowerType.BASIC)
	_start_next_wave()


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


func get_upgrade_cost(level: int) -> int:
	return level * 45


func _start_next_wave() -> void:
	if not game_running or game_over:
		return
	wave += 1
	if wave > TOTAL_WAVES:
		_end_game(true)
		return

	_enemies_to_spawn = 4 + wave * 2
	_spawn_interval = maxf(0.35, 1.2 - wave * 0.07)
	_spawn_health = 35.0 + wave * 18.0
	_spawn_speed = 65.0 + wave * 4.0
	_wave_in_progress = true
	wave_changed.emit(wave, TOTAL_WAVES)
	# Spawn the first enemy immediately so players know the game started.
	_on_spawn_timer_timeout()


func _on_wave_timer_timeout() -> void:
	spawn_timer.wait_time = _spawn_interval
	spawn_timer.start()
	_on_spawn_timer_timeout()


func _on_spawn_timer_timeout() -> void:
	if not game_running or game_over:
		return
	if _enemies_to_spawn > 0:
		_spawn_enemy()
		_enemies_to_spawn -= 1
		if _enemies_to_spawn > 0:
			spawn_timer.wait_time = _spawn_interval
			spawn_timer.start()


func _spawn_enemy() -> void:
	var enemy := ENEMY_SCENE.instantiate()
	enemy.global_position = path_points[0]
	enemy.setup(path_points, _spawn_health, _spawn_speed, wave)
	enemies_container.add_child(enemy)
	_enemies_alive += 1


func _check_wave_complete() -> void:
	if not _wave_in_progress or _waiting_next_wave:
		return
	if _enemies_to_spawn <= 0 and _enemies_alive <= 0:
		_wave_in_progress = false
		_waiting_next_wave = true
		add_gold(30 + wave * 10)
		_wait_and_start_next_wave()


func _wait_and_start_next_wave() -> void:
	await get_tree().create_timer(2.5).timeout
	_waiting_next_wave = false
	if game_running and not game_over:
		_start_next_wave()


func _end_game(victory: bool) -> void:
	game_running = false
	game_over = true
	spawn_timer.stop()
	wave_timer.stop()
	game_over_signal.emit(victory)


func restart_game() -> void:
	get_tree().reload_current_scene()
