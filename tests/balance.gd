extends SceneTree
# 밸런스 시뮬 (54x54, HQ 중심 (26,26)): 시기별 요새 vs 공세 — 신규 적/연구 반영
var main
var frame := 0

func north_wall(rows := 1) -> void:
	for gx in range(23, 41):
		for r in rows:
			main.make_building("wall2", gx, 25 - r, true)

func ring_wall() -> void:
	# 최종전 표준: 철벽 링
	for gx in range(22, 42):
		for gy in [24, 25, 38, 39]:
			if main.occ[gy][gx] == null and main.cliff[gy * main.GW + gx] == 0:
				main.make_building("wall3", gx, gy, true)
	for gy in range(26, 38):
		for gx in [22, 23, 40, 41]:
			if main.occ[gy][gx] == null and main.cliff[gy * main.GW + gx] == 0:
				main.make_building("wall3", gx, gy, true)

func towers(a2: Array, ct: Array, bt: Array = []) -> void:
	for p in a2:
		main.make_building("atower", p[0], p[1], true)
	for p in ct:
		main.make_building("ctower", p[0], p[1], true)
	for p in bt:
		main.make_building("btower", p[0], p[1], true)

func troops(n_ar: int, n_sp: int, n_ar2: int, n_sp2: int, y: float) -> void:
	var k := 0
	for spec in [["archer", n_ar], ["spear", n_sp], ["archer2", n_ar2], ["spear2", n_sp2]]:
		for i in int(spec[1]):
			var u = main._make_unit(spec[0], (24.5 + k * 0.9) * 22.0, y * 22.0)
			u["ox"] = u["x"]
			u["oy"] = u["y"]
			main.units.append(u)
			k += 1

func run_wave(idx: int, all_sides: bool) -> Dictionary:
	main.enemies.clear()
	main.spawn_q.clear()
	main.wave_idx = idx
	var w: Dictionary = main.WAVES[idx]
	if not all_sides:
		w["side"] = 0
	main.start_wave(w)
	var steps := 0
	while (not main.enemies.is_empty() or not main.spawn_q.is_empty()) and steps < 24000 and main.hq["hp"] > 0.0:
		main.sim_update(0.05)
		steps += 1
	if steps >= 24000:
		for e in main.enemies.slice(0, 4):
			print("  STUCK: pos=(", int(e["x"] / 22.0), ",", int(e["y"] / 22.0), ") tgt=", (e["target"].get("type", "unit?") if e["target"] != null else "none"))
	var walls := 0
	for b in main.buildings:
		if b["type"] == "wall" or b["type"] == "wall2" or b["type"] == "gate":
			walls += 1
	return {"steps":steps, "hq":int(main.hq["hp"]), "walls":walls, "units":main.units.size(), "enemies_left":main.enemies.size()}

func reset_scene() -> void:
	if main != null:
		main.queue_free()
	main = load("res://main.tscn").instantiate()
	root.add_child(main)

func _process(_delta) -> bool:
	frame += 1
	if frame == 2:
		reset_scene()
	if frame == 4:
		# A: 5차(16일차, 왜장 1 포함) — 중반 요새 (연구 없음)
		main._on_start()
		main.game_time = 16.0 * 28.0
		north_wall(1)
		towers([[26, 27], [31, 27], [36, 27]], [[31, 28]])
		troops(8, 4, 0, 0, 27.5)
		print("A(w5,mid): ", run_wave(4, false))
	if frame == 6:
		reset_scene()
	if frame == 8:
		# B: 7차(22일차) — 후반 요새 + 연구 1
		main._on_start()
		main.game_time = 22.0 * 28.0
		north_wall(2)
		towers([[24, 27], [27, 27], [30, 27], [33, 27], [36, 27], [39, 27]], [[29, 28], [32, 28], [35, 28]], [[30, 29], [33, 29]])
		troops(12, 6, 1, 1, 27.5)
		print("B(w7,late): ", run_wave(6, false))
	if frame == 10:
		reset_scene()
	if frame == 12:
		# C: 최종(사방, 왜장 3+폭탄병) — 최대 요새 + 연구 2~3
		main._on_start()
		main.game_time = 26.0 * 28.0
		ring_wall()
		towers([[25, 27], [29, 27], [34, 27], [38, 27], [25, 36], [31, 36], [37, 36], [27, 31]], [[28, 28], [33, 28], [31, 35], [36, 31]], [[30, 30], [33, 32]])
		troops(18, 10, 3, 3, 31.5)
		print("C(w8,final): ", run_wave(7, true))
		quit()
	return false
