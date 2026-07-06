extends SceneTree
func _initialize():
	var s = load("res://main.gd").new()
	print("SFX_LOADED=", s.SFX.size() if s.get("SFX") != null else -1)
	quit()
