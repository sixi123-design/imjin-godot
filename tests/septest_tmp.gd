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
		for i in 20:
			main.enemies.append({"type":"ashi","x":600.0+randf_range(-2,2),"y":600.0+randf_range(-2,2),"hp":16.0,"maxhp":16.0,"dmg":2.5,"cd":9.0,"atk_t":0.0,
				"tox":0.0,"toy":0.0,"target":main.hq,"rt":9.0,"flash":0.0,"ph":randf(),"moving":true,"fx":1.0})
		for i in 50:
			main._separate_enemies()
		var mind := 9999.0
		for a in main.enemies:
			for b in main.enemies:
				if is_same(a, b): continue
				var d = Vector2(a["x"]-b["x"], a["y"]-b["y"]).length()
				if d < mind: mind = d
		print("SEP: min_gap=", snapped(mind, 0.1), " (겹침 해소, 기대 8~13)")
		quit()
	return false
