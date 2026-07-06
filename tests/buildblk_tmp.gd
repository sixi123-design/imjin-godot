extends SceneTree
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		main._on_start()
		# 배치 가능한 타일 탐색
		var spot := Vector2i(-1, -1)
		for gy in range(20, 44):
			for gx in range(20, 44):
				if main.can_place("wall", gx, gy):
					spot = Vector2i(gx, gy)
					break
			if spot.x >= 0:
				break
		var ok1: bool = main.can_place("wall", spot.x, spot.y)
		main.enemies.append({"type":"ashi", "x":(spot.x + 2.0) * 22.0, "y":(spot.y + 0.5) * 22.0, "hp":10.0, "maxhp":10.0, "dmg":2.5, "cd":1.0, "atk_t":0.0,
			"tox":0.0, "toy":0.0, "target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":true, "fx":1.0})
		var ok2: bool = main.can_place("wall", spot.x, spot.y)
		main.enemies.clear()
		var ok3: bool = main.can_place("wall", spot.x, spot.y)
		print("BUILD_BLOCK: normal=", ok1, " near_enemy=", ok2, " cleared=", ok3)
		quit()
	return false
