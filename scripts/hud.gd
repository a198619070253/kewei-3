extends CanvasLayer

@onready var gold_label: Label = $TopBar/Margin/HBox/GoldLabel
@onready var lives_label: Label = $TopBar/Margin/HBox/LivesLabel
@onready var wave_label: Label = $TopBar/Margin/HBox/WaveLabel
@onready var level_label: Label = $TopBar/Margin/HBox/LevelLabel
@onready var tower_grid: GridContainer = $BottomBar/Margin/VBox/TowerGrid
@onready var start_panel: Control = $StartPanel
@onready var start_button: Button = $StartPanel/Dialog/VBox/StartButton
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var result_label: Label = $GameOverPanel/VBox/ResultLabel
@onready var restart_button: Button = $GameOverPanel/VBox/RestartButton
@onready var hint_label: Label = $BottomBar/Margin/VBox/HintLabel
@onready var wave_toast: Label = $WaveToast

var _game_started := false
var _tower_buttons: Dictionary = {}

const TOWER_BUTTON_COLORS := {
	GameManager.TowerType.BASIC: Color(0.85, 0.45, 0.2),
	GameManager.TowerType.CANNON: Color(0.65, 0.35, 0.65),
	GameManager.TowerType.RAPID: Color(0.25, 0.65, 0.75),
	GameManager.TowerType.SNIPER: Color(0.35, 0.45, 0.85),
	GameManager.TowerType.FROST: Color(0.5, 0.8, 0.95),
	GameManager.TowerType.SPLASH: Color(0.9, 0.5, 0.15),
	GameManager.TowerType.POISON: Color(0.4, 0.9, 0.25),
	GameManager.TowerType.LIGHTNING: Color(0.55, 0.85, 1.0),
	GameManager.TowerType.LASER: Color(0.95, 0.35, 0.85),
}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_panel.hide()
	wave_toast.hide()
	start_panel.show()
	start_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	start_button.mouse_filter = Control.MOUSE_FILTER_STOP

	GameManager.gold_changed.connect(_on_gold_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.level_changed.connect(_on_level_changed)
	GameManager.game_over_signal.connect(_on_game_over)
	GameManager.tower_selected.connect(_on_tower_selected)

	if not start_button.pressed.is_connected(_on_start):
		start_button.pressed.connect(_on_start)
	restart_button.pressed.connect(_on_restart)
	_setup_tower_buttons()

	_on_gold_changed(300)
	_on_lives_changed(20)
	_on_level_changed(1, GameManager.TOTAL_LEVELS, "Green Valley")
	_on_wave_changed(0, GameManager.WAVES_PER_LEVEL)
	_on_tower_selected(GameManager.TowerType.BASIC)


func _setup_tower_buttons() -> void:
	for type in GameManager.ALL_TOWER_TYPES:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(118, 36)
		var tower_name: String = GameManager.TOWER_NAMES.get(type, "")
		var tower_cost: int = GameManager.TOWER_COSTS.get(type, 0)
		var tower_desc: String = GameManager.TOWER_DESCRIPTIONS.get(type, "")
		btn.text = "%s %dg" % [tower_name, tower_cost]
		btn.tooltip_text = tower_desc
		btn.add_theme_color_override("font_color", TOWER_BUTTON_COLORS.get(type, Color.WHITE))
		btn.pressed.connect(func() -> void: GameManager.select_tower(type))
		tower_grid.add_child(btn)
		_tower_buttons[type] = btn


func _unhandled_input(event: InputEvent) -> void:
	if not start_panel.visible or _game_started:
		return
	if event.is_action_pressed("ui_accept") or (
		event is InputEventKey
		and event.pressed
		and not event.echo
		and event.keycode == KEY_SPACE
	):
		_on_start()
		get_viewport().set_input_as_handled()


func _on_start() -> void:
	if _game_started:
		return
	_game_started = true
	start_panel.hide()
	start_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	GameManager.call_deferred("start_game")


func _on_gold_changed(gold: int) -> void:
	gold_label.text = "Gold: %d" % gold
	_update_tower_buttons()


func _on_lives_changed(lives: int) -> void:
	lives_label.text = "Lives: %d" % lives


func _on_level_changed(current: int, total: int, level_name: String) -> void:
	level_label.text = "Level %d/%d: %s" % [current, total, level_name]
	if GameManager.game_running and GameManager.wave == 0 and current > 1:
		_show_level_toast(current, level_name)


func _on_wave_changed(current: int, total: int) -> void:
	if current == 0:
		wave_label.text = "Get Ready"
	else:
		wave_label.text = "Wave %d / %d" % [current, total]
		_show_wave_toast(current)


func _show_level_toast(level_num: int, level_name: String) -> void:
	wave_toast.text = "Level %d - %s" % [level_num, level_name]
	wave_toast.show()
	var tween := create_tween()
	tween.tween_interval(2.2)
	tween.tween_property(wave_toast, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void:
		wave_toast.hide()
		wave_toast.modulate.a = 1.0
	)


func _show_wave_toast(wave: int) -> void:
	if GameManager.level > 0:
		wave_toast.text = "Wave %d - Enemies Incoming!" % wave
	else:
		return
	wave_toast.show()
	var tween := create_tween()
	tween.tween_interval(1.8)
	tween.tween_property(wave_toast, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func() -> void:
		wave_toast.hide()
		wave_toast.modulate.a = 1.0
	)


func _on_tower_selected(type: int) -> void:
	for tower_type in _tower_buttons:
		var btn: Button = _tower_buttons[tower_type]
		var base_color: Color = TOWER_BUTTON_COLORS.get(tower_type, Color.WHITE)
		if tower_type == type:
			btn.modulate = base_color.lightened(0.35)
		else:
			btn.modulate = Color.WHITE

	var name: String = GameManager.TOWER_NAMES.get(type, "")
	var cost: int = GameManager.TOWER_COSTS.get(type, 0)
	var desc: String = GameManager.TOWER_DESCRIPTIONS.get(type, "")
	hint_label.text = "Selected: %s (%dg) · %s | Left-click to build/upgrade" % [name, cost, desc]


func _update_tower_buttons() -> void:
	for type in _tower_buttons:
		var btn: Button = _tower_buttons[type]
		btn.disabled = not GameManager.can_afford(type)


func _on_game_over(victory: bool) -> void:
	result_label.text = "Victory! You cleared all %d levels!" % GameManager.TOTAL_LEVELS if victory else "Defeat! The main pagoda was destroyed..."
	game_over_panel.show()


func _on_restart() -> void:
	GameManager.restart_game()
