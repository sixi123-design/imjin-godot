extends SceneTree
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		# 난이도
		main.difficulty = 2
		main._apply_difficulty()
		print("DIFF: hp=", main.diff_mult["hp"], " count=", main.diff_mult["count"])
		# 모디파이어
		main.chosen_mod = "ally_boost"
		main._apply_mod()
		print("MOD_ALLY: ", main.mod_flags.get("ally_dmg"))
		main.chosen_mod = "cheap_wall"
		main._apply_mod()
		print("MOD_WALL: wall_cost=", main.BDEFS["wall"]["cost"])
		main._on_start()
		# 시장
		main.res = {"food":100.0, "wood":100.0, "iron":100.0}
		main.mod_flags = {}
		main._trade("wood", "food")
		print("TRADE: wood=", int(main.res["wood"]), " food=", int(main.res["food"]), " (기대 50/130)")
		main.res = {"food":0.0, "wood":500.0, "iron":0.0}
		main._trade("wood", "iron", 500)
		print("TRADE_BIG: wood=", int(main.res["wood"]), " iron=", int(main.res["iron"]), " (기대 0/300)")
		var mk = main.make_building("market", 30, 30, true)
		print("MARKET: type=", mk["type"], " has=", main.has_market())
		var before_workers: int = main.workers.size()
		main.make_building("wall", 34, 30)
		main.make_building("atower", 36, 30)
		print("DEF_BUILD_WORKERS: before=", before_workers, " after=", main.workers.size(), " hidden=", main.workers_hidden)
		# 무한 웨이브 생성
		main.endless = true
		main.wave_idx = main.WAVES.size() - 1
		main.WAVES[main.wave_idx]["started"] = true
		main.enemies.clear()
		main.spawn_q.clear()
		var n0: int = main.WAVES.size()
		main.sim_update(0.05)
		print("ENDLESS: waves_grew=", main.WAVES.size() > n0, " endless_wave=", main.endless_wave)
		# 저장/로드
		main._save_game()
		print("SAVE: exists=", FileAccess.file_exists("user://save.dat"))
		main._load_game()
		print("LOAD_OK buildings=", main.buildings.size())
		main._draw()
		print("DRAW_OK")
		quit()
	return false
