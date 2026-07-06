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
		var bt = main.make_building("btower", 38, 31, true)
		for i in 10:
			main.enemies.append({"type":"ashi", "x":(42.0 + (i % 3)) * 22.0, "y":(30.0 + i * 0.4) * 22.0, "hp":16.0, "maxhp":16.0, "dmg":4.0, "cd":99.0,
				"target":main.hq, "rt":99.0, "flash":0.0, "ph":0.0, "moving":false, "fx":1.0})
		var n0: int = main.enemies.size()
		for i in 40:
			main.sim_update(0.05)
		var after_first: int = main.enemies.size()
		var cd_now: float = bt["cd"]
		for i in 40:
			main.sim_update(0.05)
		print("BTOWER: first_kill=", n0 - after_first, " cd_after_shot=", snapped(cd_now, 0.1), " second_volley_done=", main.enemies.size() < after_first or main.enemies.is_empty())
		quit()
	return false
