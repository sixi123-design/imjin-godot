extends SceneTree
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		print("DIFF_DEFAULT: ", main.difficulty, " btn=", main.diff_cycle_btn.text)
		main._cycle_diff()
		print("DIFF_CYCLE1: ", main.difficulty, " btn=", main.diff_cycle_btn.text)
		main._cycle_diff(); main._cycle_diff()
		print("DIFF_CYCLE3: ", main.difficulty, " (0으로 복귀)")
		# 승리 화면 무한 버튼
		main._on_start()
		main._show_end("승리!", "테스트", true)
		var has_endless := false
		for ch in main.overlay.get_children():
			for gc in ch.get_children():
				for ggc in gc.get_children():
					if ggc is Button and "무한" in ggc.text:
						has_endless = true
		print("VICTORY_ENDLESS_BTN: ", has_endless)
		main._continue_endless()
		print("CONTINUE_ENDLESS: endless=", main.endless, " over=", main.game_over)
		main._draw()
		print("DRAW_OK")
		quit()
	return false
