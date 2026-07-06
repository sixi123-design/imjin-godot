extends SceneTree
var main
var frame := 0

func _process(_delta) -> bool:
	frame += 1
	if frame == 1:
		main = load("res://main.tscn").instantiate()
		root.add_child(main)
	if frame == 4:
		print("WARNS=", main.balance_warns.size(), " ", main.balance_warns)
		print("CFG_GLOBAL: hp_growth=", main.ENEMY_HP_GROWTH, " bomber_dmg=", main.BOMBER_DMG, " res_maxlv=", main.RES_MAX_LV)
		print("CFG_BLDG: wall_hp=", main.BDEFS["wall"]["hp"], " farm_prod=", main.BDEFS["farm"]["prod"], " ctower_rng=", main.BDEFS["ctower"]["rng"] / 22.0)
		print("CFG_UNIT: spear2=", main.UDEFS["spear2"]["hp"], "/", main.UDEFS["spear2"]["dmg"], " cost=", main.UDEFS["spear2"]["cost"], " armor=", main.UDEFS["spear2"].get("armor"))
		print("CFG_ENEMY: ashi_spd=", main.EDEFS["ashi"]["spd"], " lord_hp=", main.EDEFS["lord"]["hp"])
		print("CFG_WAVES: n=", main.WAVES.size(), " final=", main.WAVES[7]["comp"], " day=", main.WAVES[7]["day"])
		print("CFG_KEY: f2=", main.KEY_SELECT_ALL == KEY_F2)
		print("RES_START: ", main.res)
		quit()
	return false
