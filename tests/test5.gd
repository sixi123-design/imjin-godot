extends SceneTree
# 신규 기능 통합 테스트: 광맥/목책·석벽 오토타일/성문/이동 차단/논 2x2/포그 페이드/미니맵
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
		print("INIT_UNITS=", main.units.size())
		# 광맥 배치 규칙
		var oidx := -1
		var ore_total := 0
		for i in main.ore.size():
			if main.ore[i] == 1:
				ore_total += 1
				var gy := int(i / float(main.GW))
				var gx: int = i % int(main.GW)
				if oidx < 0 and main.fog[i] == 1 and main.occ[gy][gx] == null:
					oidx = i
		print("ORE: total=", ore_total, " visible_found=", oidx >= 0)
		if oidx >= 0:
			var ogy := int(oidx / float(main.GW))
			var ogx := oidx % int(main.GW)
			print("ORE_RULES: mine_on_ore=", main.can_place("mine", ogx, ogy), " house_on_ore=", main.can_place("house", ogx, ogy))
		print("MINE_OFF_ORE=", main.can_place("mine", 28, 18))
		# 목책 개축 제거 확인 (_do_upgrade 무시)
		var w2 = main.make_building("wall", 27, 24, true)
		main.make_building("wall", 26, 24, true)
		main.make_building("wall", 28, 24, true)
		main.sel_building = w2
		main._do_upgrade()
		print("WALL_NO_UPGRADE: still=", w2["type"])
		# 벽 차단 / 빈 타일 통과
		print("BLOCK: wall=", main._blocked(26.5 * 22.0, 24.5 * 22.0), " open=", main._blocked(31.5 * 22.0, 24.5 * 22.0))
		# 이동 차단 (벽 너머 집결 명령)
		var u = main.units[0]
		u["x"] = 27.5 * 22.0
		u["y"] = 25.6 * 22.0
		u["ox"] = 27.5 * 22.0
		u["oy"] = 22.5 * 22.0
		for i in 80:
			main.sim_update(0.05)
		print("UNIT_BLOCKED=", u["y"] > 24.9 * 22.0)
		# 농경지 2x2 점유 + 개축 제거 확인
		var f = main.make_building("farm", 33, 27, true)
		main.sel_building = f
		main._do_upgrade()
		var occ_ok: bool = main.occ[f["gy"]][f["gx"]] == f and main.occ[f["gy"] + 1][f["gx"] + 1] == f
		print("FARM_2x2: type=", f["type"], " size=", f["size"], " occ4=", occ_ok)
		# 포그 페이드 레벨
		main._recalc_fog_lv()
		var n_full := 0
		var n_edge := 0
		var n_soft := 0
		for i in main.fog_lv.size():
			if main.fog_lv[i] >= 1.0:
				n_full += 1
			elif main.fog_lv[i] > 0.5:
				n_edge += 1
			elif main.fog_lv[i] > 0.0:
				n_soft += 1
		print("FOGLV: full=", n_full > 0, " edge=", n_edge > 0, " soft=", n_soft > 0)
		# 미니맵
		main._update_minimap()
		print("MINIMAP=", main.mm_img.get_size())
		main._draw()
		print("DRAW_OK")
		quit()
	return false
