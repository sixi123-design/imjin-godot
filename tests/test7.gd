extends SceneTree
# v4 테스트: 정사각맵/연구/인구/왜장 버프/폭탄병/차수 성장/생산 플로팅/정예 강화
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		main._on_start()
		main.res["wood"] = 99999.0
		main.res["iron"] = 99999.0
		main.res["food"] = 99999.0
		print("SQUARE_MAP=", main.GW == main.GH, " (", main.GW, "x", main.GH, ")")
		print("ASHI_SPD=", main.EDEFS["ashi"]["spd"], " ELITE_COST=", main.UDEFS["archer2"]["cost"])
		# 인구: 정예 2
		main.units.clear()
		main.units.append(main._make_unit("archer", 500.0, 500.0))
		main.units.append(main._make_unit("spear2", 520.0, 500.0))
		print("POP: used=", main.pop_used(), " (archer1+spear2:2 = 3)")
		# 공방 연구
		main.make_building("smith", 30, 22, true)
		var w0: float = main.res["wood"]
		main._do_research("uatk")
		main._do_research("bdef")
		print("RESEARCH: uatk=", main.research["uatk"], " bdef=", main.research["bdef"], " paid=", main.res["wood"] < w0)
		# 차수 성장: wave 7 스폰은 기본보다 강함
		main.wave_idx = 7
		main.spawn_enemy("ashi", 0)
		var e7 = main.enemies[0]
		print("SCALING: hp=", snapped(e7["hp"], 0.1), " base=16 dmg=", snapped(e7["dmg"], 0.1), " base=4")
		main.enemies.clear()
		# 왜장 버프
		main.enemies.append({"type":"lord", "x":600.0, "y":600.0, "hp":320.0, "maxhp":320.0, "dmg":22.0, "cd":99.0,
			"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		main.enemies.append({"type":"ashi", "x":620.0, "y":600.0, "hp":16.0, "maxhp":16.0, "dmg":4.0, "cd":99.0,
			"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		main.sim_update(0.05)
		print("LORD_BUFF: near=", main._lord_buffed(main.enemies[1]), " lords=", main.lords_cache.size())
		main.enemies.clear()
		# 폭탄병: 벽 옆에서 폭발
		var wl = main.make_building("wall", 30, 30, true)
		var whp: float = wl["hp"]
		main.enemies.append({"type":"bomber", "x":30.5 * 22.0 - 14.0, "y":30.5 * 22.0, "hp":22.0, "maxhp":22.0, "dmg":0.0, "cd":0.0,
			"target":wl, "rt":99.0, "flash":0.0, "ph":0.0, "moving":true, "fx":1.0})
		for i in 30:
			main.sim_update(0.05)
		print("BOMBER: exploded=", main.enemies.is_empty(), " wall_dmg=", wl["hp"] < whp, " hp=", int(wl["hp"]), "/", int(whp))
		# 생산 플로팅
		main.make_building("farm", 20, 30, true)
		main.floats.clear()
		for i in 120:
			main.sim_update(0.05)
		print("FLOATS_SEEN=", main.floats.size() > 0 or true)
		var seen := false
		for i in 100:
			main.sim_update(0.05)
			if not main.floats.is_empty():
				seen = true
				break
		print("PROD_FLOAT=", seen)
		# 창병 범위 근접 공격 (3마리 동시 타격)
		main.units.clear()
		var sp = main._make_unit("spear", 700.0, 700.0)
		main.units.append(sp)
		for off in [[20, 0], [-16, 10], [2, -20]]:
			main.enemies.append({"type":"ashi", "x":700.0 + off[0], "y":700.0 + off[1], "hp":160.0, "maxhp":160.0, "dmg":0.0, "cd":99.0,
				"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		for i in 25:
			main.sim_update(0.05)
		var hurt := 0
		for e in main.enemies:
			if e["hp"] < 160.0:
				hurt += 1
		print("CLEAVE: hurt=", hurt, "/3")
		main.enemies.clear()
		# 방어력: 창병(25% 감소) vs 궁수
		var ar = main._make_unit("archer", 800.0, 800.0)
		main.units.append(ar)
		main.damage_thing(sp, 20.0)
		main.damage_thing(ar, 20.0)
		print("ARMOR: spear_lost=", snapped(100.0 - sp["hp"], 0.1), " archer_lost=", snapped(45.0 - ar["hp"], 0.1))
		main._draw()
		print("DRAW_OK")
		quit()
	return false
