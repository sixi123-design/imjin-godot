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
		main.intro_t = 0.0
		# 갑사 하나가 좁은 길목을 막는 상황
		var g = main._make_unit("spear2", 700.0, 700.0)
		g["ox"] = g["x"]
		g["oy"] = g["y"]
		main.units.append(g)
		main.enemies.append({"type":"ashi", "x":700.0, "y":760.0, "hp":160.0, "maxhp":160.0, "dmg":0.5, "cd":0.5, "atk_t":0.0,
			"tox":0.0, "toy":0.0, "target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":true, "fx":1.0})
		for i in 40:
			main.sim_update(0.05)
		var e = main.enemies[0] if not main.enemies.is_empty() else null
		if e != null:
			print("GAPSA_BLOCK: enemy_y=", snapped(e["y"], 1.0), " passed=", e["y"] < 690.0, " attacking_gapsa=", e["target"] == g)
		else:
			print("GAPSA_BLOCK: enemy dead (갑사가 처치)")
		quit()
	return false
