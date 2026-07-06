extends SceneTree
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 3:
		main._on_start()
		main.build_sel = "wall"
		var p: Vector2 = main.iso(12.5 * 22.0, 10.5 * 22.0)
		var mm := InputEventMouseMotion.new()
		mm.position = p
		mm.global_position = p
		main._unhandled_input(mm)
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		mb.pressed = true
		mb.position = p
		mb.global_position = p
		main._unhandled_input(mb)
		var mu := InputEventMouseButton.new()
		mu.button_index = MOUSE_BUTTON_LEFT
		mu.pressed = false
		mu.position = p
		mu.global_position = p
		main._unhandled_input(mu)
		print("DIRECT: buildings=", main.buildings.size(), " wood=", int(main.res["wood"]), " workers=", main.workers.size(), " hover=", main.hover)
		# 병사 선택/이동 명령도 직접 검증
		var up: Vector2 = main.iso(main.units[0]["x"], main.units[0]["y"])
		var s1 := InputEventMouseButton.new()
		s1.button_index = MOUSE_BUTTON_LEFT
		s1.pressed = true
		s1.position = up
		main._unhandled_input(s1)
		var s2 := InputEventMouseButton.new()
		s2.button_index = MOUSE_BUTTON_LEFT
		s2.pressed = false
		s2.position = up
		main._unhandled_input(s2)
		print("SELECT: sel=", main.sel_units.size())
		var rc := InputEventMouseButton.new()
		rc.button_index = MOUSE_BUTTON_RIGHT
		rc.pressed = true
		rc.position = main.iso(300.0, 300.0)
		main._unhandled_input(rc)
		print("ORDER: ox=", int(main.units[0]["ox"]), " oy=", int(main.units[0]["oy"]))
		# 건설 완료까지 시뮬
		for i in 200:
			main.sim_update(0.05)
		print("BUILT: wall_hp=", int(main.buildings[1]["hp"]), " build=", main.buildings[1]["build"], " workers=", main.workers.size())
		# 철거 테스트
		main.build_sel = "demolish"
		var dp: Vector2 = main.iso(12.5 * 22.0, 10.5 * 22.0)
		var db := InputEventMouseButton.new()
		db.button_index = MOUSE_BUTTON_LEFT
		db.pressed = true
		db.position = dp
		main._unhandled_input(db)
		print("DEMOLISH: buildings=", main.buildings.size(), " wood=", int(main.res["wood"]))
		quit()
	return false
