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
		var w3 = main.make_building("wall3", 40, 31, true)
		print("WALL3: hp=", w3["hp"], " blocked=", main._wall_at(40.5 * 22.0, 31.5 * 22.0), " btn=", main.btns.has("wall3"))
		w3["flash"] = 0.12
		main._draw()
		print("WHITE_FLASH_DRAW_OK cached=", main.TEXW.size() > 0)
		quit()
	return false
