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
		print("INTRO_START: zoom=", snapped(main.cam.zoom.x, 0.01), " fade=", main.fade_rect.visible, " a=", main.fade_rect.modulate.a)
	if frame == 10:
		print("INTRO_MID: t=", snapped(main.intro_t, 0.1), " zoom=", snapped(main.cam.zoom.x, 0.01), " a=", snapped(main.fade_rect.modulate.a, 0.01))
	if frame == 200:
		print("INTRO_END: t=", snapped(main.intro_t, 0.1), " zoom=", snapped(main.cam.zoom.x, 0.01), " fade_visible=", main.fade_rect.visible)
		quit()
	return false
