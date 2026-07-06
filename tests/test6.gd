extends SceneTree
# v3 테스트: 절벽/진흙, 2x2 건물, 정예 전투 수정, 전체선택
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		main._on_start()
		main.res["wood"] = 9999.0
		main.res["iron"] = 9999.0
		main.res["food"] = 9999.0
		# 절벽/진흙
		var ci := -1
		var mi := -1
		for i in main.cliff.size():
			if ci < 0 and main.cliff[i] == 1:
				ci = i
			if mi < 0 and main.mud[i] == 1:
				mi = i
		print("TERRAIN: cliffs=", main.cliffs.size(), " mud_found=", mi >= 0)
		if ci >= 0:
			var cgy := int(ci / float(main.GW))
			var cgx: int = ci % int(main.GW)
			print("CLIFF: blocked=", main._terra_blocked((cgx + 0.5) * 22.0, (cgy + 0.5) * 22.0), " place=", main.can_place("house", cgx, cgy))
		if mi >= 0:
			var mgy := int(mi / float(main.GW))
			var mgx: int = mi % int(main.GW)
			print("MUD: passable=", not main._terra_blocked((mgx + 0.5) * 22.0, (mgy + 0.5) * 22.0), " place=", main.can_place("house", mgx, mgy))
		# 2x2 건물
		var f = main.make_building("farm", 20, 22, true)
		var br = main.make_building("barracks", 33, 22, true)
		print("SIZE2: farm=", f["size"], " barracks=", br["size"], " occ=", main.occ[f["gy"] + 1][f["gx"] + 1] == f and main.occ[br["gy"] + 1][br["gx"] + 1] == br)
		# 정예 전투: 갑사 근접 추격+타격, 편전수 화살
		main.make_building("barracks2", 26, 18, true)
		var s2 = main._make_unit("spear2", 30.0 * 22.0, 30.0 * 22.0)
		s2["ox"] = s2["x"]
		s2["oy"] = s2["y"]
		main.units.append(s2)
		main.enemies.append({"type":"ashi", "x":31.5 * 22.0, "y":30.0 * 22.0, "hp":16.0, "maxhp":16.0, "cd":99.0,
			"target":null, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		main.enemies[0]["target"] = main.hq
		for i in 60:
			main.sim_update(0.05)
		print("SPEAR2_FIGHTS=", main.enemies.is_empty() or main.enemies[0]["hp"] < 16.0)
		main.enemies.clear()
		var a2 = main._make_unit("archer2", 10.0 * 22.0, 30.0 * 22.0)
		main.units.append(a2)
		main.enemies.append({"type":"ashi", "x":13.0 * 22.0, "y":30.0 * 22.0, "hp":16.0, "maxhp":16.0, "cd":99.0,
			"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		var saw_proj := false
		for i in 40:
			main.sim_update(0.05)
			if not main.projs.is_empty():
				saw_proj = true
		print("ARCHER2_ARROW=", saw_proj)
		main.enemies.clear()
		# 전체선택
		main._select_all_units()
		print("SELECT_ALL=", main.sel_units.size() == main.units.size(), " n=", main.sel_units.size())
		# 석벽 직접 건설 버튼 존재 + 비용
		print("WALL2_BTN=", main.btns.has("wall2"), " cost=", main.BDEFS["wall2"].has("cost"))
		# 이동 명령 우선 (교전 중 이탈)
		var mu = main._make_unit("spear", 20.0 * 22.0, 20.0 * 22.0)
		main.units.append(mu)
		main.enemies.append({"type":"ashi", "x":20.8 * 22.0, "y":20.0 * 22.0, "hp":16.0, "maxhp":16.0, "cd":99.0,
			"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		mu["ox"] = 20.0 * 22.0
		mu["oy"] = 14.0 * 22.0
		mu["mv"] = true
		var ehp0: float = main.enemies[0]["hp"]
		for i in 60:
			main.sim_update(0.05)
		print("MOVE_ORDER: moved=", mu["y"] < 17.0 * 22.0, " no_fight=", main.enemies[0]["hp"] == ehp0, " mv_off=", not mu["mv"])
		main.enemies.clear()
		main._draw()
		print("DRAW_OK")
		quit()
	return false
