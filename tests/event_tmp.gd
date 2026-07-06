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
		main.wave_idx = 3
		# 이벤트 강제 호출로 각 분기 스모크
		var u0: int = main.units.size()
		main.units.clear()
		for i in 20:
			main.chosen_mod = ""
			main._roll_event()
		print("EVENT_ROLLS_OK reinforce_or_more units=", main.units.size(), " mods=", main.mod_flags.keys())
		# 일시 모디파이어 해제
		main.mod_flags = {"ally_dmg":2.0, "enemy_hp":1.5, "refund_full":true}
		main._clear_temp_mods()
		print("CLEAR_TEMP: refund_kept=", main.mod_flags.get("refund_full", false), " ally_cleared=", not main.mod_flags.has("ally_dmg"))
		main._draw()
		print("DRAW_OK")
		quit()
	return false
