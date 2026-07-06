extends SceneTree
func _initialize():
	var s = load("res://main.gd")
	print("script=", s)
	var n = Node2D.new()
	n.set_script(s)
	print("attached=", n.get_script() != null)
	quit()
