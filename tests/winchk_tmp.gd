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
		main.wave_idx = main.WAVES.size() - 1
		main.WAVES[7]["started"] = true
		main.enemies.clear()
		main.spawn_q.clear()
		main.last_kill = Vector2(200.0, 200.0)
		var c0: Vector2 = main.cam.position
		main.sim_update(0.05)
		for i in 30:
			main._process(0.033)
		print("WIN_CAM: moved=", main.cam.position.distance_to(c0) > 100.0, " zoom=", snapped(main.cam.zoom.x, 0.01), " win_t=", snapped(main.win_t, 0.1))
		quit()
	return false
