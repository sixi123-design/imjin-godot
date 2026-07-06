extends SceneTree
func _initialize():
	var n := Node2D.new()
	n.name = "Main"
	n.set_script(load("res://main.gd"))
	var ps := PackedScene.new()
	var err := ps.pack(n)
	print("pack=", err)
	print("save=", ResourceSaver.save(ps, "res://main.tscn"))
	quit()
