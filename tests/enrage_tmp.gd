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
		# 설정 토글
		main._toggle_settings()
		print("SETTINGS: visible=", main.settings_panel.visible, " paused=", main.paused)
		main._toggle_settings()
		print("SETTINGS_CLOSE: visible=", main.settings_panel.visible)
		# 광폭화: 공세 진행 상태 시뮬
		main.wave_idx = 0
		main.WAVES[0]["started"] = true
		main.enemies.append({"type":"ashi","x":600.0,"y":600.0,"hp":16.0,"maxhp":16.0,"dmg":4.0,"cd":0.0,"atk_t":0.0,
			"tox":0.0,"toy":0.0,"target":main.hq,"rt":9.0,"flash":0.0,"ph":0.0,"moving":true,"fx":1.0,"bf":false})
		main.wave_elapsed = 0.0
		for i in 1400:  # 70초분 (0.05*1400)
			main.sim_update(0.05)
			# 적이 안 죽게 체력 리필
			if not main.enemies.is_empty():
				main.enemies[0]["hp"] = 16.0
		print("ENRAGE: elapsed=", snapped(main.wave_elapsed, 1.0), " enrage=", snapped(main.enrage, 1.0), " (기대 >20)")
		quit()
	return false
