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
		var hqx: float = main.hq["x"]
		var hqy: float = main.hq["y"]
		# 포그: HQ 주변 가시, 원거리 불가시 + 건설 금지
		print("FOG near=", main.tile_visible(hqx, hqy), " far=", main.tile_visible(100.0, 100.0), " place_far=", main.can_place("wall", 3, 3), " place_near=", main.can_place("wall", 28, 20))
		# 건설 + 개축 흐름
		main.res["wood"] = 999.0
		main.res["iron"] = 999.0
		main.res["food"] = 999.0
		# 행궁 주변 2타일 건설 금지 + 기본 병사 행궁 모집(훈련소 없이)
		print("HQ_ZONE: near=", main.can_place("house", int(main.hq["gx"]) + 2, int(main.hq["gy"])), " ok=", main.can_place("house", int(main.hq["gx"]) + 5, int(main.hq["gy"])))
		main.recruit("archer")
		print("HQ_RECRUIT: units=", main.units.size(), " (기대 2)")
		main.recruit("archer2")
		var blocked: int = main.units.size()
		var h = main.make_building("house", 28, 20)
		var bar = main.make_building("barracks", 34, 20)
		for i in 400:
			main.sim_update(0.05)
		print("BUILT: house=", h["type"], " hp=", int(h["hp"]), " pop=", main.pop_max())
		main.sel_building = h
		main._do_upgrade()
		print("NO_UPGRADE: type=", h["type"], " (개축 전면 삭제) pop=", main.pop_max())
		# 정예 병사: 훈련소 완공 후 허용 (개축 불필요)
		main.recruit("archer2")
		main.recruit("spear2")
		print("TIER2: before=", blocked, " after=", main.units.size(), " barracks=", bar["type"])
		# 탭 전환 (0=생산 1=방어 2=병력)
		main._switch_tab(2)
		print("TAB: prod=", main.build_box.visible, " def=", main.def_box.visible, " unit=", main.unit_box.visible)
		# 최종 총공세 성능/안정
		main.wave_idx = 7
		main.start_wave(main.WAVES[7])
		var t0 := Time.get_ticks_msec()
		for i in 900:
			main.sim_update(0.05)
		print("HORDE: enemies=", main.enemies.size(), " spawnq=", main.spawn_q.size(), " ms/900steps=", Time.get_ticks_msec() - t0, " hq=", int(main.hq["hp"]))
		main._draw()
		print("DRAW_OK")
		quit()
	return false
