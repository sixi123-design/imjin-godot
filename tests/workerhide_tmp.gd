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
		main.res = {"food":9999.0, "wood":9999.0, "iron":9999.0}
		main.make_building("farm", 22, 22)
		var build_workers: int = main.workers.size()
		main.make_building("wall", 26, 22)
		main.make_building("atower", 28, 22)
		var after_defense_workers: int = main.workers.size()
		var w := {"day":1, "side":0, "comp":{"ashi":1}}
		main.start_wave(w)
		var hidden_started: bool = main.workers_hidden
		main.spawn_q.clear()
		main.enemies.clear()
		w["started"] = true
		main.WAVES = [w, {"day":2, "side":1, "comp":{"ashi":1}}]
		main.wave_idx = 0
		main.sim_update(0.05)
		var d_hq: int = int(main.wdist(main.workers[0]["x"], main.workers[0]["y"], main.hq["x"], main.hq["y"] + 30.0))
		var going_home: bool = main.workers[0]["tx"] != main.hq["x"] and main.workers[0]["ty"] != main.hq["y"] + 30.0
		print("WORKER_HIDE: build=", build_workers, " after_def=", after_defense_workers, " hidden_start=", hidden_started, " hidden_end=", main.workers_hidden, " d_hq=", d_hq, " going_job=", going_home)
		quit()
	return false
