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
		main.game_time = 26.0 * 28.0
		for gx in range(24, 40):
			for gy in [16, 27]:
				if main.can_place("wall", gx, gy):
					main.make_building("wall2", gx, gy, true)
		for gy in range(17, 27):
			for gx in [24, 39]:
				if main.can_place("wall", gx, gy):
					main.make_building("wall2", gx, gy, true)
		for p in [[27, 18], [35, 18], [27, 25], [35, 25]]:
			main.make_building("atower2", p[0], p[1], true)
		for p in [[31, 18], [31, 24]]:
			main.make_building("ctower", p[0], p[1], true)
		var k := 0
		for spec in [["archer", 6], ["spear", 4], ["archer2", 2]]:
			for i in int(spec[1]):
				var u = main._make_unit(spec[0], (26.0 + k * 0.9) * 22.0, 20.0 * 22.0)
				u["ox"] = u["x"]
				u["oy"] = u["y"]
				main.units.append(u)
				k += 1
		main.wave_idx = 7
		main.start_wave(main.WAVES[7])
		var steps := 0
		while (not main.enemies.is_empty() or not main.spawn_q.is_empty()) and steps < 24000 and main.hq["hp"] > 0.0:
			main.sim_update(0.05)
			steps += 1
		var walls := 0
		for b in main.buildings:
			if b["type"] == "wall2":
				walls += 1
		print("C_WEAK: steps=", steps, " hq=", int(main.hq["hp"]), " walls=", walls, " units=", main.units.size(), " left=", main.enemies.size())
		quit()
	return false
