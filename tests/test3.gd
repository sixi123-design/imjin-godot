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
		main._zoom(Vector2(576, 350), 1.5)
		print("ZOOM: ", main.cam.zoom.x)
		main._zoom(Vector2(576, 350), 1.0 / 1.5)
		main.build_sel = "wall"
		var cp: Vector2 = main.iso(12.5 * 22.0, 10.5 * 22.0)
		var p: Vector2 = main.get_canvas_transform() * cp
		var mm := InputEventMouseMotion.new()
		mm.position = p
		main._unhandled_input(mm)
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		mb.pressed = true
		mb.position = p
		main._unhandled_input(mb)
		var mu := InputEventMouseButton.new()
		mu.button_index = MOUSE_BUTTON_LEFT
		mu.pressed = false
		mu.position = p
		main._unhandled_input(mu)
		print("BUILD: buildings=", main.buildings.size(), " wood=", int(main.res["wood"]), " hover=", main.hover)
		# 줌 상태에서 배치 (좌표 변환 왕복 검증)
		var wz := InputEventMouseButton.new()
		wz.button_index = MOUSE_BUTTON_WHEEL_UP
		wz.pressed = true
		wz.position = Vector2(400, 300)
		main._unhandled_input(wz)
		main._unhandled_input(wz)
	if frame == 6:
		main.build_sel = "wall"
		var cp2: Vector2 = main.iso(14.5 * 22.0, 10.5 * 22.0)
		var p2: Vector2 = main.get_canvas_transform() * cp2
		var mm2 := InputEventMouseMotion.new()
		mm2.position = p2
		main._unhandled_input(mm2)
		var mb2 := InputEventMouseButton.new()
		mb2.button_index = MOUSE_BUTTON_LEFT
		mb2.pressed = true
		mb2.position = p2
		main._unhandled_input(mb2)
		print("BUILD_ZOOMED: buildings=", main.buildings.size(), " zoom=", main.cam.zoom.x, " hover=", main.hover)
		for i in 1200:
			main.sim_update(0.05)
			if main.game_over:
				break
		print("SIM: day=", main.cur_day(), " wave=", main.wave_idx, " hq=", int(main.hq["hp"]), " over=", main.game_over)
		main._draw()
		print("DRAW_OK")
		quit()
	return false
