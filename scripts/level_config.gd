extends Node

const WAVES_PER_LEVEL := 5
const TOTAL_LEVELS := 5


static func get_level(index: int) -> Dictionary:
	return get_levels()[index]


static func get_total_waves() -> int:
	return WAVES_PER_LEVEL * TOTAL_LEVELS


static func global_wave_index(level: int, wave: int) -> int:
	return (level - 1) * WAVES_PER_LEVEL + wave


static func get_levels() -> Array:
	return [
		{
			"name": "Green Valley",
			"ground": Color(0.15, 0.22, 0.14),
			"base": Vector2(1240, 360),
			"path": PackedVector2Array([
				Vector2(60, 360), Vector2(180, 360), Vector2(180, 140),
				Vector2(520, 140), Vector2(520, 520), Vector2(880, 520),
				Vector2(880, 220), Vector2(1100, 220), Vector2(1100, 360),
				Vector2(1240, 360),
			]),
			"slots": [
				Vector2(120, 280), Vector2(120, 440), Vector2(60, 280), Vector2(300, 360),
				Vector2(260, 80), Vector2(260, 220), Vector2(180, 280), Vector2(350, 140),
				Vector2(400, 80), Vector2(400, 220), Vector2(450, 140), Vector2(520, 280),
				Vector2(460, 420), Vector2(460, 560), Vector2(520, 440), Vector2(700, 520),
				Vector2(640, 420), Vector2(640, 560), Vector2(780, 420), Vector2(780, 560),
				Vector2(720, 80), Vector2(720, 160), Vector2(880, 280), Vector2(880, 380),
				Vector2(960, 80), Vector2(960, 160), Vector2(960, 300), Vector2(960, 440),
				Vector2(1000, 220), Vector2(1040, 300), Vector2(1040, 440), Vector2(1100, 290),
				Vector2(1180, 360), Vector2(1180, 440),
			],
		},
		{
			"name": "Stone Ridge",
			"ground": Color(0.20, 0.18, 0.16),
			"base": Vector2(1240, 320),
			"path": PackedVector2Array([
				Vector2(640, 50), Vector2(640, 190), Vector2(180, 190),
				Vector2(180, 520), Vector2(920, 520), Vector2(920, 320),
				Vector2(1240, 320),
			]),
			"slots": [
				Vector2(640, 120), Vector2(640, 260), Vector2(500, 190), Vector2(780, 120),
				Vector2(300, 190), Vector2(180, 340), Vector2(180, 440), Vector2(180, 260),
				Vector2(280, 520), Vector2(400, 520), Vector2(520, 520), Vector2(650, 520),
				Vector2(820, 520), Vector2(920, 440), Vector2(920, 260), Vector2(1020, 400),
				Vector2(1080, 320), Vector2(1150, 320), Vector2(1150, 420), Vector2(780, 190),
				Vector2(1000, 520), Vector2(560, 190), Vector2(380, 340), Vector2(920, 580),
			],
		},
		{
			"name": "Bamboo Crossing",
			"ground": Color(0.12, 0.24, 0.14),
			"base": Vector2(1240, 180),
			"path": PackedVector2Array([
				Vector2(60, 620), Vector2(380, 620), Vector2(380, 300),
				Vector2(760, 300), Vector2(760, 520), Vector2(1080, 520),
				Vector2(1080, 180), Vector2(1240, 180),
			]),
			"slots": [
				Vector2(120, 560), Vector2(220, 620), Vector2(60, 560), Vector2(280, 620),
				Vector2(380, 500), Vector2(380, 400), Vector2(380, 220), Vector2(480, 300),
				Vector2(520, 300), Vector2(640, 300), Vector2(640, 400), Vector2(760, 400),
				Vector2(760, 460), Vector2(760, 580), Vector2(900, 520), Vector2(980, 520),
				Vector2(1080, 460), Vector2(1080, 300), Vector2(1080, 100), Vector2(960, 180),
				Vector2(1150, 180), Vector2(1150, 260), Vector2(500, 620), Vector2(620, 520),
				Vector2(880, 300), Vector2(880, 400), Vector2(300, 300),
			],
		},
		{
			"name": "Misty Forest",
			"ground": Color(0.10, 0.18, 0.20),
			"base": Vector2(1240, 360),
			"path": PackedVector2Array([
				Vector2(60, 360), Vector2(280, 360), Vector2(280, 100),
				Vector2(720, 100), Vector2(720, 600), Vector2(1040, 600),
				Vector2(1040, 360), Vector2(1240, 360),
			]),
			"slots": [
				Vector2(120, 280), Vector2(120, 440), Vector2(60, 360), Vector2(200, 360),
				Vector2(280, 200), Vector2(280, 480), Vector2(280, 280), Vector2(380, 100),
				Vector2(480, 100), Vector2(600, 100), Vector2(720, 220), Vector2(720, 480),
				Vector2(720, 560), Vector2(720, 360), Vector2(880, 600), Vector2(960, 600),
				Vector2(1040, 500), Vector2(1040, 280), Vector2(1040, 420), Vector2(920, 360),
				Vector2(480, 360), Vector2(600, 600), Vector2(600, 480), Vector2(1160, 360),
				Vector2(1160, 280), Vector2(820, 100), Vector2(820, 480),
			],
		},
		{
			"name": "Dragon Gate",
			"ground": Color(0.22, 0.14, 0.12),
			"base": Vector2(1240, 480),
			"path": PackedVector2Array([
				Vector2(60, 120), Vector2(320, 120), Vector2(320, 360),
				Vector2(560, 360), Vector2(560, 600), Vector2(840, 600),
				Vector2(840, 240), Vector2(1080, 240), Vector2(1080, 480),
				Vector2(1240, 480),
			]),
			"slots": [
				Vector2(120, 180), Vector2(220, 120), Vector2(60, 120), Vector2(200, 240),
				Vector2(320, 240), Vector2(320, 480), Vector2(320, 120), Vector2(440, 360),
				Vector2(440, 280), Vector2(560, 480), Vector2(560, 540), Vector2(560, 280),
				Vector2(700, 600), Vector2(760, 600), Vector2(840, 520), Vector2(840, 340),
				Vector2(840, 180), Vector2(960, 240), Vector2(960, 320), Vector2(1080, 320),
				Vector2(1080, 420), Vector2(1080, 560), Vector2(1160, 480), Vector2(1160, 400),
				Vector2(700, 240), Vector2(480, 120), Vector2(480, 480), Vector2(960, 600),
				Vector2(200, 360), Vector2(680, 360),
			],
		},
	]
