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
		main.res["food"] = 9999.0
		main.res["iron"] = 9999.0
		while main.pop_used() < main.pop_max():
			main.recruit("archer")
		var n0: int = main.units.size()
		main.recruit("archer")
		print("POP_MSG: blocked=", main.units.size() == n0, " banner=", main.banner_lbl.text)
		main._update_hud()
		print("BTN: disabled=", main.btns["archer"].disabled, " tooltip=", main.btns["archer"].tooltip_text.substr(0, 20))
		quit()
	return false
