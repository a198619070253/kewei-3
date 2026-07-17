extends Node

const FROST_BURST := preload("res://scripts/frost_burst.gd")
const EXPLOSION := preload("res://scripts/explosion_effect.gd")
const HIT_SPARK := preload("res://scripts/hit_spark.gd")
const POISON_BURST := preload("res://scripts/poison_burst.gd")
const LIGHTNING_ARC := preload("res://scripts/lightning_arc.gd")
const FIRE_BURST := preload("res://scripts/fire_burst.gd")
const PIERCE_LINE := preload("res://scripts/pierce_line.gd")
const MORTAR_ARC := preload("res://scripts/mortar_arc.gd")


func _effects_root() -> Node2D:
	var scene := get_tree().current_scene
	if scene and scene.has_node("Effects"):
		return scene.get_node("Effects")
	return null


func _spawn_fx(script: GDScript) -> Node2D:
	var root := _effects_root()
	if root == null:
		return null
	var fx := Node2D.new()
	fx.set_script(script)
	root.add_child(fx)
	return fx


func spawn_frost_burst(pos: Vector2) -> void:
	var fx := _spawn_fx(FROST_BURST)
	if fx:
		fx.setup(pos)


func spawn_explosion(pos: Vector2, radius: float) -> void:
	var fx := _spawn_fx(EXPLOSION)
	if fx:
		fx.setup(pos, radius)


func spawn_hit_spark(pos: Vector2, color: Color) -> void:
	var fx := _spawn_fx(HIT_SPARK)
	if fx:
		fx.setup(pos, color)


func spawn_poison_burst(pos: Vector2) -> void:
	var fx := _spawn_fx(POISON_BURST)
	if fx:
		fx.setup(pos)


func spawn_lightning_arc(from_pos: Vector2, to_pos: Vector2) -> void:
	var fx := _spawn_fx(LIGHTNING_ARC)
	if fx:
		fx.setup(from_pos, to_pos)


func spawn_laser_beam(from_pos: Vector2, to_pos: Vector2) -> void:
	var fx := _spawn_fx(LASER_BEAM)
	if fx:
		fx.setup(from_pos, to_pos)


func spawn_muzzle_flash(pos: Vector2, color: Color) -> void:
	spawn_hit_spark(pos, Color(color.r, color.g, color.b, 0.7))


func spawn_fire_burst(pos: Vector2) -> void:
	var fx := _spawn_fx(FIRE_BURST)
	if fx:
		fx.setup(pos)


func spawn_pierce_line(from_pos: Vector2, to_pos: Vector2) -> void:
	var fx := _spawn_fx(PIERCE_LINE)
	if fx:
		fx.setup(from_pos, to_pos)


func spawn_mortar_arc(from_pos: Vector2, to_pos: Vector2) -> void:
	var fx := _spawn_fx(MORTAR_ARC)
	if fx:
		fx.setup(from_pos, to_pos)


func spawn_boss_death(pos: Vector2) -> void:
	spawn_explosion(pos, 55.0)
	spawn_hit_spark(pos, Color(1.0, 0.85, 0.3))
	spawn_hit_spark(pos + Vector2(12, -8), Color(0.95, 0.4, 0.9))
