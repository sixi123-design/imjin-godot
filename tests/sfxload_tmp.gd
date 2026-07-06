extends SceneTree
var main
var frame := 0
func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		print("SFX_LOADED=", main.SFX.size(), " / 26개 기대")
		var missing := []
		for n in ["arrow","recruit","hammer","enemy_die","ally_die","move","ally_attack","enemy_attack","event","wave_warn","deny","menu","intro","gamestart","victory","defeat"]:
			if not main.SFX.has(n):
				missing.append(n)
		print("MISSING=", missing)
		quit()
	return false
