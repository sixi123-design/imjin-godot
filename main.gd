extends Node2D
# ============================================================
# 불멸의 성채: 임진왜란 — Godot 4 아이소메트릭 버전
# They Are Billions 스타일 · 조선 수성전
# ============================================================

const TILE := 22.0
const GW := 64
const GH := 64
const W := TILE * GW
const H := TILE * GH
const ISO_SX := 2.5454545456
const ISO_SY := 1.2727272728
const OX := H * ISO_SX + 60.0
const OY := 60.0
# ============ 밸런스 기본값 — 실제 수치는 balance.cfg가 덮어씀 (그쪽을 수정!) ============
var DAY_LEN := 28.0             # 하루 길이(초)
var START_FOOD := 150.0         # 시작 식량
var START_WOOD := 220.0         # 시작 목재
var START_IRON := 80.0          # 시작 철
var FREE_ARCHERS := 1           # 시작 무료 궁수 수
var CAM_SPEED := 1100.0         # WASD 카메라 이동 속도(px/초)
var WORKER_SPD := 70.0          # 일꾼 이동 속도
var WARN_TIME := 45.0           # 공세 예고 표시 시간(초)
var SPAWN_GAP := 0.12           # 일반 공세 스폰 간격(초)
var SPAWN_GAP_FINAL := 0.11     # 최종 공세 스폰 간격(초)
var ENEMY_HP_GROWTH := 0.14     # 공세 차수당 적 체력 증가율 (7%씩 누적)
var ENEMY_DMG_GROWTH := 0.08    # 공세 차수당 적 공격력 증가율
var ENEMY_COUNT_GROWTH := 0.05  # 공세 차수당 적 수 증가율
var LORD_AURA := 4.0            # 왜장 버프 반경(타일)
var LORD_DMG_BUFF := 1.5       # 왜장 버프: 주변 적 공격력 배율
var LORD_SPD_BUFF := 1.2        # 왜장 버프: 주변 적 이속 배율
var BOMBER_AOE := 1.5           # 폭탄병 폭발 반경(타일)
var BOMBER_DMG := 300.0          # 폭탄병 폭발 피해
var RES_BATK := 0.15            # 공방 연구: 건물 공격 +15%/Lv
var RES_BDEF := 0.20            # 공방 연구: 건물 피해감소 +20%/Lv
var RES_UATK := 0.15            # 공방 연구: 유닛 공격 +15%/Lv
var RES_UDEF := 0.12            # 공방 연구: 유닛 피해감소 +12%/Lv
var RES_MAX_LV := 10             # 연구 최대 레벨
var RES_COST_WOOD := 200         # 연구 기본 비용(목재) × (Lv+1)
var RES_COST_IRON := 140         # 연구 기본 비용(철) × (Lv+1)
var FLOAT_EVERY := 4.0          # 생산량 표시 주기(초)
var SPEAR_CLEAVE := 1.15        # 창병·갑사 근접 범위 공격 반경(타일)
var KEY_SELECT_ALL := KEY_F2    # 전군 선택 단축키 (KEY_F2, KEY_Q 등 Godot 키 상수)
var INTRO_LEN := 2.4            # 시작 연출(줌아웃+페이드인) 길이(초)
var LORD_SUMMON_CD := 5.0       # 왜장 강령술 주기(초)
var LORD_SUMMON_N := 30         # 왜장 강령술 소환 수(왜병)
var LORD_SUMMON_MAX := 4        # 왜장 1명당 강령술 최대 횟수(마력 소진)
var AOE_FALLOFF := 0.4         # 범위 공격 가장자리 감쇠율 (0.65 = 가장자리에서 35% 피해)
var HUNTER_HP_MIN := 60.0       # 편전수 대물 특효가 적용되는 적 최대체력 기준
var GAPSA_BLOCK_R := 16.0       # 갑사 길막 반경(px) — 적이 통과 못 함
var ENEMY_BUILD_BLOCK := 1.0    # 적이 이 거리(타일) 안에 있으면 건설 불가
var SPAWN_SPREAD := 0.11        # 스폰 산개 폭 (군집 주변, 클수록 넓게 퍼짐)
var EVENT_CHANCE := 0.1         # 공세 격퇴 후 랜덤 이벤트 발생 확률
var WORK_SFX_MAX := 3           # 생산 작업음 동시 재생 최대 개수 (중첩 소음 방지)
var WORK_SFX_VOL := -16.0       # 생산 작업음 볼륨(dB, 낮을수록 작음)
var APPROACH_SPREAD := 60.0     # 개체별 접근 오프셋(px) — 클수록 뭉치지 않음
var ENEMY_SEP := 13.0           # 적끼리 최소 간격(px) — 겹침·한방 전멸 방지
var ENRAGE_START := 45.0        # 공세 시작 후 이 시간(초) 지나면 광폭화 시작
var ENRAGE_RATE := 0.06         # 광폭화: 초당 남은 적 공격력 증가율 (누적)
var ENRAGE_SPD := 0.03          # 광폭화: 초당 이속 증가율 (누적)
# --- 런타임 상태(모디파이어·난이도가 갱신, 직접 수정 X) ---
var diff_mult := {"hp":1.0, "count":1.0, "dmg":1.0}   # 난이도 배율
var mod_flags := {}             # 활성 모디파이어 (refund_full, market_deal, ally_boost, ...)
var ENEMY_CAP := 900            # 동시 적 상한(성능 보호)
# =============================================================================

var BDEFS := {
	"hq":       {"name":"행궁",   "hp":1500, "size":2, "build":0.0},
	"wall":     {"name":"목책",   "hp":120,  "size":1, "build":2.0,  "cost":{"wood":5},              "desc":"목재 방책 — 석벽으로 개축 가능"},
	"wall2":    {"name":"석벽",   "hp":500,  "size":1, "build":4.0,  "cost":{"wood":8,"iron":6},     "desc":"중반 방어벽"},
	"wall3":    {"name":"철벽",   "hp":1000, "size":1, "build":5.0,  "cost":{"wood":10,"iron":22},   "desc":"후반 최종 방어벽"},
	"farm":     {"name":"농경지", "hp":120,  "size":2, "build":5.0,  "cost":{"wood":30},             "prod":{"food":2.0}, "desc":"식량 +2.0/초 · 2×2"},
	"lumber":   {"name":"벌목장", "hp":150,  "size":2, "build":6.0,  "cost":{"wood":40,"food":15},   "prod":{"wood":1.6}, "desc":"목재 +1.6/초 · 2×2"},
	"mine":     {"name":"철광",   "hp":110,  "size":1, "build":7.0,  "cost":{"wood":50,"food":25},   "prod":{"iron":0.6}, "desc":"철 +0.6/초 · 광맥 위에만 건설"},
	"house":    {"name":"민가",   "hp":130,  "size":2, "build":6.0,  "cost":{"wood":40},             "pop":8, "desc":"병력 상한 +8 · 2×2"},
	"barracks": {"name":"훈련소", "hp":260,  "size":2, "build":8.0,  "cost":{"wood":90,"iron":20},   "desc":"정예 병사(편전수·갑사) 해금 · 2×2"},
	"atower":   {"name":"궁수탑", "hp":260,  "size":1, "build":8.0,  "cost":{"wood":60,"iron":15},   "rng":5.0*TILE,  "dmg":9.0,  "cd":0.75, "desc":"단일 원거리 공격"},
	"ctower":   {"name":"총통탑", "hp":320,  "size":1, "build":10.0, "cost":{"wood":110,"iron":60},   "rng":6.5*TILE,  "dmg":30.0, "cd":2.4, "aoe":1.4*TILE, "desc":"천자총통 · 범위 폭발"},
	"market":   {"name":"저잣거리", "hp":180, "size":2, "build":6.0, "cost":{"wood":60,"iron":20}, "desc":"재화 환전(수수료 있음) · 2×2"},
	"btower":   {"name":"진천탑", "hp":550,  "size":1, "build":12.0, "cost":{"wood":220,"iron":260}, "rng":8.5*TILE, "dmg":300.0, "cd":3.0, "aoe":2.4*TILE, "desc":"비격진천뢰 — 후반 정예 처단 · 고가"},
	"smith":    {"name":"공방",   "hp":240,  "size":2, "build":8.0,  "cost":{"wood":100,"iron":120},  "desc":"연구: 건물/유닛 공·방 강화"},
}
var UPGR := {}
var UDEFS := {
	"archer": {"name":"궁수", "cost":{"food":25,"iron":8},  "hp":45.0,  "dmg":7.0,  "cd":0.7, "rng":4.5*TILE,  "spd":55.0},
	"spear":  {"name":"창병", "cost":{"food":35,"iron":12}, "hp":100.0, "dmg":11.0, "cd":1.0, "rng":0.95*TILE, "spd":62.0, "armor":0.25},
	"archer2": {"name":"편전수", "cost":{"food":250,"iron":80},  "hp":130.0, "dmg":30.0, "cd":0.5, "rng":5.6*TILE, "spd":58.0, "tier":2, "pop":2, "hunter":2.0},
	"spear2":  {"name":"갑사",   "cost":{"food":350,"iron":120}, "hp":420.0, "dmg":46.0, "cd":0.8, "rng":0.95*TILE, "spd":62.0, "tier":2, "pop":2, "armor":0.35},
}
var EDEFS := {
	"ashi": {"name":"왜병", "hp":16.0, "dmg":4.0, "cd":1.0, "rng":0.8*TILE, "spd":34.0, "r":5.0, "loot":{"food":1}, "corpse":Color("#6e2a1e")},
	"gun":  {"name":"조총병",   "hp":14.0, "dmg":5.0, "cd":1.6, "rng":3.2*TILE, "spd":34.0, "r":5.0, "loot":{"food":1,"iron":1}, "corpse":Color("#4e3057")},
	"sam":  {"name":"사무라이", "hp":70.0, "dmg":9.0, "cd":1.2, "rng":0.9*TILE, "spd":30.0, "r":8.0, "siege":2.0, "loot":{"food":3,"iron":1}, "corpse":Color("#3e0c0c")},
	"bomber": {"name":"폭탄병", "hp":22.0, "dmg":0.0, "cd":1.0, "rng":0.7*TILE, "spd":50.0, "r":5.5, "loot":{"iron":2}, "corpse":Color("#2e2622")},
	"lord": {"name":"왜장",   "hp":1200.0, "dmg":100.0, "cd":1.4, "rng":1.0*TILE, "spd":22.0, "r":9.0, "siege":2.0, "loot":{"food":10,"iron":6}, "corpse":Color("#301010")},
}
# TAB식 레벨링: 긴 초반 평화기 → 후반 기하급수 증가. 마지막은 사방 총공세.
var WAVES := [
	{"day":4,  "comp":{"ashi":18}},
	{"day":7,  "comp":{"ashi":30,"bomber":2}},
	{"day":10, "comp":{"ashi":42,"gun":10,"bomber":4}},
	{"day":13, "comp":{"ashi":56,"gun":18,"sam":4,"bomber":6}},
	{"day":16, "comp":{"ashi":60,"gun":22,"sam":8,"bomber":5}},
	{"day":19, "comp":{"ashi":78,"gun":30,"sam":12,"bomber":8,"lord":1}},
	{"day":22, "comp":{"ashi":95,"gun":38,"sam":18,"bomber":10,"lord":2}},
	{"day":26, "comp":{"ashi":250,"gun":106,"sam":46,"bomber":46,"lord":10}, "final":true},
]
var SIDE_NAME := {0:"북쪽", 1:"동쪽", 2:"남쪽", 3:"서쪽"}

var res := {"food":START_FOOD, "wood":START_WOOD, "iron":START_IRON}
var buildings := []
var units := []
var enemies := []
var workers := []
var workers_hidden := false
var projs := []
var spawn_q := []
var particles := []
var booms := []
var decals := []
var tmp_lights := []
var occ := []
var trees := []
var tile_tex := []
var tile_pos := []
var fog := PackedByteArray()
var fog_t := 0.0
var fog_lv := PackedFloat32Array()
var fog_dirty := true
var ore := PackedByteArray()
var mud := PackedByteArray()
var cliff := PackedByteArray()
var cliffs := []
var floats := []
var lords_cache := []
var gapsa_cache := []
var research := {"batk":0, "bdef":0, "uatk":0, "udef":0}
var RES_NAMES := {"batk":"건물 공격", "bdef":"건물 방어", "uatk":"유닛 공격", "udef":"유닛 방어"}
var res_btns := {}
var cost_items := []
var balance_warns := []
var intro_t := 0.0
var fade_rect: ColorRect
var amb_cur := 0.0
var hammer_t := 0.0
var warn_played := false
var work_sfx_n := 0
var wave_elapsed := 0.0
var enrage := 0.0
# 일꾼 도구 스윙 (한 사이클 = 치켜들기→내려치기→복귀)
var SWING_HZ := 1.45       # 초당 스윙 횟수
var SWING_DOWN := 0.30     # 사이클 중 내려치는 구간 비율(가속)
var SWING_HOLD := 0.12     # 타격 순간 멈칫하는 비율
var SWING_IDLE := 0.45     # 걸어다닐 때 도구를 든 위상(0~1)
var SWING_ANG_UP := -1.75  # 치켜든 각도(rad, 음수=위쪽)
var SWING_ANG_HIT := 0.30  # 내려친 각도(rad, 양수=아래쪽 — 지면을 찍는 느낌)
# 병사 모집 스폰 — 건물 풋프린트 앞쪽으로 내보내는 거리(px)
var SPAWN_FRONT := 26.0    # 건물 가장자리에서 더 앞으로
var SPAWN_SCATTER := 18.0  # 좌우 흩어짐 반경 (SPAWN_FRONT보다 작아야 가려지지 않음)
# 공사장 스프라이트 확대율: 크기 1칸 늘 때마다 이만큼 커진다 (1.0 = 크기와 정비례 = 너무 큼)
var SITE_GROW := 0.55
# 이동 명령 목표 인디케이터. 새 명령이 오면 교체, 전원 도착하면 null
# {"x","y","t"(경과초),"units"(명령받은 병사 배열)}
var move_marker = null
const EGRID_CELL := 160.0   # 적 공간 해시 셀 크기(px) — 조준 사거리 기준 튜닝됨
var enemy_grid := {}
var win_t := -1.0  # 승리 시네마틱 경과(초), -1 = 비활성
var restart_btn: Button
var restart_arm := 0.0
var settings_panel: PanelContainer
var trade_box: VBoxContainer
var endless := false
var endless_wave := 0
var difficulty := 1  # 0쉬움 1보통 2어려움
var diff_cycle_btn: Button
var chosen_mod := ""
var roll_mods := []
var MODS := {
	"none":       {"name":"평온한 출정", "desc":"특별한 조짐이 없다."},
	"refund_full":{"name":"검소한 목수", "desc":"철거 시 자원 100% 회수"},
	"market_deal":{"name":"보부상의 방문", "desc":"저잣거리 거래가 손해 없이 50→50 / 500→500"},
	"ally_boost": {"name":"의병의 사기", "desc":"아군 유닛 공격력 2배"},
	"horde_weak": {"name":"오합지졸", "desc":"적 수 2배, 그러나 피해 절반"},
	"rich_start": {"name":"조정의 하사품", "desc":"시작 자원 2배"},
	"cheap_wall": {"name":"석공 길드", "desc":"성벽 비용 절반"},
	"tough_foe":  {"name":"정예 왜군", "desc":"적 체력 1.4배, 대신 시작 자원 1.5배"},
}
var last_kill := Vector2.ZERO

var game_time := DAY_LEN * 0.35
var speed := 1.0
var paused := true
var game_started := false
var game_over := false
var wave_idx := 0
var shake := 0.0
var shake_off := Vector2.ZERO
var build_sel := ""
var hover := Vector2i(-99, -99)
var sel_units := []
var drag_box := Rect2()
var dragging := false
var drag_start := Vector2.ZERO
var hq = null
var kfont: Font
var cam: Camera2D
var mmb_down := false
var banner_t := 0.0
var logs := []

# UI 참조
var ui: CanvasLayer
var cmod: CanvasModulate
var lbl_food: Label
var lbl_wood: Label
var lbl_iron: Label
var lbl_pop: Label
var lbl_day: Label
var lbl_wave: Label
var banner_lbl: Label
var log_lbl: Label
var pause_btn: Button
var overlay: ColorRect
var btns := {}
var build_box: HBoxContainer
var def_box: HBoxContainer
var unit_box: HBoxContainer
var tab_btns := []
var sel_building = null
var up_panel: PanelContainer
var bot_bar: PanelContainer
var trade_btns := []   # [버튼, 주는재화, 받는재화, 수량, 받는수량_라벨]
var up_lbl: Label
var up_btn: Button
var mm_img: Image
var mm_tex: ImageTexture
var mm_view: Control
var mm_t := 0.0
var light_tex: GradientTexture2D
var TEX := {}
var TEXW := {}
var SFX := {}
var sfx_bus: Node
var ANCH := {"hq":Vector2(200,296),"wall":Vector2(72,152),"farm":Vector2(128,88),"lumber":Vector2(128,164),
	"mine":Vector2(72,96),"house":Vector2(125,157),"barracks":Vector2(128,200),"atower":Vector2(88,208),
	"ctower":Vector2(88,216),"site":Vector2(72,80),"tree":Vector2(56,128),"pine":Vector2(60,152),
	"u_worker":Vector2(32,72),"u_archer":Vector2(32,72),"u_spear":Vector2(32,72),
	"u_ashi":Vector2(32,72),"u_gun":Vector2(32,72),"u_sam":Vector2(40,88),
	"u_archer2":Vector2(32,72),"u_spear2":Vector2(32,72),
	"u_worker_farm":Vector2(32,72),"u_worker_lumber":Vector2(32,72),"u_worker_mine":Vector2(32,72),
	"tile_cliff":Vector2(56,76),"u_lord":Vector2(36,88),"u_bomber":Vector2(32,72),"smith":Vector2(72,128),"btower":Vector2(88,184),"market":Vector2(128,200),
	# 도구는 손잡이 끝(grip)이 앵커 — art_src/gen_tools.py의 GX,GY와 반드시 일치
	"tool_hammer":Vector2(5,12),"tool_hoe":Vector2(5,12),"tool_axe":Vector2(5,12),"tool_pick":Vector2(5,12)}

func _ready() -> void:
	randomize()
	_load_balance()
	_load_sfx()
	res = {"food":START_FOOD, "wood":START_WOOD, "iron":START_IRON}
	game_time = DAY_LEN * 0.35
	RenderingServer.set_default_clear_color(Color(0.055, 0.042, 0.028))
	var f := SystemFont.new()
	f.font_names = PackedStringArray(["Malgun Gothic", "맑은 고딕", "Apple SD Gothic Neo", "Noto Sans CJK KR", "Noto Sans KR", "NanumGothic"])
	kfont = f
	for y in GH:
		var row := []
		row.resize(GW)
		occ.append(row)
	_make_light_tex()
	for a in ["hq","farm","lumber","mine","house","barracks","atower","ctower","site","tree","pine","tile_g0","tile_g1","tile_g2","tile_dirt","tile_court","tile_ore","tile_mud","tile_cliff","u_worker","u_archer","u_spear","u_ashi","u_gun","u_sam","u_archer2","u_spear2","u_worker_farm","u_worker_lumber","u_worker_mine","u_lord","u_bomber","smith","btower","market","wall","wall2","wall3","icon_food","icon_wood","icon_iron","tool_hammer","tool_hoe","tool_axe","tool_pick"]:
		TEX[a] = load("res://art/%s.png" % a)
	ANCH["wall2"] = ANCH["wall"]
	ANCH["wall3"] = ANCH["wall"]
	cmod = CanvasModulate.new()
	add_child(cmod)
	_init_ground()
	_init_ore()
	_init_rough()
	hq = make_building("hq", int(GW / 2.0) - 1, int(GH / 2.0) - 1, true)
	for i in FREE_ARCHERS: # 무료 초기 병력
		units.append(_make_unit("archer", hq["x"] + randf_range(-35, 35), hq["y"] + 40 + randf_range(-8, 8)))
	_init_trees()
	WAVES[0]["side"] = randi() % 4
	cam = Camera2D.new()
	cam.position = iso(W / 2.0, H / 2.0)
	add_child(cam)
	cam.make_current()
	cam.zoom = Vector2(0.55, 0.55)
	_build_ui()
	# 완전한 블랙에서 타이틀 페이드인
	fade_rect.get_parent().move_child(fade_rect, fade_rect.get_parent().get_child_count() - 1)
	fade_rect.visible = true
	fade_rect.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(fade_rect, "modulate:a", 0.0, 1.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tw.tween_callback(func(): fade_rect.visible = false)
	_sfx("intro")
	log_msg("행궁을 지켜라. 첫 공세까지 경제를 구축하라. (휠/핀치: 줌, 휠클릭 드래그: 이동)")
	for wmsg in balance_warns:
		log_msg("⚠ balance.cfg: " + wmsg)
	if not balance_warns.is_empty():
		show_banner("balance.cfg 경고 %d건 — 좌하단 로그 확인" % balance_warns.size())

func _load_balance() -> void:
	# balance.cfg(사용자 전용 파일) 로드 — 실패/오타 시 기본값 + 경고
	var cf := ConfigFile.new()
	var err := cf.load("res://balance.cfg")
	if err != OK:
		balance_warns.append("balance.cfg 로드 실패(코드 %d) — 기본값으로 실행" % err)
		return
	var propnames := []
	for p in get_property_list():
		propnames.append(p["name"])
	for sec in cf.get_sections():
		if sec == "global":
			for k in cf.get_section_keys(sec):
				if k == "select_all_key":
					var kc := OS.find_keycode_from_string(str(cf.get_value(sec, k)))
					if kc != KEY_NONE:
						KEY_SELECT_ALL = kc
					else:
						balance_warns.append("[global] 알 수 없는 키 이름: %s" % str(cf.get_value(sec, k)))
				elif k in propnames:
					set(k, cf.get_value(sec, k))
				else:
					balance_warns.append("[global] 알 수 없는 항목: %s" % k)
		elif sec.begins_with("building_"):
			_apply_def(BDEFS, sec.substr(9), cf, sec)
		elif sec.begins_with("unit_"):
			_apply_def(UDEFS, sec.substr(5), cf, sec)
		elif sec.begins_with("enemy_"):
			_apply_def(EDEFS, sec.substr(6), cf, sec)
		elif sec.begins_with("wave_"):
			pass
		else:
			balance_warns.append("알 수 없는 섹션: [%s]" % sec)
	var new_waves := []
	var wi := 1
	while cf.has_section("wave_%d" % wi):
		var wsec := "wave_%d" % wi
		var w := {"day":int(cf.get_value(wsec, "day", 4)), "comp":{}}
		for k in cf.get_section_keys(wsec):
			if k == "day":
				continue
			if k == "final":
				if bool(cf.get_value(wsec, k)):
					w["final"] = true
			elif EDEFS.has(k):
				w["comp"][k] = int(cf.get_value(wsec, k))
			else:
				balance_warns.append("[%s] 알 수 없는 적 종류: %s" % [wsec, k])
		new_waves.append(w)
		wi += 1
	if not new_waves.is_empty():
		WAVES = new_waves

func _apply_def(defs: Dictionary, id: String, cf: ConfigFile, sec: String) -> void:
	if not defs.has(id):
		balance_warns.append("알 수 없는 대상: [%s]" % sec)
		return
	var d: Dictionary = defs[id]
	for k in cf.get_section_keys(sec):
		var v = cf.get_value(sec, k)
		if k.begins_with("cost_"):
			if not d.has("cost"):
				d["cost"] = {}
			d["cost"][k.substr(5)] = v
		elif k.begins_with("prod_"):
			if not d.has("prod"):
				d["prod"] = {}
			d["prod"][k.substr(5)] = v
		elif k.begins_with("loot_"):
			if not d.has("loot"):
				d["loot"] = {}
			d["loot"][k.substr(5)] = v
		elif k == "rng_tiles":
			d["rng"] = float(v) * TILE
		elif k == "aoe_tiles":
			d["aoe"] = float(v) * TILE
		elif k in ["hp", "dmg", "cd", "spd", "size", "build", "pop", "armor", "r", "name", "desc", "tier", "siege", "hunter"]:
			d[k] = v
		else:
			balance_warns.append("[%s] 알 수 없는 항목: %s" % [sec, k])

func _load_sfx() -> void:
	# res://sfx/<이름>.ogg / .wav 가 있으면 로드. 없으면 조용히 무시 (나중에 파일만 넣으면 됨)
	sfx_bus = Node.new()
	sfx_bus.name = "SfxBus"
	add_child(sfx_bus)
	var names := ["arrow", "cannon", "jincheon", "hit", "wall_break", "build",
		"wave_start", "summon", "bomber", "victory", "defeat", "select", "coin",
		"recruit", "hammer", "enemy_die", "ally_die", "move", "ally_attack",
		"enemy_attack", "event", "wave_warn", "deny", "menu", "intro", "gamestart",
		"hoe", "pick", "saw", "slash",
		"place_wall", "place_prod", "place_tower", "place_house",
		"place_farm", "place_lumber", "place_mine"]
	for n in names:
		for ext in [".ogg", ".wav"]:
			var path := "res://sfx/%s%s" % [n, ext]
			if ResourceLoader.exists(path):
				SFX[n] = load(path)
				break

func _sfx(n: String, vol := 0.0, wpos := Vector2.INF) -> void:
	# 사운드 파일이 있을 때만 재생 (경로만 잡아둔 상태에서도 안전)
	if not SFX.has(n) or sfx_bus == null:
		return
	if wpos != Vector2.INF and cam != null:
		# 화면 중심에서 멀수록 감쇠, 화면 밖이면 재생 안 함
		var scr := iso(wpos.x, wpos.y)
		var d := scr.distance_to(cam.position) * cam.zoom.x
		var reach: float = get_viewport_rect().size.length() * 0.5 + 120.0
		if d > reach:
			return
		var t: float = clampf(1.0 - d / reach, 0.0, 1.0)
		vol += linear_to_db(0.15 + 0.85 * t * t)
	var p := AudioStreamPlayer.new()
	p.stream = SFX[n]
	p.volume_db = vol
	sfx_bus.add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func _make_light_tex() -> void:
	var g := Gradient.new()
	g.set_color(0, Color(1, 1, 1, 1))
	g.set_color(1, Color(1, 1, 1, 0))
	light_tex = GradientTexture2D.new()
	light_tex.gradient = g
	light_tex.fill = GradientTexture2D.FILL_RADIAL
	light_tex.fill_from = Vector2(0.5, 0.5)
	light_tex.fill_to = Vector2(0.5, 0.0)
	light_tex.width = 256
	light_tex.height = 256

func iso(wx: float, wy: float) -> Vector2:
	return Vector2((wx - wy) * ISO_SX + OX, (wx + wy) * ISO_SY + OY)

func unproject(p: Vector2) -> Vector2:
	var sx := (p.x - OX) / ISO_SX
	var sy := (p.y - OY) / ISO_SY
	return Vector2((sy + sx) * 0.5, (sy - sx) * 0.5)

func screen_to_canvas(p: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * p

func _vs_half() -> Vector2:
	var ct := get_canvas_transform()
	return ct.origin + cam.position * ct.get_scale()

func _clamp_cam() -> void:
	cam.position.x = clampf(cam.position.x, 460.0, OX + W * ISO_SX - 460.0)
	cam.position.y = clampf(cam.position.y, 260.0, OY + (W + H) * ISO_SY - 260.0)

func _zoom(spos: Vector2, f: float) -> void:
	var vs2 := _vs_half()
	var before := (spos - vs2) / cam.zoom.x + cam.position
	var z: float = clampf(cam.zoom.x * f, 0.18, 1.6)
	cam.zoom = Vector2(z, z)
	var after := (spos - vs2) / z + cam.position
	cam.position += before - after
	_clamp_cam()

func ambient_level() -> float:
	# 공세 상태 연동: 평시=낮 · 예고 중=어스름 · 러시 중=밤
	return amb_cur

func _ambient_target() -> float:
	if not enemies.is_empty() or not spawn_q.is_empty():
		return 0.52
	var w = next_wave()
	if w != null and not w.has("started"):
		var remain: float = float(w["day"]) * DAY_LEN - DAY_LEN - game_time
		if remain < WARN_TIME and remain > 0.0:
			if not warn_played:
				warn_played = true
				_sfx("wave_warn")
			return 0.30 * (1.0 - remain / WARN_TIME) + 0.08
	warn_played = false
	return 0.0

func cur_day() -> int:
	return int(game_time / DAY_LEN) + 1

func next_wave():
	return WAVES[wave_idx] if wave_idx < WAVES.size() else null

func add_res(o: Dictionary) -> void:
	for k in o:
		res[k] += o[k]

func can_afford(c: Dictionary) -> bool:
	for k in c:
		if res[k] < c[k]:
			return false
	return true

func pay(c: Dictionary) -> void:
	for k in c:
		res[k] -= c[k]

func pop_max() -> int:
	var n := 6
	for b in buildings:
		if b["build"] <= 0.0 and BDEFS[b["type"]].has("pop"):
			n += BDEFS[b["type"]]["pop"]
	return n

func has_market() -> bool:
	for b in buildings:
		if b["type"] == "market" and b["build"] <= 0.0:
			return true
	return false

func _trade(src: String, dst: String, give_n := 50) -> void:
	var get_n: int = give_n if mod_flags.get("market_deal", false) else int(give_n * 0.6)
	if res[src] < give_n:
		log_msg("%s이(가) 부족합니다." % {"food":"식량","wood":"목재","iron":"철"}[src])
		return
	res[src] -= give_n
	res[dst] += get_n
	_sfx("coin")

func pop_used() -> int:
	var n := 0
	for u in units:
		n += int(UDEFS[u["type"]].get("pop", 1))
	return n

func has_smith() -> bool:
	for b in buildings:
		if b["type"] == "smith" and b["build"] <= 0.0:
			return true
	return false

func has_barracks() -> bool:
	for b in buildings:
		if b["type"] == "barracks" and b["build"] <= 0.0:
			return true
	return false

func wdist(ax: float, ay: float, bx: float, by: float) -> float:
	return Vector2(ax - bx, ay - by).length()

# ---------- 지형/나무 ----------
func _init_ground() -> void:
	fog.resize(GW * GH)
	for gy in GH:
		for gx in GW:
			var cx := (gx + 0.5) * TILE
			var cy := (gy + 0.5) * TILE
			var k := "tile_g%d" % (randi() % 3)
			var dc := wdist(cx, cy, W / 2.0, H / 2.0)
			if dc < 100.0:
				k = "tile_court"
			elif absf(cx - W / 2.0) < 13.0 or absf(cy - H / 2.0) < 13.0:
				k = "tile_dirt"
			tile_tex.append(k)
			tile_pos.append(iso(gx * TILE, gy * TILE) - Vector2(56.0, 0.0))

func _init_ore() -> void:
	# 철 광맥 군집 7개 — 첫 군집은 행궁 초기 시야권, 나머지는 탐사 필요
	ore.resize(GW * GH)
	var centers: Array = []
	var tries := 0
	while centers.size() < 9 and tries < 700:
		tries += 1
		var gx := 3 + randi() % (GW - 6)
		var gy := 3 + randi() % (GH - 6)
		var dc := wdist((gx + 0.5) * TILE, (gy + 0.5) * TILE, W / 2.0, H / 2.0)
		if centers.is_empty():
			if dc < 170.0 or dc > 260.0:
				continue
		elif dc < 200.0:
			continue
		var far_ok := true
		for c in centers:
			var cc: Vector2i = c
			if Vector2(cc - Vector2i(gx, gy)).length() < 8.0:
				far_ok = false
				break
		if not far_ok:
			continue
		centers.append(Vector2i(gx, gy))
		var want := 4 + randi() % 3
		var placed := 0
		var t2 := 0
		while placed < want and t2 < 40:
			t2 += 1
			var ox := gx + randi() % 3 - 1
			var oy := gy + randi() % 3 - 1
			if ox < 1 or oy < 1 or ox >= GW - 1 or oy >= GH - 1:
				continue
			var idx := oy * GW + ox
			if ore[idx] == 1 or tile_tex[idx] == "tile_court":
				continue
			ore[idx] = 1
			tile_tex[idx] = "tile_ore"
			placed += 1

func _init_rough() -> void:
	# 절벽(이동·건설 불가) 6군집 + 진흙(건설 불가) 7웅덩이
	cliff.resize(GW * GH)
	mud.resize(GW * GH)
	var placed := 0
	var tries := 0
	while placed < 8 and tries < 500:
		tries += 1
		var gx := 4 + randi() % (GW - 8)
		var gy := 4 + randi() % (GH - 8)
		if wdist((gx + 0.5) * TILE, (gy + 0.5) * TILE, W / 2.0, H / 2.0) < 280.0:
			continue
		var want := 3 + randi() % 5
		var done := 0
		var t2 := 0
		while done < want and t2 < 40:
			t2 += 1
			var ox := gx + randi() % 3 - 1
			var oy := gy + randi() % 3 - 1
			if ox < 1 or oy < 1 or ox >= GW - 1 or oy >= GH - 1:
				continue
			var idx := oy * GW + ox
			if cliff[idx] == 1 or ore[idx] == 1 or tile_tex[idx] == "tile_court":
				continue
			cliff[idx] = 1
			tile_tex[idx] = "tile_dirt"
			cliffs.append(Vector2((ox + 0.5) * TILE, (oy + 0.5) * TILE))
			done += 1
		placed += 1
	placed = 0
	tries = 0
	while placed < 9 and tries < 500:
		tries += 1
		var gx := 3 + randi() % (GW - 6)
		var gy := 3 + randi() % (GH - 6)
		if wdist((gx + 0.5) * TILE, (gy + 0.5) * TILE, W / 2.0, H / 2.0) < 190.0:
			continue
		var want := 4 + randi() % 5
		var done := 0
		var t2 := 0
		while done < want and t2 < 50:
			t2 += 1
			var ox := gx + randi() % 4 - 1
			var oy := gy + randi() % 3 - 1
			if ox < 1 or oy < 1 or ox >= GW - 1 or oy >= GH - 1:
				continue
			var idx := oy * GW + ox
			if cliff[idx] == 1 or mud[idx] == 1 or ore[idx] == 1 or tile_tex[idx] == "tile_court":
				continue
			mud[idx] = 1
			tile_tex[idx] = "tile_mud"
			done += 1
		placed += 1

func _init_trees() -> void:
	for c in 32:
		var cx := randf() * W
		var cy := randf() * H
		if wdist(cx, cy, hq["x"], hq["y"]) < 200.0:
			continue
		for i in 4 + randi() % 8:
			var x := cx + randf_range(-45, 45)
			var y := cy + randf_range(-32, 32)
			if x < 12.0 or y < 12.0 or x > W - 12.0 or y > H - 12.0:
				continue
			if wdist(x, y, hq["x"], hq["y"]) < 150.0:
				continue
			var ti := int(y / TILE) * GW + int(x / TILE)
			if ore[ti] == 1 or cliff[ti] == 1 or mud[ti] == 1:
				continue
			trees.append({"x":x, "y":y, "s":randf_range(0.7, 1.25), "pine":randf() < 0.45})
	for i in 70:
		var x := randf_range(15, W - 15)
		var y := randf_range(15, H - 15)
		var ti2 := int(y / TILE) * GW + int(x / TILE)
		if wdist(x, y, hq["x"], hq["y"]) > 160.0 and ore[ti2] == 0 and cliff[ti2] == 0 and mud[ti2] == 0:
			trees.append({"x":x, "y":y, "s":randf_range(0.7, 1.2), "pine":randf() < 0.4})

# ---------- 건물 ----------
func make_building(type: String, gx: int, gy: int, instant := false):
	var d: Dictionary = BDEFS[type]
	var s: int = d["size"]
	var bt: float = 0.0 if instant else d["build"]
	var b := {"type":type, "gx":gx, "gy":gy, "size":s, "hp":(d["hp"] if bt <= 0.0 else d["hp"] * 0.5),
		"maxhp":d["hp"], "cd":0.0, "flash":0.0, "ph":randf() * TAU, "st":randf_range(0.0, 2.0),
		"build":bt, "build_max":max(bt, 0.001), "light":null,
		"is_wall":(type == "wall" or type == "wall2" or type == "wall3"),
		"x":(gx + s / 2.0) * TILE, "y":(gy + s / 2.0) * TILE}
	buildings.append(b)
	for j in s:
		for i in s:
			occ[gy + j][gx + i] = b
	var rv := 7
	if type == "hq":
		rv = 13
	elif type == "atower" or type == "ctower" or type == "btower":
		rv = 10
	reveal(b["x"], b["y"], rv)
	if bt <= 0.0:
		finish_building(b)
	elif not _is_defense_building(type):
		_spawn_workers_for(b)
	return b

func finish_building(b: Dictionary) -> void:
	b["build"] = 0.0
	b["hp"] = b["maxhp"]
	var t: String = b["type"]
	if t in ["hq", "atower", "ctower", "barracks", "house"]:
		var l := PointLight2D.new()
		l.texture = light_tex
		l.color = Color(1.0, 0.78, 0.45)
		l.energy = 0.0
		var r := 380.0
		if t == "hq": r = 600.0
		elif t == "house": r = 220.0
		elif t == "barracks": r = 300.0
		l.texture_scale = r / 128.0
		l.position = iso(b["x"], b["y"]) + Vector2(0, -24)
		add_child(l)
		b["light"] = l
	_sfx("build", 0.0, Vector2(b["x"], b["y"]))
	# 생산 건물에는 상주 일꾼
	if t in ["farm", "lumber", "mine"]:
		workers.append(_make_worker(b, t))

func remove_building(b: Dictionary) -> void:
	for j in b["size"]:
		for i in b["size"]:
			occ[b["gy"] + j][b["gx"] + i] = null
	buildings.erase(b)
	if b["light"] != null:
		b["light"].queue_free()
		b["light"] = null
	for i in range(workers.size() - 1, -1, -1):
		if workers[i]["home"] == b:
			workers.remove_at(i)
	var bs: int = b["size"]
	_sfx("wall_break", 0.0, Vector2(b["x"], b["y"]))
	p_dust(b["x"], b["y"], 10 + bs * 10)
	p_smoke(b["x"], b["y"], 4 + bs * 5)
	p_spark(b["x"], b["y"], 7)
	booms.append({"x":b["x"], "y":b["y"], "r":3.0, "max":(0.9 + 0.5 * bs) * TILE, "life":0.28})
	add_decal(b["x"], b["y"], "scorch", Color.BLACK)
	add_tmp_light(b["x"], b["y"], 260.0, 0.25, 0.7)
	shake = minf(shake + 2.0 + bs * 1.5, 10.0)
	if b["type"] == "hq":
		defeat()

func can_place(type: String, gx: int, gy: int) -> bool:
	var s: int = BDEFS[type]["size"]
	if gx < 1 or gy < 1 or gx + s > GW - 1 or gy + s > GH - 1:
		return false
	# 적이 가까우면 건설 불가 (전투 중 즉석 성벽 방지)
	if nearest_enemy((gx + s / 2.0) * TILE, (gy + s / 2.0) * TILE, ENEMY_BUILD_BLOCK * TILE) != null:
		return false
	# 행궁 주변 1타일은 건설 불가
	if hq != null:
		if gx + s - 1 >= int(hq["gx"]) - 1 and gx <= int(hq["gx"]) + int(hq["size"]) \
				and gy + s - 1 >= int(hq["gy"]) - 1 and gy <= int(hq["gy"]) + int(hq["size"]):
			return false
	for j in s:
		for i in s:
			if occ[gy + j][gx + i] != null:
				return false
			var idx := (gy + j) * GW + gx + i
			if fog[idx] == 0:
				return false
			if cliff[idx] == 1 or mud[idx] == 1:
				return false
			if type == "mine":
				if ore[idx] == 0:
					return false
			elif ore[idx] == 1:
				return false
	return true

func reveal(wx: float, wy: float, r_tiles: int) -> void:
	var cgx := int(wx / TILE)
	var cgy := int(wy / TILE)
	for gy in range(max(0, cgy - r_tiles), min(GH, cgy + r_tiles + 1)):
		for gx in range(max(0, cgx - r_tiles), min(GW, cgx + r_tiles + 1)):
			if (gx - cgx) * (gx - cgx) + (gy - cgy) * (gy - cgy) <= r_tiles * r_tiles:
				fog[gy * GW + gx] = 1
	fog_dirty = true

func tile_visible(wx: float, wy: float) -> bool:
	var gx := int(wx / TILE)
	var gy := int(wy / TILE)
	if gx < 0 or gy < 0 or gx >= GW or gy >= GH:
		return false
	return fog[gy * GW + gx] == 1

func occ_at(px: float, py: float):
	var gx := int(floor(px / TILE))
	var gy := int(floor(py / TILE))
	if gx < 0 or gy < 0 or gx >= GW or gy >= GH:
		return null
	return occ[gy][gx]

func _wall_at(px: float, py: float) -> bool:
	# 문자열 비교 대신 생성 시 계산해둔 플래그를 본다 (이동 판정에서 초당 수만 번 호출됨)
	var gx := int(floor(px / TILE))
	var gy := int(floor(py / TILE))
	if gx < 0 or gy < 0 or gx >= GW or gy >= GH:
		return false
	var b = occ[gy][gx]
	return b != null and b.get("is_wall", false)

func _is_defense_building(t: String) -> bool:
	return t in ["wall", "wall2", "wall3", "atower", "ctower", "btower"]

func _terra_blocked(px: float, py: float) -> bool:
	var gx := int(floor(px / TILE))
	var gy := int(floor(py / TILE))
	if gx < 0 or gy < 0 or gx >= GW or gy >= GH:
		return false
	return cliff[gy * GW + gx] == 1

func _blocked(px: float, py: float) -> bool:
	# 아군 이동 차단: 절벽 + 목책/석벽 (성문은 통과)
	return _terra_blocked(px, py) or _wall_at(px, py)

func _pass_blocked(px: float, py: float, bw: bool, foe := false) -> bool:
	if _terra_blocked(px, py):
		return true
	if foe:
		# 갑사 길막: 적은 갑사를 통과하지 못함
		for g in gapsa_cache:
			if wdist(px, py, g["x"], g["y"]) < GAPSA_BLOCK_R:
				return true
	return bw and _wall_at(px, py)

func _recalc_fog_lv() -> void:
	# 탐사 경계 페이드: 미탐사=1.0, 인접(8방/맵끝)=0.55, 그 다음 링=0.25
	fog_dirty = false
	if fog_lv.size() != GW * GH:
		fog_lv.resize(GW * GH)
	for gy in GH:
		for gx in GW:
			var i := gy * GW + gx
			if fog[i] == 0:
				fog_lv[i] = 1.0
				continue
			var edge := false
			for oy in range(gy - 1, gy + 2):
				for ox in range(gx - 1, gx + 2):
					if ox < 0 or oy < 0 or ox >= GW or oy >= GH or fog[oy * GW + ox] == 0:
						edge = true
						break
				if edge:
					break
			fog_lv[i] = 0.55 if edge else 0.0
	for gy in GH:
		for gx in GW:
			var i := gy * GW + gx
			if fog_lv[i] != 0.0:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = gx + d.x
				var ny: int = gy + d.y
				if nx >= 0 and ny >= 0 and nx < GW and ny < GH and fog_lv[ny * GW + nx] > 0.4 and fog_lv[ny * GW + nx] < 0.9:
					fog_lv[i] = 0.25
					break

# ---------- 일꾼 ----------
func _make_worker(home: Dictionary, task: String) -> Dictionary:
	return {"x":hq["x"], "y":hq["y"] + 26.0, "home":home, "task":task,
		"state":"walk", "ph":randf() * TAU, "wt":randf_range(0.5, 2.0),
		"tx":home["x"] + randf_range(-8, 8), "ty":home["y"] + randf_range(4, 10), "fx":1.0}

func _spawn_workers_for(b: Dictionary) -> void:
	var n := 2 if b["build_max"] > 5.0 else 1
	for i in n:
		workers.append(_make_worker(b, "build"))

func _set_workers_hidden(v: bool) -> void:
	if workers_hidden == v:
		return
	workers_hidden = v
	if v:
		for wk in workers:
			wk["state"] = "walk"
			wk["tx"] = hq["x"] + randf_range(-20, 20)
			wk["ty"] = hq["y"] + 30.0
	else:
		for wk in workers:
			var home: Dictionary = wk["home"]
			wk["x"] = hq["x"] + randf_range(-18, 18)
			wk["y"] = hq["y"] + 30.0 + randf_range(-6, 6)
			wk["state"] = "walk"
			wk["tx"] = home["x"] + randf_range(-9, 9)
			wk["ty"] = home["y"] + randf_range(3, 12)
			wk["fx"] = 1.0 if wk["tx"] > wk["x"] else -1.0

func _update_workers(dt: float) -> void:
	work_sfx_n = 0
	for i in range(workers.size() - 1, -1, -1):
		var wk: Dictionary = workers[i]
		var home: Dictionary = wk["home"]
		if wk["state"] == "walk":
			var d := wdist(wk["x"], wk["y"], wk["tx"], wk["ty"])
			if d < 3.0:
				wk["state"] = "work"
			else:
				_move(wk, wk["tx"], wk["ty"], WORKER_SPD * dt, false)
				wk["fx"] = 1.0 if wk["tx"] > wk["x"] else -1.0
		elif wk["state"] == "work":
			# 건설 완료된 일꾼은 귀환
			if wk["task"] == "build" and home["build"] <= 0.0:
				wk["state"] = "return"
				wk["tx"] = hq["x"] + randf_range(-20, 20)
				wk["ty"] = hq["y"] + 30.0
				continue
			# 작업 사운드 (task별, 주기적)
			wk["st2"] = float(wk.get("st2", randf_range(0.3, 1.0))) - dt
			if float(wk["st2"]) <= 0.0:
				wk["st2"] = randf_range(0.7, 1.3)
				var wsnd := ""
				if wk["task"] == "farm":
					wsnd = "hoe"
				elif wk["task"] == "mine":
					wsnd = "pick"
				elif wk["task"] == "lumber":
					wsnd = "saw"
				if wsnd != "" and work_sfx_n < WORK_SFX_MAX:
					work_sfx_n += 1
					_sfx(wsnd, WORK_SFX_VOL, Vector2(wk["x"], wk["y"]))
			wk["wt"] -= dt
			if wk["wt"] <= 0.0:
				wk["wt"] = randf_range(1.5, 3.5)
				# 작업 지점 재배치 (밭 이랑 사이, 벌목장 주변 등)
				wk["state"] = "walk"
				wk["tx"] = home["x"] + randf_range(-9, 9)
				wk["ty"] = home["y"] + randf_range(3, 12)
		else: # return
			var d2 := wdist(wk["x"], wk["y"], wk["tx"], wk["ty"])
			if d2 < 6.0:
				workers.remove_at(i)
				continue
			_move(wk, wk["tx"], wk["ty"], WORKER_SPD * dt, false)
			wk["fx"] = 1.0 if wk["tx"] > wk["x"] else -1.0

# ---------- 병사/적 생성 ----------
func _make_unit(t: String, x: float, y: float) -> Dictionary:
	var d: Dictionary = UDEFS[t]
	return {"type":t, "x":x, "y":y, "hp":d["hp"], "maxhp":d["hp"], "cd":0.0,
		"ox":x, "oy":y, "flash":0.0, "ph":randf() * TAU, "moving":false, "fx":1.0, "mv":false, "atk_t":0.0}

func _place_snd(t: String) -> String:
	if t in ["wall", "wall2", "wall3"]:
		return "place_wall"
	elif t in ["atower", "ctower", "btower"]:
		return "place_tower"
	elif t in ["house", "barracks"]:
		return "place_house"
	elif t == "farm":
		return "place_farm"
	elif t == "lumber":
		return "place_lumber"
	elif t == "mine":
		return "place_mine"
	return "place_prod"  # 시장 등 기타

func _clear_temp_mods() -> void:
	for k in ["ally_dmg", "enemy_hp", "enemy_dmg", "enemy_count"]:
		mod_flags.erase(k)

func _roll_event() -> void:
	_sfx("event")
	# 난이도 조절된 이벤트 풀 — 좋은 것/나쁜 것 섞임, 후반일수록 규모 커짐
	var pool := ["reinforce", "reinforce", "grant", "market_deal", "uprising", "rabble", "elite_foe", "refund"]
	var pick: String = pool[randi() % pool.size()]
	match pick:
		"reinforce":
			var n: int = 2 + wave_idx / 2
			for i in n:
				units.append(_make_unit("archer", hq["x"] + randf_range(-40, 40), hq["y"] + 40 + randf_range(-10, 10)))
			_sfx("build")
			show_banner("의병 합류! 궁수 %d명이 성에 들어왔다" % n)
			log_msg("[이벤트] 의병 %d명 합류" % n)
		"grant":
			var g := {"food":40 + wave_idx * 15, "wood":50 + wave_idx * 15, "iron":20 + wave_idx * 8}
			add_res(g)
			_sfx("coin")
			show_banner("조정의 하사품이 도착했다!")
			log_msg("[이벤트] 하사품: %s" % _cost_str(g))
		"market_deal":
			mod_flags["market_deal"] = true
			show_banner("보부상 방문 — 저잣거리 거래가 특가로!")
			log_msg("[이벤트] 보부상: 다음 공세까지 거래 50→50 / 500→500")
		"refund":
			mod_flags["refund_full"] = true
			show_banner("검소한 목수 — 철거 시 자원 전액 회수!")
			log_msg("[이벤트] 철거 100% 회수 (이후 계속)")
		"uprising":
			mod_flags["ally_dmg"] = 2.0
			show_banner("의병의 사기 충천! 다음 공세 아군 공격 2배")
			log_msg("[이벤트] 아군 공격 2배 (다음 공세 한정)")
		"rabble":
			mod_flags["enemy_count"] = 1.8
			mod_flags["enemy_dmg"] = 0.5
			show_banner("오합지졸 — 왜군이 두 배로 몰려오나 약하다!")
			log_msg("[이벤트] 다음 공세: 적 수 1.8배 · 피해 0.5배")
		"elite_foe":
			mod_flags["enemy_hp"] = 1.5
			add_res({"iron":40 + wave_idx * 10})
			show_banner("정예 왜군 출진 경보! (대신 철을 비축했다)")
			log_msg("[이벤트] 다음 공세: 적 체력 1.5배 · 철 지급")

func recruit(t: String) -> void:
	var d: Dictionary = UDEFS[t]
	var tier2: bool = d.has("tier")
	if tier2 and not has_barracks():
		log_msg("훈련소가 필요합니다.")
		return
	if pop_used() + int(d.get("pop", 1)) > pop_max():
		log_msg("병력 상한 도달 (%d/%d) — 민가를 지으십시오. (정예는 인구 2)" % [pop_used(), pop_max()])
		_sfx("deny")
		show_banner("인구 상한! 민가를 지어 상한을 늘리세요 (%d/%d)" % [pop_used(), pop_max()])
		return
	if not can_afford(d["cost"]):
		_sfx("deny")
		log_msg("자원이 부족합니다.")
		return
	pay(d["cost"])
	# 궁수/창병은 행궁에서, 정예는 훈련소에서 모집
	var bar = hq
	if tier2:
		for b in buildings:
			if b["build"] <= 0.0 and b["type"] == "barracks":
				bar = b
				break
	# 건물 정면(월드 x+y가 커지는 쪽) 아래에 스폰.
	# 깊이 정렬 키가 x+y라서, 흩어짐 반경보다 앞으로 더 내보내야 건물에 가려지지 않는다.
	var a := randf() * TAU
	var sz: float = float(bar["size"]) * TILE * 0.5
	var sx: float = bar["x"] + cos(a) * SPAWN_SCATTER
	var sy: float = bar["y"] + sz + SPAWN_FRONT + sin(a) * (SPAWN_SCATTER * 0.45)
	units.append(_make_unit(t, sx, sy))
	_sfx("recruit")

func start_wave(w: Dictionary) -> void:
	var sides: Array = [0, 1, 2, 3] if w.has("final") else [int(w["side"])]
	var delay := 0.0
	var cmult := 1.0 + ENEMY_COUNT_GROWTH * wave_idx
	# 측면당 군집 지점 3~5개 + 넓은 산개 (일렬 방지)
	var clusters := {}
	for sd in sides:
		var arr := []
		for i in 3 + randi() % 3:
			arr.append(randf_range(0.08, 0.92))
		clusters[sd] = arr
	for type in w["comp"]:
		for i in int(ceil(int(w["comp"][type]) * cmult)):
			var sd2: int = sides[randi() % sides.size()]
			var carr: Array = clusters[sd2]
			var fr: float = float(carr[randi() % carr.size()]) + randf_range(-SPAWN_SPREAD, SPAWN_SPREAD)
			spawn_q.append({"type":type, "side":sd2, "t":delay, "fr":clampf(fr, 0.02, 0.98)})
			delay += SPAWN_GAP_FINAL if w.has("final") else SPAWN_GAP
	var sname: String = "사방" if w.has("final") else SIDE_NAME[int(w["side"])]
	_sfx("wave_start")
	_set_workers_hidden(true)
	show_banner("왜군 총공세다! 전군 배치하라!" if w.has("final") else "제%d차 공세 — %s에서 %s" % [wave_idx + 1, sname, wave_comp_str(w)])
	log_msg("제%d차 공세 시작 (%s)" % [wave_idx + 1, sname])

func spawn_enemy(type: String, side: int, fr := -1.0) -> void:
	var d: Dictionary = EDEFS[type]
	if fr < 0.0:
		fr = randf()
	var dp := 10.0 + randf() * 34.0
	var x: float
	var y: float
	match side:
		0: x = fr * W; y = -dp
		1: x = W + dp; y = fr * H
		2: x = fr * W; y = H + dp
		_: x = -dp; y = fr * H
	var hpm := (1.0 + ENEMY_HP_GROWTH * wave_idx) * float(diff_mult["hp"]) * float(mod_flags.get("enemy_hp", 1.0))
	var dmm := (1.0 + ENEMY_DMG_GROWTH * wave_idx) * float(diff_mult["dmg"]) * float(mod_flags.get("enemy_dmg", 1.0))
	enemies.append({"type":type, "x":x, "y":y, "hp":d["hp"] * hpm, "maxhp":d["hp"] * hpm,
		"dmg":float(d["dmg"]) * dmm, "cd":0.0, "atk_t":0.0,
		"tox":randf_range(-APPROACH_SPREAD, APPROACH_SPREAD), "toy":randf_range(-APPROACH_SPREAD, APPROACH_SPREAD),
		"target":null, "rt":0.0, "flash":0.0, "ph":randf() * TAU, "moving":true,
		"fx":-1.0 if x > W / 2.0 else 1.0})

func _lord_summon(lord: Dictionary) -> void:
	# 강령술: 왜장 주변 원형으로 왜병 소환
	if enemies.size() >= ENEMY_CAP:
		return
	var hpm := 1.0 + ENEMY_HP_GROWTH * wave_idx
	var dmm := 1.0 + ENEMY_DMG_GROWTH * wave_idx
	var d: Dictionary = EDEFS["ashi"]
	var n: int = mini(LORD_SUMMON_N, ENEMY_CAP - enemies.size())
	for i in n:
		var a := randf() * TAU
		var r := randf_range(0.6, 2.4) * TILE
		var x: float = clampf(lord["x"] + cos(a) * r, 8.0, W - 8.0)
		var y: float = clampf(lord["y"] + sin(a) * r, 8.0, H - 8.0)
		enemies.append({"type":"ashi", "x":x, "y":y, "hp":d["hp"] * hpm, "maxhp":d["hp"] * hpm,
			"dmg":float(d["dmg"]) * dmm, "cd":randf_range(0.2, 1.0), "atk_t":0.0, "flash":0.18,
			"tox":randf_range(-34.0, 34.0), "toy":randf_range(-34.0, 34.0),
			"target":null, "rt":0.0, "ph":randf() * TAU, "moving":true,
			"fx":-1.0 if x > W / 2.0 else 1.0})
	# 연출: 어두운 기운 링 + 연기 + 광원
	_sfx("summon", 0.0, Vector2(lord["x"], lord["y"]))
	booms.append({"x":lord["x"], "y":lord["y"], "r":6.0, "max":2.6 * TILE, "life":0.4})
	p_smoke(lord["x"], lord["y"], 10)
	add_tmp_light(lord["x"], lord["y"], 380.0, 0.4, 0.8)

func nearest_unit(x: float, y: float, rad: float):
	var best = null
	var bd := rad
	for u in units:
		var d := wdist(x, y, u["x"], u["y"])
		if d < bd:
			bd = d
			best = u
	return best

func nearest_building(x: float, y: float, rad: float):
	var best = null
	var bd := rad
	for b in buildings:
		var d: float = wdist(x, y, b["x"], b["y"]) - (b["size"] - 1) * TILE * 0.5
		if d < bd:
			bd = d
			best = b
	return best

# ---------- 적 공간 해시 ----------
# 매 sim 틱 한 번만 만들고, 타워·병사 조준과 광역 판정이 함께 쓴다.
# 죽은 적(hp<=0)은 격자에 남아 있을 수 있으므로 조회할 때 걸러낸다.
# 명령받은 병사가 전원 도착(또는 사망/명령취소)하면 인디케이터 제거
func _update_move_marker(dt: float) -> void:
	if move_marker == null:
		return
	move_marker["t"] = float(move_marker["t"]) + dt
	for u in move_marker["units"]:
		if u.get("mv", false) and u["hp"] > 0.0 and units.has(u):
			return
	move_marker = null

func _build_enemy_grid() -> void:
	enemy_grid.clear()
	for e in enemies:
		var k := Vector2i(int(floor(e["x"] / EGRID_CELL)), int(floor(e["y"] / EGRID_CELL)))
		var bucket = enemy_grid.get(k)
		if bucket == null:
			enemy_grid[k] = [e]
		else:
			bucket.append(e)

func _egrid_span(x: float, y: float, rad: float) -> Array:
	var cr := int(ceil(rad / EGRID_CELL))
	return [int(floor(x / EGRID_CELL)) - cr, int(floor(y / EGRID_CELL)) - cr, cr * 2 + 1]

# 반경 안의 살아있는 적을 새 배열로 반환 — 순회 중 damage_enemy가 enemies를 건드려도 안전
func enemies_near(x: float, y: float, rad: float) -> Array:
	var out := []
	if enemies.is_empty():
		return out
	if enemy_grid.is_empty():
		_build_enemy_grid()
	var sp := _egrid_span(x, y, rad)
	var n: int = sp[2]
	for oy in range(sp[1], sp[1] + n):
		for ox in range(sp[0], sp[0] + n):
			var k := Vector2i(ox, oy)
			if not enemy_grid.has(k):
				continue
			for e in enemy_grid[k]:
				if e["hp"] <= 0.0:
					continue
				if wdist(x, y, e["x"], e["y"]) <= rad:
					out.append(e)
	return out

func nearest_enemy(x: float, y: float, rad: float):
	if enemies.is_empty():
		return null
	if enemy_grid.is_empty():
		_build_enemy_grid()
	var best = null
	var bd := rad
	var sp := _egrid_span(x, y, rad)
	var n: int = sp[2]
	for oy in range(sp[1], sp[1] + n):
		for ox in range(sp[0], sp[0] + n):
			var k := Vector2i(ox, oy)
			if not enemy_grid.has(k):
				continue
			for e in enemy_grid[k]:
				if e["hp"] <= 0.0:
					continue
				var d := wdist(x, y, e["x"], e["y"])
				if d < bd:
					bd = d
					best = e
	return best

# ---------- 파티클/데칼 (파티클은 화면좌표) ----------
func p_add(sp: Vector2, vx: float, vy: float, g: float, r: float, life: float, col: Color, gr := 0.0) -> void:
	particles.append({"x":sp.x, "y":sp.y, "vx":vx, "vy":vy, "g":g, "r":r, "gr":gr, "life":life, "max":life, "col":col})

func p_blood(wx: float, wy: float, n: int) -> void:
	var sp := iso(wx, wy)
	for i in n:
		p_add(sp, randf_range(-160, 160), randf_range(-240, 40), 640.0, randf_range(4, 8.8), randf_range(0.3, 0.6), Color("#a01818"))

func p_dust(wx: float, wy: float, n: int) -> void:
	var sp := iso(wx, wy)
	for i in n:
		p_add(sp + Vector2(randf_range(-32, 32), randf_range(-20, 20)), randf_range(-100, 100), randf_range(-160, -20), 120.0, randf_range(6, 12.8), randf_range(0.4, 0.8), Color("#b8a888"))

func p_spark(wx: float, wy: float, n: int) -> void:
	var sp := iso(wx, wy)
	for i in n:
		p_add(sp, randf_range(-360, 360), randf_range(-440, 80), 880.0, randf_range(4, 8), randf_range(0.25, 0.5), Color("#ffcc44") if randf() < 0.5 else Color("#ff8833"))

func p_smoke(wx: float, wy: float, n: int) -> void:
	var sp := iso(wx, wy)
	for i in n:
		p_add(sp + Vector2(randf_range(-16, 16), randf_range(-16, 16)), randf_range(-48, 48), randf_range(-140, -60), -48.0, randf_range(10, 18), randf_range(0.6, 1.1), Color("#888880"))

func p_chimney(wx: float, wy: float, zoff: float) -> void:
	var sp := iso(wx, wy) + Vector2(0, -zoff)
	p_add(sp, randf_range(-12, 12), randf_range(-60, -36), -20.0, randf_range(5.6, 8.8), randf_range(1.3, 2.0), Color("#9a968c"), 9.6)

func add_decal(wx: float, wy: float, type: String, col: Color, big := false) -> void:
	var s: float
	if type == "scorch":
		s = randf_range(36, 56)
	elif type == "corpse":
		s = 6.0 if big else 4.0
	else:
		s = randf_range(14, 28)
	var fade := 0.05 if type == "corpse" else (0.015 if type == "scorch" else 0.03)
	decals.append({"x":wx, "y":wy, "type":type, "col":col, "rot":randf() * TAU, "s":s,
		"a":0.95 if type == "corpse" else 0.7, "fade":fade})
	if decals.size() > 240:
		decals.pop_front()

func add_tmp_light(wx: float, wy: float, r: float, life: float, energy := 0.9) -> void:
	var l := PointLight2D.new()
	l.texture = light_tex
	l.color = Color(1.0, 0.8, 0.5)
	l.energy = energy
	l.texture_scale = r / 128.0
	l.position = iso(wx, wy)
	add_child(l)
	tmp_lights.append({"node":l, "life":life, "max":life})

# ---------- 전투 ----------
func damage_enemy(e: Dictionary, dmg: float) -> void:
	e["hp"] -= dmg
	e["flash"] = 0.12
	if randf() < 0.12:
		_sfx("hit", -10.0, Vector2(e["x"], e["y"]))
	if e["hp"] <= 0.0 and not e.get("dead", false):
		e["dead"] = true
		enemies.erase(e)
		if randf() < 0.5:
			_sfx("enemy_die", -12.0, Vector2(e["x"], e["y"]))
		last_kill = Vector2(e["x"], e["y"])
		add_res(EDEFS[e["type"]]["loot"])
		var lt: Dictionary = EDEFS[e["type"]]["loot"]
		var lparts := []
		var lname := {"food":"식량", "wood":"목재", "iron":"철"}
		for k in lt:
			lparts.append("+%d %s" % [int(lt[k]), lname[k]])
		if not lparts.is_empty():
			floats.append({"x":e["x"], "y":e["y"], "t":0.9, "max":0.9, "small":true,
				"txt":" ".join(lparts), "col":Color(1, 0.92, 0.55)})
			if floats.size() > 80:
				floats.pop_front()
		p_blood(e["x"], e["y"], 8)
		add_decal(e["x"], e["y"], "blood", Color("#7a1414"))
		add_decal(e["x"], e["y"], "corpse", EDEFS[e["type"]]["corpse"], e["type"] == "sam")

func damage_thing(t: Dictionary, dmg: float) -> void:
	if t.has("size"):
		dmg /= (1.0 + RES_BDEF * research["bdef"])
	else:
		dmg /= (1.0 + RES_UDEF * research["udef"])
		if t.has("type") and UDEFS.has(t["type"]):
			dmg *= (1.0 - float(UDEFS[t["type"]].get("armor", 0.0)))
	t["hp"] -= dmg
	t["flash"] = 0.12
	if t["hp"] <= 0.0:
		if t.has("size") and buildings.has(t):
			remove_building(t)

# ---------- 메인 시뮬레이션 ----------
func sim_update(dt: float) -> void:
	game_time += dt
	_update_move_marker(dt)
	var w = next_wave()
	if w != null and cur_day() >= int(w["day"]) and spawn_q.is_empty() and not w.has("started"):
		w["started"] = true
		wave_elapsed = 0.0
		enrage = 0.0
		start_wave(w)
	var wave_active: bool = w != null and w.has("started") and (not spawn_q.is_empty() or not enemies.is_empty())
	if wave_active:
		wave_elapsed += dt
		enrage = maxf(0.0, wave_elapsed - ENRAGE_START)
	else:
		enrage = 0.0
	for i in range(spawn_q.size() - 1, -1, -1):
		spawn_q[i]["t"] -= dt
		if spawn_q[i]["t"] <= 0.0:
			spawn_enemy(spawn_q[i]["type"], spawn_q[i]["side"], float(spawn_q[i].get("fr", -1.0)))
			spawn_q.remove_at(i)
	if w != null and w.has("started") and spawn_q.is_empty() and enemies.is_empty():
		_set_workers_hidden(false)
		wave_idx += 1
		if wave_idx >= WAVES.size():
			if endless:
				WAVES.append(_gen_endless_wave())
				endless_wave += 1
				WAVES[wave_idx]["side"] = randi() % 4
				show_banner("무한 항전 제%d파 격퇴! 계속된다..." % endless_wave)
				log_msg("무한 항전 진행 — 최고 기록 갱신 중")
			else:
				victory()
				return
		else:
			WAVES[wave_idx]["side"] = randi() % 4
		show_banner("제%d차 공세 격퇴!" % wave_idx)
		log_msg("다음 공세: %d일차 · %s" % [int(WAVES[wave_idx]["day"]), SIDE_NAME[int(WAVES[wave_idx]["side"])]])
		# 일시 모디파이어 해제 후 이벤트 롤
		_clear_temp_mods()
		if randf() < EVENT_CHANCE:
			_roll_event()
	_build_enemy_grid()
	# 건물
	for b in buildings:
		if b["flash"] > 0.0:
			b["flash"] -= dt
		if b["build"] > 0.0:
			b["build"] -= dt
			if b["build"] <= 0.0:
				finish_building(b)
				log_msg("%s 완공" % BDEFS[b["type"]]["name"])
			continue
		var d: Dictionary = BDEFS[b["type"]]
		if d.has("prod"):
			for k in d["prod"]:
				res[k] += d["prod"][k] * dt
			b["ft"] = float(b.get("ft", randf_range(1.0, FLOAT_EVERY))) - dt
			if float(b["ft"]) <= 0.0:
				b["ft"] = FLOAT_EVERY
				var rname := {"food":"식량", "wood":"목재", "iron":"철"}
				var rcol := {"food":Color(1, 0.85, 0.4), "wood":Color(0.62, 0.85, 0.42), "iron":Color(0.75, 0.8, 0.95)}
				for k in d["prod"]:
					floats.append({"x":b["x"], "y":b["y"], "t":1.6, "max":1.6,
						"txt":"+%d %s" % [int(round(d["prod"][k] * FLOAT_EVERY)), rname[k]], "col":rcol[k]})
		if b["type"] == "house" or b["type"] == "hq":
			b["st"] -= dt
			if b["st"] <= 0.0:
				b["st"] = randf_range(1.1, 2.6)
				p_chimney(b["x"] + randf_range(-4, 4), b["y"], 56.0 if b["type"] == "house" else 120.0)
		if d.has("rng"):
			b["cd"] -= dt
			if b["cd"] <= 0.0:
				var e = nearest_enemy(b["x"], b["y"], d["rng"])
				if e != null:
					b["cd"] = d["cd"]
					var aoe: float = d["aoe"] if d.has("aoe") else 0.0
					projs.append({"x":b["x"], "y":b["y"], "tgt":e, "tx":e["x"], "ty":e["y"],
						"spd":220.0 if aoe > 0.0 else 340.0, "dmg":float(d["dmg"]) * (1.0 + RES_BATK * research["batk"]), "aoe":aoe,
						"cannon":aoe > 0.0, "hostile":false, "z":104.0,
						"trav":0.0, "tot":max(wdist(b["x"], b["y"], e["x"], e["y"]), 1.0)})
					if aoe > 0.0:
						_sfx("jincheon" if b["type"] == "btower" else "cannon", 0.0, Vector2(b["x"], b["y"]))
						p_smoke(b["x"], b["y"], 2)
						add_tmp_light(b["x"], b["y"], 220.0, 0.1)
					else:
						_sfx("arrow", -8.0, Vector2(b["x"], b["y"]))
	# 병사
	for u in units:
		var d: Dictionary = UDEFS[u["type"]]
		u["cd"] -= dt
		u["moving"] = false
		if u["flash"] > 0.0:
			u["flash"] -= dt
		if float(u.get("atk_t", 0.0)) > 0.0:
			u["atk_t"] = float(u["atk_t"]) - dt
		# 명시적 이동 명령은 전투보다 우선 — 도착할 때까지 교전하지 않음
		if u.get("mv", false):
			if wdist(u["x"], u["y"], u["ox"], u["oy"]) <= 4.0:
				u["mv"] = false
			else:
				if u["ox"] != u["x"]:
					u["fx"] = 1.0 if u["ox"] > u["x"] else -1.0
				_move(u, u["ox"], u["oy"], d["spd"] * dt)
				u["moving"] = true
				continue
		var melee: bool = float(d["rng"]) < 1.5 * TILE
		var aggro: float = 4.0 * TILE if melee else float(d["rng"])
		var e = nearest_enemy(u["x"], u["y"], aggro)
		if e != null:
			if e["x"] != u["x"]:
				u["fx"] = 1.0 if e["x"] > u["x"] else -1.0
			var ed := wdist(u["x"], u["y"], e["x"], e["y"])
			if ed <= float(d["rng"]):
				if u["cd"] <= 0.0:
					u["cd"] = d["cd"]
					var udmg: float = float(d["dmg"]) * (1.0 + RES_UATK * research["uatk"]) * float(mod_flags.get("ally_dmg", 1.0))
					if float(d.get("hunter", 1.0)) > 1.0 and float(e["maxhp"]) >= HUNTER_HP_MIN:
						udmg *= float(d["hunter"])
					if melee:
						# 범위 근접 공격: 반경 내 모든 적 타격
						u["atk_t"] = 0.3
						_sfx("slash", -10.0, Vector2(u["x"], u["y"]))
						for e2 in enemies_near(u["x"], u["y"], SPEAR_CLEAVE * TILE):
							damage_enemy(e2, udmg)
						p_blood(e["x"], e["y"], 2)
					else:
						if randf() < 0.35:
							_sfx("arrow", -12.0, Vector2(u["x"], u["y"]))
						projs.append({"x":u["x"], "y":u["y"], "tgt":e, "tx":e["x"], "ty":e["y"],
							"spd":340.0, "dmg":udmg, "aoe":0.0, "cannon":false, "hostile":false,
							"z":24.0, "trav":0.0, "tot":max(ed, 1.0)})
			elif melee:
				_move(u, e["x"], e["y"], d["spd"] * dt)
				u["moving"] = true
		elif wdist(u["x"], u["y"], u["ox"], u["oy"]) > 4.0:
			if u["ox"] != u["x"]:
				u["fx"] = 1.0 if u["ox"] > u["x"] else -1.0
			_move(u, u["ox"], u["oy"], d["spd"] * dt)
			u["moving"] = true
	# 적
	lords_cache.clear()
	for e0 in enemies:
		if e0["type"] == "lord":
			lords_cache.append(e0)
	gapsa_cache.clear()
	for u0 in units:
		if u0["type"] == "spear2":
			gapsa_cache.append(u0)
	var exploders := []
	for e in enemies:
		var d: Dictionary = EDEFS[e["type"]]
		e["cd"] -= dt
		e["rt"] -= dt
		e["moving"] = false
		if e["flash"] > 0.0:
			e["flash"] -= dt
		if float(e.get("atk_t", 0.0)) > 0.0:
			e["atk_t"] = float(e["atk_t"]) - dt
		if e["type"] == "lord":
			e["sum_t"] = float(e.get("sum_t", LORD_SUMMON_CD)) - dt
			if float(e["sum_t"]) <= 0.0 and int(e.get("sum_n", 0)) < LORD_SUMMON_MAX:
				e["sum_t"] = LORD_SUMMON_CD
				e["sum_n"] = int(e.get("sum_n", 0)) + 1
				_lord_summon(e)
		if e["rt"] <= 0.0 or e["target"] == null or e["target"]["hp"] <= 0.0:
			e["rt"] = 0.5
			var tg = nearest_unit(e["x"], e["y"], 3.5 * TILE)
			if tg == null:
				tg = nearest_building(e["x"], e["y"], 2.4 * TILE)
			if tg == null:
				tg = hq
			e["target"] = tg
		var t: Dictionary = e["target"]
		if t["x"] != e["x"]:
			e["fx"] = 1.0 if t["x"] > e["x"] else -1.0
		var trng: float = (t["size"] * TILE * 0.5 + 4.0 if t.has("size") else 7.0) + float(d["rng"])
		var td := wdist(e["x"], e["y"], t["x"], t["y"])
		e["bf"] = _lord_buffed(e)
		if td <= trng:
			if e["type"] == "bomber":
				exploders.append(e)
			elif e["cd"] <= 0.0:
				e["cd"] = d["cd"]
				var edmg: float = float(e.get("dmg", d["dmg"])) * (1.0 + ENRAGE_RATE * enrage)
				if e["bf"]:
					edmg *= LORD_DMG_BUFF
				if float(d["rng"]) > TILE:
					projs.append({"x":e["x"], "y":e["y"], "tgt":t, "tx":t["x"], "ty":t["y"],
						"spd":420.0, "dmg":edmg, "aoe":0.0, "cannon":false, "hostile":true,
						"z":20.0, "trav":0.0, "tot":max(td, 1.0)})
					p_smoke(e["x"], e["y"], 1)
					add_tmp_light(e["x"] + e["fx"] * 9.0, e["y"] - 3.0, 144.0, 0.08)
				else:
					e["atk_t"] = 0.3
					var sdmg := edmg
					if t.has("size"):
						sdmg *= float(EDEFS[e["type"]].get("siege", 1.0))
					if randf() < 0.15:
						_sfx("enemy_attack", -16.0, Vector2(e["x"], e["y"]))
					damage_thing(t, sdmg)
					if t.has("size"):
						p_dust(e["x"], e["y"], 1)
		else:
			var a: float = atan2(t["y"] - e["y"], t["x"] - e["x"])
			var probe = occ_at(e["x"] + cos(a) * (float(d["rng"]) + 8.0), e["y"] + sin(a) * (float(d["rng"]) + 8.0))
			if probe != null and probe != t:
				e["target"] = probe
			else:
				var spd2: float = float(d["spd"]) * (LORD_SPD_BUFF if bool(e.get("bf", false)) else 1.0) * (1.0 + ENRAGE_SPD * enrage)
				if enemies.size() <= 3:
					e["ghost_t"] = 0.5  # 극소수 잔당은 장애물 무시 직행 (소프트락 방지)
				if e.get("ghost_t", 0.0) > 0.0:
					# 최후 수단: 잠시 장애물 무시 (절벽 포켓 소프트락 방지)
					e["ghost_t"] = float(e["ghost_t"]) - dt
					e["x"] += cos(a) * spd2 * dt
					e["y"] += sin(a) * spd2 * dt
				elif e.get("detour_t", 0.0) > 0.0:
					e["detour_t"] = float(e["detour_t"]) - dt
					var da: float = e["d_ang"]
					_move(e, e["x"] + cos(da) * 60.0, e["y"] + sin(da) * 60.0, spd2 * dt, false, true)
				else:
					var offm: float = clampf(td / (3.0 * TILE) + 0.25, 0.35, 1.0)
					if enemies.size() <= 12:
						offm = clampf(td / (3.0 * TILE) - 0.3, 0.0, 1.0)  # 잔당은 곧장 돌격 (스트래글러 방지)
					_move(e, t["x"] + float(e.get("tox", 0.0)) * offm, t["y"] + float(e.get("toy", 0.0)) * offm, spd2 * dt, false, true)
				e["moving"] = true
				# 정체 감지 → 무작위 우회 전념, 반복 정체 시 ghost 탈출
				e["chk_t"] = float(e.get("chk_t", 1.2)) - dt
				if float(e["chk_t"]) <= 0.0:
					if wdist(e["x"], e["y"], float(e.get("sx", -999.0)), float(e.get("sy", -999.0))) < 7.0:
						var sn: int = int(e.get("stuck_n", 0)) + 1
						# 근처에 건물(성벽 등)이 있으면 우회 대신 즉시 공격 대상으로 전환
						var nb = nearest_building(e["x"], e["y"], 3.0 * TILE)
						if nb != null and nb != t:
							e["target"] = nb
							e["rt"] = 1.2
							e["stuck_n"] = 0
						elif sn >= 4:
							e["ghost_t"] = 1.6
							e["stuck_n"] = 0
						else:
							e["stuck_n"] = sn
							e["detour_t"] = randf_range(0.9, 1.8) + 0.5 * sn
							e["d_ang"] = a + (PI * 0.5 + randf() * 0.9) * (1.0 if randf() < 0.5 else -1.0)
					else:
						e["stuck_n"] = 0
					e["sx"] = e["x"]
					e["sy"] = e["y"]
					e["chk_t"] = 1.2
	_separate_enemies()
	for eb in exploders:
		if enemies.has(eb):
			_explode_bomber(eb)
	# 투사체
	for i in range(projs.size() - 1, -1, -1):
		var p: Dictionary = projs[i]
		if p["tgt"] != null and p["tgt"]["hp"] > 0.0:
			p["tx"] = p["tgt"]["x"]
			p["ty"] = p["tgt"]["y"]
		var dd := wdist(p["x"], p["y"], p["tx"], p["ty"])
		var step: float = p["spd"] * dt
		p["trav"] += step
		if dd <= step:
			if p["aoe"] > 0.0:
				for e2 in enemies_near(p["tx"], p["ty"], p["aoe"]):
					var dd2 := wdist(e2["x"], e2["y"], p["tx"], p["ty"])
					damage_enemy(e2, p["dmg"] * (1.0 - AOE_FALLOFF * dd2 / p["aoe"]))
				booms.append({"x":p["tx"], "y":p["ty"], "r":4.0, "max":p["aoe"], "life":0.3})
				p_spark(p["tx"], p["ty"], 12)
				p_smoke(p["tx"], p["ty"], 5)
				add_decal(p["tx"], p["ty"], "scorch", Color.BLACK)
				add_tmp_light(p["tx"], p["ty"], 480.0, 0.35, 1.2)
				shake = min(shake + 4.0, 8.0)
				if p["aoe"] >= 1.9 * TILE:
					# 대완구급 대폭발: 링 2겹 + 불꽃·연기 증량 + 강한 진동
					booms.append({"x":p["tx"], "y":p["ty"], "r":10.0, "max":p["aoe"] * 1.35, "life":0.45})
					p_spark(p["tx"], p["ty"], 26)
					p_smoke(p["tx"], p["ty"], 12)
					add_tmp_light(p["tx"], p["ty"], 900.0, 0.5, 1.6)
					shake = minf(shake + 7.0, 14.0)
			elif p["hostile"]:
				if p["tgt"] != null and p["tgt"]["hp"] > 0.0:
					damage_thing(p["tgt"], p["dmg"])
					if p["tgt"].has("size"):
						p_dust(p["tx"], p["ty"], 1)
					else:
						p_blood(p["tx"], p["ty"], 2)
			else:
				if p["tgt"] != null and p["tgt"]["hp"] > 0.0:
					damage_enemy(p["tgt"], p["dmg"])
					p_blood(p["tx"], p["ty"], 1)
			projs.remove_at(i)
		else:
			var a2: float = atan2(p["ty"] - p["y"], p["tx"] - p["x"])
			p["x"] += cos(a2) * step
			p["y"] += sin(a2) * step
	for i in range(booms.size() - 1, -1, -1):
		booms[i]["life"] -= dt
		booms[i]["r"] += dt * booms[i]["max"] * 4.0
		if booms[i]["life"] <= 0.0:
			booms.remove_at(i)
	for i in range(tmp_lights.size() - 1, -1, -1):
		var tl: Dictionary = tmp_lights[i]
		tl["life"] -= dt
		if tl["life"] <= 0.0:
			tl["node"].queue_free()
			tmp_lights.remove_at(i)
		else:
			tl["node"].energy = 1.2 * tl["life"] / tl["max"]
	for i in range(particles.size() - 1, -1, -1):
		var pt: Dictionary = particles[i]
		pt["life"] -= dt
		if pt["life"] <= 0.0:
			particles.remove_at(i)
			continue
		pt["vy"] += pt["g"] * dt
		pt["x"] += pt["vx"] * dt
		pt["y"] += pt["vy"] * dt
		if pt["gr"] != 0.0:
			pt["r"] += pt["gr"] * dt
	for i in range(decals.size() - 1, -1, -1):
		decals[i]["a"] -= decals[i]["fade"] * dt
		if decals[i]["a"] <= 0.0:
			decals.remove_at(i)
	for i in range(floats.size() - 1, -1, -1):
		floats[i]["t"] -= dt
		if floats[i]["t"] <= 0.0:
			floats.remove_at(i)
	for i in range(units.size() - 1, -1, -1):
		if units[i]["hp"] <= 0.0:
			_sfx("ally_die", -6.0, Vector2(units[i]["x"], units[i]["y"]))
			p_blood(units[i]["x"], units[i]["y"], 6)
			add_decal(units[i]["x"], units[i]["y"], "blood", Color("#7a1414"))
			sel_units.erase(units[i])
			units.remove_at(i)
	fog_t -= dt
	if fog_t <= 0.0:
		fog_t = 0.6
		for u2 in units:
			reveal(u2["x"], u2["y"], 6)
		if not workers_hidden:
			for wk2 in workers:
				reveal(wk2["x"], wk2["y"], 5)
	# 건설 중 망치 소리 (주기적, 건설 일꾼이 실제 두드리는 중일 때)
	hammer_t -= dt
	if hammer_t <= 0.0:
		var building_now := false
		var hammer_pos := Vector2.ZERO
		if not workers_hidden:
			for wk in workers:
				if wk["task"] == "build" and wk["state"] == "work":
					building_now = true
					hammer_pos = Vector2(wk["x"], wk["y"])
					break
		if building_now:
			_sfx("hammer", -6.0, Vector2(hammer_pos))
			hammer_t = 0.55
		else:
			hammer_t = 0.2
	if not workers_hidden:
		_update_workers(dt)

func _separate_enemies() -> void:
	# 공간 해시로 O(n) 근사 — 가까운 적끼리만 밀어냄
	# 좌표를 Packed 배열에 미리 뽑아 인덱스로만 돌린다(딕셔너리 문자열 키 접근이 병목이었음)
	var n := enemies.size()
	if n < 2:
		return
	var cell: float = ENEMY_SEP
	var ex := PackedFloat32Array()
	var ey := PackedFloat32Array()
	ex.resize(n)
	ey.resize(n)
	var grid := {}
	for i in n:
		var e: Dictionary = enemies[i]
		var x: float = e["x"]
		var y: float = e["y"]
		ex[i] = x
		ey[i] = y
		var key := Vector2i(int(x / cell), int(y / cell))
		var bucket = grid.get(key)
		if bucket == null:
			grid[key] = [i]
		else:
			bucket.append(i)
	var sep: float = ENEMY_SEP
	var sep2 := sep * sep
	for i in n:
		var x := ex[i]
		var y := ey[i]
		var cx := int(x / cell)
		var cy := int(y / cell)
		var px := 0.0
		var py := 0.0
		for oy in 3:
			for ox in 3:
				var bucket = grid.get(Vector2i(cx + ox - 1, cy + oy - 1))
				if bucket == null:
					continue
				for j in bucket:
					if j == i:
						continue
					var dx := x - ex[j]
					var dy := y - ey[j]
					var d2 := dx * dx + dy * dy
					if d2 < sep2:
						if d2 < 0.01:
							# 완전 중첩 — 무작위 방향으로 밀어냄
							px += randf_range(-1.0, 1.0)
							py += randf_range(-1.0, 1.0)
						else:
							var d := sqrt(d2)
							var f := (sep - d) / d * 0.5
							px += dx * f
							py += dy * f
		if px != 0.0 or py != 0.0:
			var nx: float = clampf(x + clampf(px, -3.0, 3.0), 4.0, W - 4.0)
			var ny: float = clampf(y + clampf(py, -3.0, 3.0), 4.0, H - 4.0)
			if not _terra_blocked(nx, ny) and not _wall_at(nx, ny):
				var e: Dictionary = enemies[i]
				e["x"] = nx
				e["y"] = ny

func _lord_buffed(e: Dictionary) -> bool:
	if lords_cache.is_empty() or e["type"] == "lord":
		return false
	for l in lords_cache:
		if wdist(e["x"], e["y"], l["x"], l["y"]) < LORD_AURA * TILE:
			return true
	return false

func _explode_bomber(e: Dictionary) -> void:
	_sfx("bomber", 0.0, Vector2(e["x"], e["y"]))
	var r := BOMBER_AOE * TILE
	for b in buildings.duplicate():
		if wdist(e["x"], e["y"], b["x"], b["y"]) <= r + (b["size"] - 1) * TILE * 0.5:
			damage_thing(b, BOMBER_DMG)
	for u in units:
		if wdist(e["x"], e["y"], u["x"], u["y"]) <= r:
			damage_thing(u, BOMBER_DMG)
	booms.append({"x":e["x"], "y":e["y"], "r":4.0, "max":r, "life":0.3})
	p_spark(e["x"], e["y"], 14)
	p_smoke(e["x"], e["y"], 6)
	add_decal(e["x"], e["y"], "scorch", Color.BLACK)
	add_tmp_light(e["x"], e["y"], 420.0, 0.3, 1.2)
	shake = minf(shake + 5.0, 9.0)
	e["dead"] = true
	e["hp"] = 0.0
	enemies.erase(e)

func _move(o: Dictionary, tx: float, ty: float, step: float, block_walls := true, foe := false) -> void:
	var a: float = atan2(ty - o["y"], tx - o["x"])
	var nx: float = o["x"] + cos(a) * step
	var ny: float = o["y"] + sin(a) * step
	if _pass_blocked(nx, ny, block_walls, foe):
		# 막히면 축 단위로 미끄러짐
		if not _pass_blocked(nx, o["y"], block_walls, foe):
			ny = o["y"]
		elif not _pass_blocked(o["x"], ny, block_walls, foe):
			nx = o["x"]
		else:
			# 완전히 막힘 — 수직 방향 우회(벽 따라가기, 좌측 우선)
			for pa in [a + PI * 0.5, a - PI * 0.5]:
				var qx: float = o["x"] + cos(pa) * step
				var qy: float = o["y"] + sin(pa) * step
				if not _pass_blocked(qx, qy, block_walls, foe):
					o["x"] = qx
					o["y"] = qy
					return
			return
	o["x"] = nx
	o["y"] = ny

# ---------- 승패/메시지 ----------
func victory() -> void:
	# 마지막 적 처치 → 3초 슬로 모션 → 페이드 아웃 → 승리 타이틀
	if win_t >= 0.0 or game_over:
		return
	win_t = 0.0
	banner_lbl.text = ""
	banner_t = 0.0

func defeat() -> void:
	if game_over:
		return
	game_over = true
	paused = true
	_show_end("행궁 함락...", "%d일차, 제%d차 공세에서 행궁이 함락되었습니다.\n성벽을 더 두껍게, 궁수탑을 더 촘촘히 배치해 보십시오." % [cur_day(), wave_idx + 1])

func _gen_endless_wave() -> Dictionary:
	# 마지막 파도 기준 절차적 증강 (지수적으로 점증)
	var base: Dictionary = WAVES[WAVES.size() - 1]["comp"]
	var f := 1.0 + 0.12 * (endless_wave + 1)
	var comp := {}
	for k in base:
		comp[k] = int(ceil(int(base[k]) * f))
	comp["lord"] = int(comp.get("lord", 2)) + 1 + endless_wave / 2
	return {"day":int(WAVES[WAVES.size() - 1]["day"]) + 3, "comp":comp, "final":true}

func wave_comp_str(w: Dictionary) -> String:
	# 성장률 반영 실제 스폰 수로 편성 요약
	var cmult := 1.0 + ENEMY_COUNT_GROWTH * wave_idx
	var parts := []
	for k in ["ashi", "gun", "sam", "bomber", "lord"]:
		if w["comp"].has(k):
			parts.append("%s %d" % [EDEFS[k]["name"], int(ceil(int(w["comp"][k]) * cmult))])
	return " · ".join(parts)

func show_banner(s: String) -> void:
	banner_lbl.text = s
	banner_t = 3.5

func log_msg(s: String) -> void:
	logs.append(s)
	if logs.size() > 4:
		logs.pop_front()
	log_lbl.text = "\n".join(logs)

# ---------- UI ----------
func _sb(bg: Color, border: Color, bw := 1, rad := 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(rad)
	s.set_content_margin_all(6)
	return s

func _style_button(b: Button) -> void:
	b.add_theme_stylebox_override("normal", _sb(Color(0.22, 0.16, 0.09), Color(0.42, 0.32, 0.2)))
	b.add_theme_stylebox_override("hover", _sb(Color(0.3, 0.23, 0.12), Color(0.66, 0.5, 0.28)))
	b.add_theme_stylebox_override("pressed", _sb(Color(0.54, 0.41, 0.22), Color(1.0, 0.85, 0.47)))
	b.add_theme_stylebox_override("disabled", _sb(Color(0.13, 0.1, 0.06), Color(0.25, 0.2, 0.13)))
	b.add_theme_color_override("font_color", Color(0.91, 0.86, 0.78))
	b.add_theme_color_override("font_disabled_color", Color(0.5, 0.45, 0.38))

func _mk_label(txt: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = txt
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l

func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	var th := Theme.new()
	th.default_font = kfont
	th.default_font_size = 14
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.theme = th
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(root)
	# 상단 바
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.add_theme_stylebox_override("panel", _sb(Color(0.14, 0.1, 0.055, 0.95), Color(0.48, 0.36, 0.2), 2, 0))
	root.add_child(top)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 14)
	top.add_child(hb)
	lbl_food = _mk_label("식량 0", 15, Color(1, 0.85, 0.48))
	lbl_wood = _mk_label("목재 0", 15, Color(1, 0.85, 0.48))
	lbl_iron = _mk_label("철 0", 15, Color(1, 0.85, 0.48))
	lbl_pop = _mk_label("병력 0/6", 15, Color(0.75, 0.88, 1))
	for pair in [["icon_food", lbl_food], ["icon_wood", lbl_wood], ["icon_iron", lbl_iron]]:
		var ic := TextureRect.new()
		ic.texture = TEX[pair[0]]
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(22, 22)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hb.add_child(ic)
		hb.add_child(pair[1])
	hb.add_child(lbl_pop)
	pause_btn = Button.new()
	pause_btn.text = "일시정지"
	_style_button(pause_btn)
	pause_btn.pressed.connect(_toggle_pause)
	hb.add_child(pause_btn)
	for sp in [1.0, 2.0, 3.0]:
		var sb := Button.new()
		sb.text = "x%d" % int(sp)
		_style_button(sb)
		sb.pressed.connect(_set_speed.bind(sp))
		hb.add_child(sb)
	var all_btn := Button.new()
	all_btn.text = "전군 선택"
	_style_button(all_btn)
	all_btn.pressed.connect(_select_all_units)
	hb.add_child(all_btn)
	var setb := Button.new()
	setb.text = "⚙ 설정"
	_style_button(setb)
	setb.pressed.connect(_toggle_settings)
	hb.add_child(setb)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(spacer)
	lbl_day = _mk_label("1일차", 14, Color(0.91, 0.86, 0.78))
	lbl_wave = _mk_label("", 14, Color(1, 0.6, 0.55))
	hb.add_child(lbl_day)
	hb.add_child(lbl_wave)
	# 하단 건설 바
	bot_bar = PanelContainer.new()
	var bot := bot_bar
	bot.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bot.grow_vertical = Control.GROW_DIRECTION_BEGIN
	bot.add_theme_stylebox_override("panel", _sb(Color(0.14, 0.1, 0.055, 0.95), Color(0.48, 0.36, 0.2), 2, 0))
	root.add_child(bot)
	var bhb := HBoxContainer.new()
	bhb.add_theme_constant_override("separation", 10)
	bot.add_child(bhb)
	var vb0 := VBoxContainer.new()
	bhb.add_child(vb0)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	vb0.add_child(tabs)
	tab_btns = []
	for spec in [["생산", 0], ["방어", 1], ["병력", 2]]:
		var tb := Button.new()
		tb.text = spec[0]
		tb.toggle_mode = true
		tb.custom_minimum_size = Vector2(76, 26)
		_style_button(tb)
		tb.pressed.connect(_switch_tab.bind(int(spec[1])))
		tabs.add_child(tb)
		tab_btns.append(tb)
	tab_btns[0].button_pressed = true
	build_box = HBoxContainer.new()
	build_box.add_theme_constant_override("separation", 6)
	vb0.add_child(build_box)
	def_box = HBoxContainer.new()
	def_box.add_theme_constant_override("separation", 6)
	def_box.visible = false
	vb0.add_child(def_box)
	unit_box = HBoxContainer.new()
	unit_box.add_theme_constant_override("separation", 6)
	unit_box.visible = false
	vb0.add_child(unit_box)
	# 생산 탭: 자원·인구·거래·병력양성 / 방어 탭: 성벽·탑
	var prod_group := ["lumber", "farm", "mine", "house", "market", "barracks"]
	for t in prod_group + ["wall", "wall2", "wall3", "atower", "ctower", "btower"]:
		var d: Dictionary = BDEFS[t]
		var b := Button.new()
		b.tooltip_text = "%s\n내구도 %d · 건설 %d초" % [d["desc"], int(d["hp"]), int(d["build"])]
		b.custom_minimum_size = Vector2(90, 88)
		_style_button(b)
		_btn_portrait(b, d["name"], d["cost"], t, Vector2(44, 38))
		b.pressed.connect(_on_build_pressed.bind(t))
		if t in prod_group:
			build_box.add_child(b)
		else:
			def_box.add_child(b)
		btns[t] = b
	var bspacer := Control.new()
	bspacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bspacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bhb.add_child(bspacer)
	var dsep := VSeparator.new()
	bhb.add_child(dsep)
	var dem := Button.new()
	dem.text = "철거\n50% 회수"
	dem.custom_minimum_size = Vector2(76, 60)
	dem.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	dem.add_theme_stylebox_override("normal", _sb(Color(0.3, 0.1, 0.08), Color(0.62, 0.26, 0.2)))
	dem.add_theme_stylebox_override("hover", _sb(Color(0.4, 0.14, 0.1), Color(0.8, 0.36, 0.28)))
	dem.add_theme_stylebox_override("pressed", _sb(Color(0.55, 0.2, 0.14), Color(1.0, 0.5, 0.4)))
	dem.add_theme_color_override("font_color", Color(1, 0.78, 0.72))
	dem.pressed.connect(_on_build_pressed.bind("demolish"))
	bhb.add_child(dem)
	btns["demolish"] = dem
	for t in ["archer", "spear", "archer2", "spear2"]:
		var d2: Dictionary = UDEFS[t]
		var b2 := Button.new()
		var utrait := ""
		if t == "archer2":
			utrait = " · 대물 저격(고체력 적 2배)"
		elif t == "spear2":
			utrait = " · 방벽(적이 통과 못함 — 성벽 구멍을 몸으로 막음)"
		b2.tooltip_text = "%s · 체력 %d 공격 %d%s%s" % ["훈련소 필요" if d2.has("tier") else "행궁에서 모집", int(d2["hp"]), int(d2["dmg"]), " · 인구 2" if d2.has("tier") else "", utrait]
		b2.custom_minimum_size = Vector2(90, 88)
		_style_button(b2)
		_btn_portrait(b2, d2["name"], d2["cost"], "u_" + t, Vector2(32, 38))
		b2.pressed.connect(_on_recruit_pressed.bind(t))
		unit_box.add_child(b2)
		btns[t] = b2
	up_panel = PanelContainer.new()
	up_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	up_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	up_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	up_panel.offset_right = -10
	up_panel.offset_bottom = -118   # _sync_up_panel_pos()가 하단 바 높이에 맞춰 갱신
	up_panel.add_theme_stylebox_override("panel", _sb(Color(0.14, 0.1, 0.055, 0.95), Color(0.66, 0.5, 0.28), 2, 6))
	up_panel.visible = false
	root.add_child(up_panel)
	bot_bar.resized.connect(_sync_up_panel_pos)
	_sync_up_panel_pos.call_deferred()
	var uvb := VBoxContainer.new()
	up_panel.add_child(uvb)
	up_lbl = _mk_label("", 14, Color(0.95, 0.9, 0.78))
	uvb.add_child(up_lbl)
	up_btn = Button.new()
	up_btn.text = ""
	_style_button(up_btn)
	up_btn.pressed.connect(_do_upgrade)
	uvb.add_child(up_btn)
	# 설정 패널 (재시작·저장·불러오기·닫기)
	settings_panel = PanelContainer.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	settings_panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	settings_panel.add_theme_stylebox_override("panel", _sb(Color(0.12, 0.09, 0.05, 0.98), Color(0.66, 0.5, 0.28), 2, 8))
	settings_panel.visible = false
	root.add_child(settings_panel)
	var svb := VBoxContainer.new()
	svb.add_theme_constant_override("separation", 8)
	settings_panel.add_child(svb)
	var stitle := _mk_label("설정", 22, Color(1, 0.85, 0.48))
	stitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	svb.add_child(stitle)
	restart_btn = Button.new()
	restart_btn.text = "재시작"
	restart_btn.custom_minimum_size = Vector2(200, 34)
	_style_button(restart_btn)
	restart_btn.pressed.connect(_on_restart_pressed)
	svb.add_child(restart_btn)
	var s_save := Button.new()
	s_save.text = "저장"
	s_save.custom_minimum_size = Vector2(200, 34)
	_style_button(s_save)
	s_save.pressed.connect(_save_game)
	svb.add_child(s_save)
	var s_load := Button.new()
	s_load.text = "불러오기"
	s_load.custom_minimum_size = Vector2(200, 34)
	_style_button(s_load)
	s_load.pressed.connect(_load_game)
	svb.add_child(s_load)
	var s_close := Button.new()
	s_close.text = "닫기 (계속하기)"
	s_close.custom_minimum_size = Vector2(200, 34)
	_style_button(s_close)
	s_close.pressed.connect(_toggle_settings)
	svb.add_child(s_close)
	trade_box = VBoxContainer.new()
	trade_box.visible = false
	uvb.add_child(trade_box)
	var pairs := [["wood", "food"], ["food", "wood"], ["wood", "iron"], ["iron", "wood"], ["food", "iron"], ["iron", "food"]]
	trade_btns = []
	for pr in pairs:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		trade_box.add_child(row)
		for amount in [50, 500]:
			var tb := Button.new()
			tb.custom_minimum_size = Vector2(124, 30)
			_style_button(tb)
			var rl := _trade_btn_content(tb, pr[0], pr[1], amount)
			tb.pressed.connect(_trade.bind(pr[0], pr[1], amount))
			row.add_child(tb)
			trade_btns.append([tb, pr[0], pr[1], amount, rl])
	# 미니맵 (우상단, 포그 연동, 클릭 이동)
	var mm_panel := PanelContainer.new()
	mm_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	mm_panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	mm_panel.offset_top = 42
	mm_panel.offset_right = -8
	mm_panel.add_theme_stylebox_override("panel", _sb(Color(0.1, 0.075, 0.045, 0.92), Color(0.48, 0.36, 0.2), 2, 4))
	root.add_child(mm_panel)
	mm_img = Image.create(GW, GH, false, Image.FORMAT_RGBA8)
	mm_tex = ImageTexture.create_from_image(mm_img)
	var mm_rect := TextureRect.new()
	mm_rect.texture = mm_tex
	mm_rect.custom_minimum_size = Vector2(GW * 3, GH * 3)
	mm_rect.stretch_mode = TextureRect.STRETCH_SCALE
	mm_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mm_panel.add_child(mm_rect)
	mm_view = Control.new()
	mm_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	mm_rect.add_child(mm_view)
	mm_view.draw.connect(_draw_mm_overlay)
	mm_view.gui_input.connect(_mm_input)
	# 배너/로그
	banner_lbl = _mk_label("", 26, Color(1, 0.93, 0.62))
	banner_lbl.set_anchors_preset(Control.PRESET_CENTER_TOP)
	banner_lbl.position = Vector2(0, 60)
	banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_lbl.grow_horizontal = Control.GROW_DIRECTION_BOTH
	banner_lbl.modulate.a = 0.0
	root.add_child(banner_lbl)
	log_lbl = _mk_label("", 12, Color(0.89, 0.85, 0.72))
	log_lbl.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	log_lbl.position = Vector2(10, -140)
	log_lbl.grow_vertical = Control.GROW_DIRECTION_BEGIN
	root.add_child(log_lbl)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 1)
	fade_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_rect.visible = false
	root.add_child(fade_rect)
	# 시작 오버레이
	overlay = ColorRect.new()
	overlay.color = Color(0.03, 0.02, 0.01, 0.92)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(overlay)
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay.add_child(vb)
	var title := _mk_label("불멸의 성채", 36, Color(1, 0.85, 0.48))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(title)
	var sub := _mk_label("壬 辰 倭 亂 · 1 5 9 2", 14, Color(0.66, 0.57, 0.42))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(sub)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 24)
	vb.add_child(gap)
	# 전투 시작 (가운데, 크게)
	var start := Button.new()
	start.text = "   전투 시작   "
	start.add_theme_font_size_override("font_size", 22)
	_style_button(start)
	start.pressed.connect(_on_start)
	var hbc := HBoxContainer.new()
	hbc.alignment = BoxContainer.ALIGNMENT_CENTER
	hbc.add_child(start)
	vb.add_child(hbc)
	# 난이도: 작은 순환 버튼 (기본 보통) + 이어하기 — 눈에 덜 띄게
	var gap2 := Control.new()
	gap2.custom_minimum_size = Vector2(0, 34)
	vb.add_child(gap2)
	var sub_hb := HBoxContainer.new()
	sub_hb.alignment = BoxContainer.ALIGNMENT_CENTER
	sub_hb.add_theme_constant_override("separation", 8)
	diff_cycle_btn = Button.new()
	diff_cycle_btn.text = "난이도: 보통"
	diff_cycle_btn.custom_minimum_size = Vector2(110, 26)
	diff_cycle_btn.add_theme_font_size_override("font_size", 12)
	_style_button(diff_cycle_btn)
	diff_cycle_btn.pressed.connect(_cycle_diff)
	sub_hb.add_child(diff_cycle_btn)
	var loadb := Button.new()
	loadb.text = "이어하기"
	loadb.custom_minimum_size = Vector2(80, 26)
	loadb.add_theme_font_size_override("font_size", 12)
	_style_button(loadb)
	loadb.disabled = not FileAccess.file_exists("user://save.dat")
	loadb.pressed.connect(_load_game)
	sub_hb.add_child(loadb)
	vb.add_child(sub_hb)

# 거래창을 하단 건설 바 바로 위(철거 버튼 위쪽)에 붙인다.
# 바 높이는 폰트·해상도에 따라 달라지므로 고정값 대신 실제 높이를 쓴다.
func _sync_up_panel_pos() -> void:
	if up_panel != null and bot_bar != null:
		up_panel.offset_bottom = -(bot_bar.size.y + 8.0)

# 거래 버튼 한 개: [아이콘 50] → [아이콘 30]
func _trade_btn_content(b: Button, src: String, dst: String, amount: int) -> Label:
	var hb := HBoxContainer.new()
	hb.set_anchors_preset(Control.PRESET_FULL_RECT)
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 4)
	hb.add_child(_res_icon(src))
	var gl := _mk_label(str(amount), 13, Color(1, 0.86, 0.62))
	gl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(gl)
	var ar := _mk_label("→", 13, Color(0.75, 0.7, 0.6))
	ar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(ar)
	hb.add_child(_res_icon(dst))
	var rl := _mk_label("", 13, Color(0.7, 1.0, 0.72))
	rl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(rl)
	b.add_child(hb)
	return rl

func _res_icon(k: String) -> TextureRect:
	var ic := TextureRect.new()
	ic.texture = TEX["icon_" + k]
	ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ic.custom_minimum_size = Vector2(18, 18)
	ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return ic

func _btn_portrait(b: Button, title: String, cost: Dictionary, texkey: String, psize: Vector2) -> void:
	# 기존 스프라이트 초상(위) + 이름/비용(아래) 세로 배치
	var col := VBoxContainer.new()
	col.set_anchors_preset(Control.PRESET_FULL_RECT)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_theme_constant_override("separation", 1)
	var pt := TextureRect.new()
	pt.texture = TEX[texkey]
	pt.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pt.custom_minimum_size = psize
	pt.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	col.add_child(pt)
	b.add_child(col)
	var inner := Button.new()
	inner.visible = false
	_btn_content(inner, title, cost)
	var vb2: VBoxContainer = inner.get_child(0)
	inner.remove_child(vb2)
	col.add_child(vb2)
	inner.queue_free()

func _btn_content(b: Button, title: String, cost: Dictionary) -> void:
	# 버튼 안에 이름 + [아이콘+숫자] 비용 행 구성
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_FULL_RECT)
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_theme_constant_override("separation", 1)
	var nl := _mk_label(title, 13, Color(0.91, 0.86, 0.78))
	nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vb.add_child(nl)
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_theme_constant_override("separation", 3)
	for k in ["food", "wood", "iron"]:
		if not cost.has(k):
			continue
		var ic := TextureRect.new()
		ic.texture = TEX["icon_" + k]
		ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ic.custom_minimum_size = Vector2(18, 18)
		ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(ic)
		var cl := _mk_label(str(int(cost[k])), 12, Color(1, 0.9, 0.6))
		cl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hb.add_child(cl)
		cost_items.append([cl, k, int(cost[k])])
	vb.add_child(hb)
	b.add_child(vb)

func _cost_str(c: Dictionary) -> String:
	var m := {"food":"식", "wood":"목", "iron":"철"}
	var parts := []
	for k in c:
		parts.append("%s%d" % [m[k], int(c[k])])
	return " ".join(parts)

func _show_end(title: String, body: String, is_victory := false) -> void:
	overlay.visible = true
	for ch in overlay.get_children():
		ch.queue_free()
	var vb := VBoxContainer.new()
	vb.set_anchors_preset(Control.PRESET_CENTER)
	vb.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vb.grow_vertical = Control.GROW_DIRECTION_BOTH
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	overlay.add_child(vb)
	var t := _mk_label(title, 34, Color(1, 0.85, 0.48))
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(t)
	var b := _mk_label(body, 15, Color(0.85, 0.81, 0.68))
	b.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(b)
	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0, 16)
	vb.add_child(gap)
	var hbc := HBoxContainer.new()
	hbc.alignment = BoxContainer.ALIGNMENT_CENTER
	hbc.add_theme_constant_override("separation", 8)
	if is_victory and not endless:
		var cont := Button.new()
		cont.text = "  무한 항전  "
		cont.add_theme_font_size_override("font_size", 18)
		_style_button(cont)
		cont.pressed.connect(_continue_endless)
		hbc.add_child(cont)
	var r := Button.new()
	r.text = "  다시 하기  "
	r.add_theme_font_size_override("font_size", 18)
	_style_button(r)
	r.pressed.connect(func(): get_tree().reload_current_scene())
	hbc.add_child(r)
	vb.add_child(hbc)

func _continue_endless() -> void:
	endless = true
	game_over = false
	paused = false
	win_t = -1.0
	overlay.visible = false
	WAVES.append(_gen_endless_wave())
	endless_wave += 1
	WAVES[wave_idx]["side"] = randi() % 4
	log_msg("무한 항전 시작! 버틸 수 있는 데까지...")

func _cycle_diff() -> void:
	_sfx("menu")
	difficulty = (difficulty + 1) % 3
	diff_cycle_btn.text = "난이도: " + ["쉬움", "보통", "어려움"][difficulty]

func _apply_difficulty() -> void:
	if difficulty == 0:
		diff_mult = {"hp":0.8, "count":0.8, "dmg":0.85}
	elif difficulty == 2:
		diff_mult = {"hp":1.35, "count":1.3, "dmg":1.2}
	else:
		diff_mult = {"hp":1.0, "count":1.0, "dmg":1.0}

func _apply_mod() -> void:
	mod_flags = {}
	match chosen_mod:
		"refund_full": mod_flags["refund_full"] = true
		"market_deal": mod_flags["market_deal"] = true
		"ally_boost":  mod_flags["ally_dmg"] = 2.0
		"horde_weak":  mod_flags["enemy_count"] = 2.0; mod_flags["enemy_dmg"] = 0.5
		"rich_start":  res = {"food":START_FOOD * 2, "wood":START_WOOD * 2, "iron":START_IRON * 2}
		"cheap_wall":  mod_flags["cheap_wall"] = true
		"tough_foe":   mod_flags["enemy_hp"] = 1.4; res = {"food":START_FOOD * 1.5, "wood":START_WOOD * 1.5, "iron":START_IRON * 1.5}
	if mod_flags.get("cheap_wall", false):
		for wt in ["wall", "wall2", "wall3"]:
			for ck in BDEFS[wt].get("cost", {}):
				BDEFS[wt]["cost"][ck] = maxi(1, int(BDEFS[wt]["cost"][ck] / 2))

func _on_start() -> void:
	_sfx("gamestart")
	_apply_difficulty()
	overlay.visible = false
	paused = false
	game_started = true
	intro_t = INTRO_LEN
	cam.position = iso(hq["x"], hq["y"])
	cam.zoom = Vector2(1.35, 1.35)
	if fade_rect != null:
		fade_rect.visible = true
		fade_rect.modulate.a = 1.0

func _toggle_pause() -> void:
	if game_over or not game_started:
		return
	paused = not paused
	pause_btn.text = "재개" if paused else "일시정지"

func _set_speed(s: float) -> void:
	speed = s

func _switch_tab(i: int) -> void:
	_sfx("menu")
	build_box.visible = i == 0
	def_box.visible = i == 1
	unit_box.visible = i == 2
	for k in tab_btns.size():
		tab_btns[k].button_pressed = k == i

func _do_upgrade() -> void:
	if sel_building == null or not buildings.has(sel_building):
		return
	var bt: String = sel_building["type"]
	if not UPGR.has(bt):
		return
	var u: Dictionary = UPGR[bt]
	if not can_afford(u["cost"]):
		_sfx("deny")
		log_msg("자원이 부족합니다.")
		return
	var to: String = u["to"]
	var d: Dictionary = BDEFS[to]
	var b = sel_building
	# 크기가 커지는 개축(논 2×2)은 공간 확보 필요
	var anchor := Vector2i(b["gx"], b["gy"])
	var ns: int = d["size"]
	if ns > int(b["size"]):
		anchor = _find_grow_anchor(b, ns)
		if anchor.x < 0:
			log_msg("개축에 필요한 %d×%d 공간이 없습니다." % [ns, ns])
			return
	pay(u["cost"])
	if b["light"] != null:
		b["light"].queue_free()
		b["light"] = null
	b["type"] = to
	b["is_wall"] = (to == "wall" or to == "wall2" or to == "wall3")
	if ns != int(b["size"]) or anchor.x != int(b["gx"]) or anchor.y != int(b["gy"]):
		for j in b["size"]:
			for i in b["size"]:
				occ[b["gy"] + j][b["gx"] + i] = null
		b["gx"] = anchor.x
		b["gy"] = anchor.y
		b["size"] = ns
		for j in ns:
			for i in ns:
				occ[b["gy"] + j][b["gx"] + i] = b
		b["x"] = (b["gx"] + ns / 2.0) * TILE
		b["y"] = (b["gy"] + ns / 2.0) * TILE
	b["maxhp"] = d["hp"]
	b["hp"] = d["hp"] * 0.5
	b["build"] = d["build"]
	b["build_max"] = max(d["build"], 0.001)
	_spawn_workers_for(b)
	log_msg("%s 개축 시작" % d["name"])

func _find_grow_anchor(b: Dictionary, s: int) -> Vector2i:
	# 기존 타일을 포함하는 s×s 영역 탐색 (빈 땅·탐사됨·광맥 아님)
	for oy in [0, -1]:
		for ox in [0, -1]:
			var ax: int = b["gx"] + ox
			var ay: int = b["gy"] + oy
			if ax < 1 or ay < 1 or ax + s > GW - 1 or ay + s > GH - 1:
				continue
			var ok := true
			for j in s:
				for i in s:
					var cell = occ[ay + j][ax + i]
					var idx := (ay + j) * GW + ax + i
					if (cell != null and cell != b) or fog[idx] == 0 or ore[idx] == 1:
						ok = false
						break
				if not ok:
					break
			if ok:
				return Vector2i(ax, ay)
	return Vector2i(-1, -1)

func _save_game() -> void:
	var d := {"res":res, "game_time":game_time, "wave_idx":wave_idx, "difficulty":difficulty,
		"chosen_mod":chosen_mod, "endless":endless, "endless_wave":endless_wave, "research":research,
		"buildings":[], "fog":Array(fog), "ore":Array(ore)}
	for b in buildings:
		d["buildings"].append({"type":b["type"], "gx":b["gx"], "gy":b["gy"], "hp":b["hp"], "build":b["build"]})
	var f := FileAccess.open("user://save.dat", FileAccess.WRITE)
	if f == null:
		log_msg("저장 실패")
		return
	f.store_string(JSON.stringify(d))
	f.close()
	log_msg("저장되었습니다.")

func _load_game() -> void:
	var f := FileAccess.open("user://save.dat", FileAccess.READ)
	if f == null:
		return
	var d = JSON.parse_string(f.get_as_text())
	f.close()
	if d == null:
		return
	for b in buildings.duplicate():
		if b["light"] != null:
			b["light"].queue_free()
	buildings.clear()
	units.clear()
	enemies.clear()
	workers.clear()
	spawn_q.clear()
	move_marker = null   # 사라진 병사를 가리키던 표식이 남지 않도록
	for j in GH:
		for i in GW:
			occ[j][i] = null
	res = {"food":float(d["res"]["food"]), "wood":float(d["res"]["wood"]), "iron":float(d["res"]["iron"])}
	game_time = float(d["game_time"])
	wave_idx = int(d["wave_idx"])
	difficulty = int(d["difficulty"])
	chosen_mod = str(d["chosen_mod"])
	endless = bool(d["endless"])
	endless_wave = int(d["endless_wave"])
	for k in d["research"]:
		research[k] = int(d["research"][k])
	var sf = d["fog"]
	for i in mini(fog.size(), sf.size()):
		fog[i] = int(sf[i])
	fog_dirty = true
	_apply_difficulty()
	_apply_mod()
	for bd in d["buildings"]:
		var nb = make_building(str(bd["type"]), int(bd["gx"]), int(bd["gy"]), true)
		nb["hp"] = float(bd["hp"])
		nb["build"] = float(bd["build"])
	for b in buildings:
		if b["type"] == "hq":
			hq = b
	overlay.visible = false
	paused = false
	game_started = true
	intro_t = 0.0
	settings_panel.visible = false
	log_msg("불러왔습니다.")

func _toggle_settings() -> void:
	_sfx("menu")
	settings_panel.visible = not settings_panel.visible
	# 설정 열면 일시정지
	if settings_panel.visible:
		if game_started and not game_over:
			paused = true
			pause_btn.text = "재개"

func _on_restart_pressed() -> void:
	if restart_arm > 0.0:
		get_tree().reload_current_scene()
	else:
		restart_arm = 2.5
		restart_btn.text = "정말? 재클릭"

func _select_all_units() -> void:
	_sfx("select")
	sel_units = units.duplicate()
	build_sel = ""
	sel_building = null
	if sel_units.is_empty():
		log_msg("선택할 병사가 없습니다.")
	else:
		log_msg("전군 선택 (%d명)" % sel_units.size())

func _research_cost(key: String) -> Dictionary:
	var lv: int = research[key]
	return {"wood":RES_COST_WOOD * (lv + 1), "iron":RES_COST_IRON * (lv + 1)}

func _do_research(key: String) -> void:
	if int(research[key]) >= RES_MAX_LV:
		return
	var c := _research_cost(key)
	if not can_afford(c):
		_sfx("deny")
		log_msg("자원이 부족합니다.")
		return
	pay(c)
	research[key] += 1
	log_msg("%s 연구 완료 (Lv%d)" % [RES_NAMES[key], research[key]])

func _on_build_pressed(t: String) -> void:
	build_sel = "" if build_sel == t else t
	sel_units.clear()
	sel_building = null

func _on_recruit_pressed(t: String) -> void:
	recruit(t)

func _update_hud() -> void:
	lbl_food.text = "식량 %d" % int(res["food"])
	lbl_wood.text = "목재 %d" % int(res["wood"])
	lbl_iron.text = "철 %d" % int(res["iron"])
	lbl_pop.text = "병력 %d/%d" % [pop_used(), pop_max()]
	lbl_day.text = "%d일차 %s  x%d" % [cur_day(), "밤" if ambient_level() > 0.25 else "낮", int(speed)]
	var w = next_wave()
	if w == null:
		lbl_wave.text = "모든 공세 격퇴!"
	elif w.has("started") or not spawn_q.is_empty() or not enemies.is_empty():
		var etxt := "제%d차 공세 진행 중! (적 %d)" % [wave_idx + 1, enemies.size() + spawn_q.size()]
		if enrage > 0.0:
			etxt += "  ⚔광폭화 +%d%%" % int(ENRAGE_RATE * enrage * 100.0)
		lbl_wave.text = etxt
	else:
		var remain: float = float(w["day"]) * DAY_LEN - DAY_LEN - game_time
		var sname: String = "사방" if w.has("final") else SIDE_NAME[int(w["side"])]
		lbl_wave.text = "다음 공세(제%d차) %d초 후 · %s  [%s]" % [wave_idx + 1, int(max(0.0, ceil(remain))), sname, wave_comp_str(w)]
	for ci in cost_items:
		var cl2: Label = ci[0]
		cl2.add_theme_color_override("font_color", Color(1, 0.32, 0.26) if res[ci[1]] < ci[2] else Color(1, 0.9, 0.6))
	for t in btns:
		var b: Button = btns[t]
		b.modulate = Color(1, 1, 1, 0.5) if b.disabled else Color(1, 1, 1, 1)
		if t == "demolish":
			b.disabled = false
		elif BDEFS.has(t):
			b.disabled = not can_afford(BDEFS[t]["cost"])
		else:
			var du: Dictionary = UDEFS[t]
			var need_ok: bool = has_barracks() if du.has("tier") else true
			var pop_block: bool = pop_used() + int(du.get("pop", 1)) > pop_max()
			b.disabled = not need_ok or not can_afford(du["cost"])
			if not b.has_meta("tt"):
				b.set_meta("tt", b.tooltip_text)
			if pop_block:
				b.tooltip_text = "인구 상한 도달 (%d/%d)\n민가를 지어 상한을 늘리세요!" % [pop_used(), pop_max()]
			else:
				b.tooltip_text = String(b.get_meta("tt"))
	# 개축 패널
	if sel_building != null and buildings.has(sel_building):
		up_panel.visible = true
		var bt2: String = sel_building["type"]
		up_lbl.text = "%s  내구 %d/%d" % [BDEFS[bt2]["name"], int(sel_building["hp"]), int(sel_building["maxhp"])]
		if UPGR.has(bt2) and sel_building["build"] <= 0.0:
			up_btn.visible = true
			var uu: Dictionary = UPGR[bt2]
			up_btn.text = "%s(으)로 개축  %s" % [BDEFS[uu["to"]]["name"], _cost_str(uu["cost"])]
			up_btn.disabled = not can_afford(uu["cost"])
		else:
			up_btn.visible = false
		var is_market: bool = bt2 == "market" and sel_building["build"] <= 0.0
		trade_box.visible = is_market
		if is_market:
			var deal: bool = mod_flags.get("market_deal", false)
			var rate := "특가! (손해 없음)" if deal else "환율 60%"
			up_lbl.text = "%s  %s" % [BDEFS[bt2]["name"], rate]
			# 특가 이벤트로 환율이 바뀌므로 받는 수량은 열 때마다 다시 계산한다
			for e in trade_btns:
				var give: int = e[3]
				var get_n: int = give if deal else int(give * 0.6)
				e[4].text = str(get_n)
				e[4].add_theme_color_override("font_color", Color(1, 0.86, 0.4) if deal else Color(0.7, 1.0, 0.72))
				e[0].disabled = res[e[1]] < float(give)
	else:
		sel_building = null
		up_panel.visible = false
		trade_box.visible = false
	# 배너 페이드
	if banner_t > 0.0:
		banner_lbl.modulate.a = min(1.0, banner_t / 0.5)
	elif paused and game_started and not game_over:
		banner_lbl.text = "일시정지 — Space 로 재개"
		banner_lbl.modulate.a = 1.0
	else:
		banner_lbl.modulate.a = 0.0

# ---------- 미니맵 ----------
func _update_minimap() -> void:
	for gy in GH:
		for gx in GW:
			var i := gy * GW + gx
			var col := Color(0.02, 0.02, 0.026)
			if fog[i] == 1:
				var tt: String = tile_tex[i]
				col = Color(0.2, 0.27, 0.15)
				if tt == "tile_dirt":
					col = Color(0.34, 0.27, 0.17)
				elif tt == "tile_court":
					col = Color(0.33, 0.32, 0.28)
				elif tt == "tile_ore":
					col = Color(0.36, 0.34, 0.4)
				elif tt == "tile_mud":
					col = Color(0.31, 0.24, 0.16)
				if cliff[i] == 1:
					col = Color(0.42, 0.4, 0.36)
			mm_img.set_pixel(gx, gy, col)
	for b in buildings:
		var t: String = b["type"]
		var bc := Color(0.82, 0.74, 0.5)
		if t == "hq":
			bc = Color(1.0, 0.85, 0.3)
		elif t == "wall":
			bc = Color(0.55, 0.42, 0.24)
		elif t == "wall2":
			bc = Color(0.66, 0.64, 0.58)
		elif t == "wall3":
			bc = Color(0.55, 0.6, 0.75)
		elif t == "atower" or t == "ctower":
			bc = Color(0.95, 0.55, 0.25)
		for j in b["size"]:
			for i in b["size"]:
				mm_img.set_pixel(int(b["gx"]) + i, int(b["gy"]) + j, bc)
	for u in units:
		mm_img.set_pixel(clampi(int(u["x"] / TILE), 0, GW - 1), clampi(int(u["y"] / TILE), 0, GH - 1), Color(0.4, 1.0, 0.4))
	for e in enemies:
		if tile_visible(e["x"], e["y"]):
			mm_img.set_pixel(clampi(int(e["x"] / TILE), 0, GW - 1), clampi(int(e["y"] / TILE), 0, GH - 1), Color(1.0, 0.25, 0.2))
	mm_tex.update(mm_img)

func _draw_mm_overlay() -> void:
	# 카메라 시야 영역 (월드 좌표 → 미니맵 비율)
	var sz := mm_view.size
	var vp := get_viewport_rect().size
	var pts := PackedVector2Array()
	for corner in [Vector2.ZERO, Vector2(vp.x, 0), vp, Vector2(0, vp.y)]:
		var wpt := unproject(screen_to_canvas(corner))
		pts.append(Vector2(clampf(wpt.x / W, 0.0, 1.0) * sz.x, clampf(wpt.y / H, 0.0, 1.0) * sz.y))
	pts.append(pts[0])
	mm_view.draw_polyline(pts, Color(1, 0.9, 0.55, 0.9), 1.5)
	var w = next_wave()
	if w != null and not w.has("started") and w.has("side") and not w.has("final"):
		var remain: float = float(w["day"]) * DAY_LEN - DAY_LEN - game_time
		if remain < WARN_TIME and remain > 0.0:
			var pulse := 0.5 + 0.5 * sin(game_time * 5.0)
			var er: Rect2 = [Rect2(0, 0, sz.x, 5), Rect2(sz.x - 5, 0, 5, sz.y), Rect2(0, sz.y - 5, sz.x, 5), Rect2(0, 0, 5, sz.y)][int(w["side"])]
			mm_view.draw_rect(er, Color(1, 0.2, 0.15, 0.4 + 0.5 * pulse))

func _mm_input(ev: InputEvent) -> void:
	var go := false
	var pos := Vector2.ZERO
	if ev is InputEventMouseButton:
		var mb: InputEventMouseButton = ev
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			go = true
			pos = mb.position
	elif ev is InputEventMouseMotion:
		var mm: InputEventMouseMotion = ev
		if (mm.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			go = true
			pos = mm.position
	if not go:
		return
	var sz := mm_view.size
	cam.position = iso(clampf(pos.x / sz.x, 0.0, 1.0) * W, clampf(pos.y / sz.y, 0.0, 1.0) * H)
	_clamp_cam()

# ---------- 입력 ----------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		_zoom(event.position, event.factor)
		return
	if event is InputEventPanGesture:
		cam.position += event.delta * 2.0 / cam.zoom.x
		_clamp_cam()
		return
	if event is InputEventMouseMotion:
		if mmb_down:
			cam.position -= event.relative / cam.zoom.x
			_clamp_cam()
			return
		var cp := screen_to_canvas(event.position)
		var wp := unproject(cp)
		hover = Vector2i(int(floor(wp.x / TILE)), int(floor(wp.y / TILE)))
		if dragging and build_sel == "":
			drag_box = Rect2(drag_start, cp - drag_start).abs()
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(event.position, 1.12)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(event.position, 1.0 / 1.12)
			return
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			mmb_down = event.pressed
			return
		var sp: Vector2 = screen_to_canvas(event.position)
		var wp2 := unproject(sp)
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = sp
				drag_box = Rect2()
				if build_sel == "demolish":
					var b = occ_at(wp2.x, wp2.y)
					if b != null and b["type"] != "hq":
						var c: Dictionary = BDEFS[b["type"]].get("cost", {})
						for k in c:
							res[k] += int(c[k] * (1.0 if mod_flags.get("refund_full", false) else 0.5))
						var nm: String = BDEFS[b["type"]]["name"]
						remove_building(b)
						log_msg("%s 철거 (자원 50%% 회수)" % nm)
				elif build_sel != "":
					var gx := int(floor(wp2.x / TILE))
					var gy := int(floor(wp2.y / TILE))
					if can_place(build_sel, gx, gy):
						if can_afford(BDEFS[build_sel]["cost"]):
							pay(BDEFS[build_sel]["cost"])
							make_building(build_sel, gx, gy)
							_sfx(_place_snd(build_sel), 0.0, Vector2((gx + 0.5) * TILE, (gy + 0.5) * TILE))
							p_dust((gx + 0.5) * TILE, (gy + 0.5) * TILE, 5)
						else:
							_sfx("deny")
							log_msg("자원이 부족합니다.")
					elif nearest_enemy((gx + 0.5) * TILE, (gy + 0.5) * TILE, ENEMY_BUILD_BLOCK * TILE) != null:
						log_msg("적이 가까이 있어 건설할 수 없습니다!")
			else:
				dragging = false
				if build_sel == "" and drag_box.size.length() > 8.0:
					sel_units.clear()
					for u in units:
						if drag_box.has_point(iso(u["x"], u["y"])):
							sel_units.append(u)
					if not sel_units.is_empty():
						log_msg("병사 %d명 선택" % sel_units.size())
				elif build_sel == "":
					sel_units.clear()
					var bestd := 14.0
					var best = null
					for u in units:
						var dd := sp.distance_to(iso(u["x"], u["y"]))
						if dd < bestd:
							bestd = dd
							best = u
					if best != null:
						sel_units.append(best)
						sel_building = null
					else:
						sel_building = occ_at(wp2.x, wp2.y)
				drag_box = Rect2()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if build_sel != "":
				build_sel = ""
			elif sel_building != null:
				sel_building = null
			elif not sel_units.is_empty():
				var i := 0
				for u in sel_units:
					var a := i * 2.4
					var r := sqrt(float(i)) * 10.0
					u["ox"] = clamp(wp2.x + cos(a) * r, 8.0, W - 8.0)
					u["oy"] = clamp(wp2.y + sin(a) * r, 8.0, H - 8.0)
					u["mv"] = true
					i += 1
				var has_elite := false
				for u2 in sel_units:
					if UDEFS[u2["type"]].has("tier"):
						has_elite = true
						break
				if has_elite:
					_sfx("move")
				# 새 명령 → 기존 인디케이터를 버리고 클릭 지점에 새로 생성
				move_marker = {"x":wp2.x, "y":wp2.y, "t":0.0, "units":sel_units.duplicate()}
				log_msg("이동 명령 하달")
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_SPACE:
			_toggle_pause()
		elif event.keycode == KEY_SELECT_ALL:
			_select_all_units()
		elif event.keycode == KEY_ESCAPE:
			build_sel = ""
			sel_units.clear()
			sel_building = null

func _process(delta: float) -> void:
	var dtr: float = clamp(delta, 0.0, 0.05)
	if not paused and not game_over:
		var dt := dtr * speed
		if win_t >= 0.0:
			dt = dtr * 0.2
		var steps := int(ceil(dt / 0.033))
		for i in steps:
			sim_update(dt / steps)
	shake *= 0.88
	if banner_t > 0.0:
		banner_t -= dtr
	if restart_arm > 0.0:
		restart_arm -= dtr
		if restart_arm <= 0.0:
			restart_btn.text = "재시작"
	mm_t -= dtr
	if mm_t <= 0.0:
		mm_t = 0.25
		_update_minimap()
		mm_view.queue_redraw()
	if win_t >= 0.0 and not game_over:
		win_t += dtr
		var wct := iso(last_kill.x, last_kill.y)
		cam.position = cam.position.lerp(wct, minf(1.0, dtr * 7.0))
		var wz: float = lerpf(cam.zoom.x, 1.05, minf(1.0, dtr * 4.0))
		cam.zoom = Vector2(wz, wz)
		_clamp_cam()
		if win_t >= 3.0:
			fade_rect.visible = true
			fade_rect.modulate.a = clampf((win_t - 3.0) / 1.5, 0.0, 1.0)
		if win_t >= 4.8:
			fade_rect.visible = false
			game_over = true
			paused = true
			_show_end("승리! 조선을 지켜냈다!", "%d일간의 항전 끝에 왜군의 공세를 모두 격퇴했습니다.\n그대의 이름은 역사에 길이 남을 것입니다." % cur_day(), true)
	if intro_t > 0.0:
		intro_t -= dtr
		var ip: float = clampf(1.0 - intro_t / INTRO_LEN, 0.0, 1.0)
		var ep: float = ip * ip * (3.0 - 2.0 * ip)
		var iz: float = lerpf(1.35, 0.55, ep)
		cam.zoom = Vector2(iz, iz)
		cam.position = iso(hq["x"], hq["y"])
		_clamp_cam()
		fade_rect.modulate.a = 1.0 - ep
		if intro_t <= 0.0:
			fade_rect.visible = false
	if game_started and not game_over and intro_t <= 0.0 and win_t < 0.0:
		var cdir := Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_W):
			cdir.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S):
			cdir.y += 1.0
		if Input.is_physical_key_pressed(KEY_A):
			cdir.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D):
			cdir.x += 1.0
		if cdir != Vector2.ZERO:
			cam.position += cdir.normalized() * CAM_SPEED * dtr / cam.zoom.x
			_clamp_cam()
	amb_cur = move_toward(amb_cur, _ambient_target(), dtr * 0.22)
	var amb := ambient_level()
	cmod.color = Color(1, 1, 1).lerp(Color(0.36, 0.42, 0.66), amb / 0.52)
	for b in buildings:
		if b["light"] != null:
			var base := 1.0
			if b["type"] == "hq":
				base = 1.25
			elif b["type"] == "house":
				base = 0.7
			var fl := 0.85 + 0.15 * sin(game_time * 11.0 + b["ph"])
			b["light"].energy = (amb / 0.52) * base * fl
	_update_hud()
	queue_redraw()

# ---------- 드로잉 헬퍼 ----------
func ell(c: Vector2, rx: float, ry: float, col: Color) -> void:
	draw_set_transform(c + shake_off, 0.0, Vector2(1.0, ry / max(rx, 0.01)))
	draw_circle(Vector2.ZERO, rx, col)
	draw_set_transform(shake_off, 0.0, Vector2.ONE)

func ering(c: Vector2, rx: float, ry: float, col: Color, wd: float) -> void:
	draw_set_transform(c + shake_off, 0.0, Vector2(1.0, ry / max(rx, 0.01)))
	draw_arc(Vector2.ZERO, rx, 0.0, TAU, 40, col, wd)
	draw_set_transform(shake_off, 0.0, Vector2.ONE)

func diamond(c: Vector2, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([c + Vector2(0, -hh), c + Vector2(hw, 0), c + Vector2(0, hh), c + Vector2(-hw, 0)])

func prism(c: Vector2, hw: float, hh: float, z: float, ct: Color, cl: Color, cr: Color) -> void:
	var n := c + Vector2(0, -hh)
	var s := c + Vector2(0, hh)
	var e := c + Vector2(hw, 0)
	var wv := c + Vector2(-hw, 0)
	var up := Vector2(0, -z)
	draw_colored_polygon(PackedVector2Array([wv, s, s + up, wv + up]), cl)
	draw_colored_polygon(PackedVector2Array([s, e, e + up, s + up]), cr)
	draw_colored_polygon(PackedVector2Array([n + up, e + up, s + up, wv + up]), ct)

func _flame(p: Vector2, s: float, ph: float) -> void:
	var f := 0.75 + 0.25 * sin(game_time * 15.0 + ph) + 0.08 * sin(game_time * 37.0 + ph * 2.0)
	ell(p + Vector2(0, -1.5 * s * f), 1.5 * s, 2.4 * s * f, Color(1, 0.47, 0.12, 0.85))
	ell(p + Vector2(0, -1.1 * s * f), 0.8 * s, 1.4 * s * f, Color(1, 0.86, 0.47, 0.9))

func _flag(p: Vector2, wd: float, ht: float, col: Color, ph: float) -> void:
	var k := sin(game_time * 6.0 + ph) * 6.4
	draw_colored_polygon(PackedVector2Array([p, p + Vector2(wd * 0.5, k * 0.5), p + Vector2(wd, k * 0.7),
		p + Vector2(wd, ht + k * 0.7), p + Vector2(wd * 0.5, ht + k * 0.5), p + Vector2(0, ht)]), col)

func hp_bar(p: Vector2, wd: float, ratio: float, fg := Color.TRANSPARENT) -> void:
	draw_rect(Rect2(p.x - 1.5, p.y - 1.5, wd + 3.0, 11.0), Color(0, 0, 0, 0.65))
	var col := fg
	if col == Color.TRANSPARENT:
		col = Color("#5fd45f") if ratio > 0.5 else (Color("#e8c84a") if ratio > 0.25 else Color("#e05c4a"))
	draw_rect(Rect2(p.x, p.y, wd * clamp(ratio, 0.0, 1.0), 8.0), col)

# ---------- 건물 드로잉 ----------
func _white_of(k: String) -> Texture2D:
	# 피격 플래시용 백색 실루엣 (최초 1회 생성 후 캐시)
	if TEXW.has(k):
		return TEXW[k]
	var img: Image = TEX[k].get_image()
	img.convert(Image.FORMAT_RGBA8)
	var data := img.get_data()
	for i in range(0, data.size(), 4):
		if data[i + 3] > 24:
			data[i] = 255
			data[i + 1] = 255
			data[i + 2] = 255
	var img2 := Image.create_from_data(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8, data)
	TEXW[k] = ImageTexture.create_from_image(img2)
	return TEXW[k]

func draw_building(b: Dictionary) -> void:
	var c := iso(b["x"], b["y"])
	var t: String = b["type"]
	if b["build"] > 0.0:
		# 공사장 스프라이트는 1×1 기준. 바닥 다이아(127px)가 타일 1칸(112px)보다
		# 이미 넓어서 size만큼 그대로 확대하면 발자국을 넘어간다 → SITE_GROW로 완만하게 키움
		var ss: float = 1.0 + (float(b["size"]) - 1.0) * SITE_GROW
		var stex: Texture2D = TEX["site"]
		draw_texture_rect(stex, Rect2(c - ANCH["site"] * ss, stex.get_size() * ss), false)
		var fr: float = 1.0 - b["build"] / b["build_max"]
		hp_bar(c + Vector2(-44, -80.0 * ss), 88.0, fr, Color("#e8c84a"))
		return
	draw_texture(TEX[t], c - ANCH[t])
	var amb := ambient_level()
	if t == "hq":
		draw_line(c + Vector2(0, -248), c + Vector2(0, -284), Color("#888888"), 3.0)
		_flag(c + Vector2(0, -284), 40.0, 22.0, Color("#2456a0"), b["ph"])
		if amb > 0.18:
			ell(c + Vector2(48, -72), 12.0, 16.0, Color(1, 0.75, 0.35, minf(0.6, amb)))
	elif t == "atower":
		_flame(c + Vector2(-40, -104), 4.8, b["ph"])
		if amb > 0.18:
			ell(c + Vector2(44, -88), 7.2, 8.8, Color(1, 0.6, 0.3, minf(0.7, amb + 0.2)))
	elif (t == "ctower" or t == "btower") and b["cd"] > float(BDEFS[t]["cd"]) - 0.15:
		draw_circle(c + Vector2(48, -100) if t == "ctower" else Vector2(4, -120), 14.0 if t == "ctower" else 20.0, Color(1, 0.86, 0.47, 0.9))
	elif t == "house" and amb > 0.18:
		ell(c + Vector2(28, -12), 8.8, 11.2, Color(1, 0.75, 0.35, minf(0.55, amb)))
	if b["flash"] > 0.0:
		draw_texture(_white_of(t), c - ANCH[t], Color(1, 1, 1, minf(1.0, b["flash"] * 6.0)))
	if b["hp"] < b["maxhp"]:
		hp_bar(c + Vector2(-44, -b["size"] * 96.0 - 32.0), 88.0, b["hp"] / b["maxhp"])
	if BDEFS[t].has("rng") and build_sel == t:
		ering(c, BDEFS[t]["rng"] * 3.6, BDEFS[t]["rng"] * 1.8, Color(1, 1, 1, 0.25), 3.0)

func _draw_site(b: Dictionary, c: Vector2) -> void:
	var hw: float = b["size"] * TILE * ISO_SX
	var hh: float = b["size"] * TILE * ISO_SY
	draw_colored_polygon(diamond(c, hw, hh), Color(0.42, 0.33, 0.2, 0.9))
	var up := Vector2(0, -10)
	for pt in [c + Vector2(-hw * 0.8, 0), c + Vector2(hw * 0.8, 0), c + Vector2(0, -hh * 0.8), c + Vector2(0, hh * 0.8)]:
		draw_line(pt, pt + up, Color("#6b4a26"), 1.6)
	draw_line(c + Vector2(-hw * 0.8, 0) + up, c + Vector2(0, hh * 0.8) + up, Color("#8a6a44"), 1.2)
	draw_line(c + Vector2(0, hh * 0.8) + up, c + Vector2(hw * 0.8, 0) + up, Color("#8a6a44"), 1.2)
	draw_circle(c + Vector2(-3, 1), 2.6, Color("#a97c4a"))
	draw_circle(c + Vector2(2, 2.5), 2.6, Color("#96683c"))
	var fr: float = 1.0 - b["build"] / b["build_max"]
	hp_bar(c + Vector2(-44, -80), 88.0, fr, Color("#e8c84a"))

func _draw_wall(c: Vector2) -> void:
	prism(c, 13.2, 6.6, 13.0, Color("#a8a69a"), Color("#75736a"), Color("#8d8b80"))
	var up := Vector2(0, -13)
	for off in [Vector2(-7, 0), Vector2.ZERO, Vector2(7, 0)]:
		prism(c + up + off, 3.0, 1.5, 3.0, Color("#b3b1a5"), Color("#7e7c72"), Color("#96948a"))
	draw_line(c + Vector2(-13.2, 0), c + Vector2(-13.2, -13) + Vector2(0, 0), Color(0, 0, 0, 0.18), 1.0)

func _draw_farm(c: Vector2) -> void:
	draw_colored_polygon(diamond(c, 12.5, 6.2), Color("#6e5230"))
	for k in 3:
		var tt := 0.28 + 0.22 * k
		var y: float = lerp(-6.2, 6.2, tt)
		var hwt: float = 12.5 * (1.0 - abs(2.0 * tt - 1.0))
		draw_line(c + Vector2(-hwt, y), c + Vector2(hwt, y), Color("#4f3c22"), 1.0)
		for m in 5:
			var x: float = lerp(-hwt + 1.5, hwt - 1.5, m / 4.0)
			draw_line(c + Vector2(x, y - 0.5), c + Vector2(x, y - 3.0), Color("#79a844"), 0.9)

func _draw_lumber(c: Vector2) -> void:
	ell(c, 12.0, 6.0, Color(0.38, 0.3, 0.18, 0.7))
	for off in [Vector2(-4.5, 1.5), Vector2(1.5, 1.5), Vector2(-1.5, -2.5)]:
		draw_circle(c + off, 3.0, Color("#a97c4a"))
		draw_arc(c + off, 3.0, 0.0, TAU, 16, Color("#7c5326"), 0.8)
		draw_circle(c + off, 1.2, Color("#c9a06a"))
	ell(c + Vector2(7, -1), 2.6, 1.6, Color("#8a6238"))
	draw_line(c + Vector2(7, -2), c + Vector2(10, -9), Color("#5a4028"), 1.4)
	draw_rect(Rect2(c.x + 9.0, c.y - 11.5, 2.6, 3.0), Color("#b9bcc2"))

func _draw_mine(c: Vector2) -> void:
	prism(c, 11.0, 5.5, 8.0, Color("#8b8b82"), Color("#5e5e56"), Color("#71716a"))
	var m := c + Vector2(6, 2)
	draw_colored_polygon(PackedVector2Array([m + Vector2(-3, 1), m + Vector2(2.5, -1.5), m + Vector2(2.5, -6.5), m + Vector2(-3, -4)]), Color("#17150f"))
	draw_line(m + Vector2(-3.4, 1.4), m + Vector2(-3.4, -4.4), Color("#6b4a26"), 1.3)
	draw_line(m + Vector2(2.9, -1.2), m + Vector2(2.9, -6.8), Color("#6b4a26"), 1.3)
	draw_circle(c + Vector2(-8, 4), 1.6, Color("#4a4f5e"))
	draw_circle(c + Vector2(-8.5, 3.6), 0.6, Color("#8a92aa"))

func _draw_house(c: Vector2) -> void:
	prism(c, 11.0, 5.5, 8.0, Color("#d8ceb6"), Color("#c2b89e"), Color("#e6dcc4"))
	var up := Vector2(0, -8)
	draw_line(c + Vector2(3, 4) , c + Vector2(3, 4) + up, Color("#8a6a44"), 1.0)
	draw_line(c + Vector2(8, 1.8), c + Vector2(8, 1.8) + up, Color("#8a6a44"), 1.0)
	draw_rect(Rect2(c.x + 4.2, c.y - 5.0, 3.0, 4.6), Color("#4a2e1a"))
	var apex := c + Vector2(0, -17.5)
	var e2 := c + Vector2(14.8, 0) + up
	var w2 := c + Vector2(-14.8, 0) + up
	var s2 := c + Vector2(0, 7.4) + up
	var n2 := c + Vector2(0, -7.4) + up
	draw_colored_polygon(PackedVector2Array([w2, n2, apex]), Color("#a8863a"))
	draw_colored_polygon(PackedVector2Array([n2, e2, apex]), Color("#b8974a"))
	draw_colored_polygon(PackedVector2Array([w2, s2, apex]), Color("#b3944a"))
	draw_colored_polygon(PackedVector2Array([s2, e2, apex]), Color("#c9a854"))

func _draw_barracks(b: Dictionary, c: Vector2) -> void:
	ell(c, 12.0, 6.0, Color(0.38, 0.3, 0.18, 0.7))
	var apex := c + Vector2(0, -16)
	var e2 := c + Vector2(11, 0)
	var w2 := c + Vector2(-11, 0)
	var s2 := c + Vector2(0, 5.5)
	var n2 := c + Vector2(0, -5.5)
	draw_colored_polygon(PackedVector2Array([w2, n2, apex]), Color("#5e4126"))
	draw_colored_polygon(PackedVector2Array([n2, e2, apex]), Color("#6b4a2c"))
	draw_colored_polygon(PackedVector2Array([w2, s2, apex]), Color("#7c5a3a"))
	draw_colored_polygon(PackedVector2Array([s2, e2, apex]), Color("#68492c"))
	draw_colored_polygon(PackedVector2Array([s2 + Vector2(-2, 0), s2 + Vector2(2, 0), c + Vector2(0, -7)]), Color("#2e1e10"))
	var pole := c + Vector2(12, -2)
	draw_line(pole, pole + Vector2(0, -20), Color("#5a4028"), 1.4)
	_flag(pole + Vector2(0, -20), 7.0, 4.5, Color("#b32020"), b["ph"])

func _draw_atower(b: Dictionary, c: Vector2) -> void:
	ell(c, 11.0, 5.5, Color(0, 0, 0, 0.25))
	var up := Vector2(0, -14)
	for pt in [c + Vector2(-9, 0), c + Vector2(9, 0), c + Vector2(0, -4.5), c + Vector2(0, 4.5)]:
		draw_line(pt, pt + up, Color("#6b4a26"), 1.8)
	draw_line(c + Vector2(-9, 0), c + Vector2(9, 0) + up, Color("#6b4a26"), 1.0)
	draw_line(c + Vector2(9, 0), c + Vector2(-9, 0) + up, Color("#6b4a26"), 1.0)
	prism(c + up, 10.0, 5.0, 3.5, Color("#9a8058"), Color("#6b4a26"), Color("#8a6a44"))
	var up2 := up + Vector2(0, -3.5)
	for pt2 in [c + Vector2(-8, 0) + up2, c + Vector2(-4, 2) + up2, c + Vector2(0, 4) + up2, c + Vector2(4, 2) + up2, c + Vector2(8, 0) + up2]:
		draw_line(pt2, pt2 + Vector2(0, -4), Color("#5a4028"), 0.9)
	var apex := c + Vector2(0, -29)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-10, -3) + up2, c + Vector2(0, 2) + up2 + Vector2(0, -4), apex]), Color("#3e352c"))
	draw_colored_polygon(PackedVector2Array([c + Vector2(0, 2) + up2 + Vector2(0, -4), c + Vector2(10, -3) + up2, apex]), Color("#4a3f34"))
	_flame(c + Vector2(9, -15), 1.4, b["ph"])

func _draw_ctower(b: Dictionary, c: Vector2) -> void:
	ell(c, 12.5, 6.2, Color(0, 0, 0, 0.25))
	var up := Vector2(0, -20)
	var wB := c + Vector2(-13.2, 0)
	var sB := c + Vector2(0, 6.6)
	var eB := c + Vector2(13.2, 0)
	var wT := c + Vector2(-8.5, 0) + up
	var sT := c + Vector2(0, 4.2) + up
	var eT := c + Vector2(8.5, 0) + up
	var nT := c + Vector2(0, -4.2) + up
	draw_colored_polygon(PackedVector2Array([wB, sB, sT, wT]), Color("#6e6c62"))
	draw_colored_polygon(PackedVector2Array([sB, eB, eT, sT]), Color("#85837a"))
	draw_colored_polygon(PackedVector2Array([nT, eT, sT, wT]), Color("#93918a"))
	draw_line(lerp(wB, wT, 0.4), lerp(sB, sT, 0.4), Color(0, 0, 0, 0.2), 0.8)
	draw_line(lerp(sB, sT, 0.4), lerp(eB, eT, 0.4), Color(0, 0, 0, 0.2), 0.8)
	for off in [Vector2(-6, 0), Vector2(0, 2), Vector2(6, 0)]:
		prism(c + up + off, 2.4, 1.2, 2.6, Color("#a3a19a"), Color("#68665c"), Color("#7e7c72"))
	var muz := c + up + Vector2(10, 3)
	draw_line(c + up + Vector2(0, -1), muz, Color("#26262c"), 4.0)
	draw_line(c + up + Vector2(6, 1.4), c + up + Vector2(8, 2.2), Color("#c9a227"), 4.2)
	if b["cd"] > BDEFS["ctower"]["cd"] - 0.13:
		draw_circle(muz, 3.5, Color(1, 0.86, 0.47, 0.9))

func _draw_hq(b: Dictionary, c: Vector2) -> void:
	prism(c, 26.4, 13.2, 6.0, Color("#9a958a"), Color("#6b6659"), Color("#83806f"))
	var c2 := c + Vector2(0, -6)
	prism(c2, 20.0, 10.0, 13.0, Color("#efe6cf"), Color("#cec4a8"), Color("#e9dfc6"))
	var up := Vector2(0, -13)
	for k in 4:
		var t2: float = k / 3.0
		var pr: Vector2 = lerp(c2 + Vector2(2, 9.2), c2 + Vector2(18.5, 1.0), t2)
		draw_line(pr, pr + up * 0.92, Color("#a23a26"), 2.0)
		var pl: Vector2 = lerp(c2 + Vector2(-18.5, 1.0), c2 + Vector2(-2, 9.2), t2)
		draw_line(pl, pl + up * 0.92, Color("#8a2e1e"), 2.0)
	var dm := c2 + Vector2(9.5, 4.8)
	draw_colored_polygon(PackedVector2Array([dm + Vector2(-2.6, 1.4), dm + Vector2(2.6, -1.2), dm + Vector2(2.6, -8), dm + Vector2(-2.6, -5.4)]), Color("#4a2e1a"))
	var ev := c + Vector2(0, -19)
	var w1 := ev + Vector2(-25, 0)
	var e1 := ev + Vector2(25, 0)
	var s1 := ev + Vector2(0, 12.5)
	var r1 := c + Vector2(-8, -31)
	var r2 := c + Vector2(8, -31)
	draw_colored_polygon(PackedVector2Array([w1, s1, e1, r2, r1]), Color("#3a4048"))
	draw_line(r1, r2, Color("#c9a227"), 1.6)
	var ev2 := c + Vector2(0, -30)
	var w3 := ev2 + Vector2(-14, 0)
	var e3 := ev2 + Vector2(14, 0)
	var s3 := ev2 + Vector2(0, 7)
	var r3 := c + Vector2(-4.5, -39)
	var r4 := c + Vector2(4.5, -39)
	draw_colored_polygon(PackedVector2Array([w3, s3, e3, r4, r3]), Color("#2e343b"))
	draw_line(r3, r4, Color("#c9a227"), 1.4)
	var pole := c + Vector2(0, -39)
	draw_line(pole, pole + Vector2(0, -11), Color("#777777"), 1.0)
	_flag(pole + Vector2(0, -11), 9.0, 5.0, Color("#2456a0"), b["ph"])

# ---------- 유닛/적/일꾼 드로잉 ----------
func _man(p: Vector2, body: Color, r: float, bob: float) -> void:
	ell(p + Vector2(0, 6), r + 1.5, 2.4, Color(0, 0, 0, 0.28))
	draw_circle(p + Vector2(0, 1 + bob), r, body)
	draw_arc(p + Vector2(0, 1 + bob), r, 0.0, TAU, 16, Color(0, 0, 0, 0.35), 1.0)
	draw_circle(p + Vector2(0, -4 + bob), 2.6, Color("#e6c39a"))

func _jeonrip(p: Vector2, bob: float) -> void:
	ell(p + Vector2(0, -5.4 + bob), 4.0, 1.3, Color("#26221c"))
	draw_circle(p + Vector2(0, -6.3 + bob), 1.9, Color("#26221c"))

func draw_spr_flip(k: String, p: Vector2, fx: float, bob: float, sc := 1.0) -> void:
	draw_set_transform(Vector2(p.x, p.y + bob) + shake_off, 0.0, Vector2(fx * sc, sc))
	draw_texture(TEX[k], -ANCH[k])
	draw_set_transform(shake_off, 0.0, Vector2.ONE)

func _draw_melee_weapon(p: Vector2, fx: float, bob: float, atk: float, sc: float, kind: String, fancy: bool) -> void:
	# 일꾼 도구처럼 손에 든 무기를 애니메이션으로 그림. atk 0.3→0 진행 중 찌르기/베기
	var ph2 := 0.0
	if atk > 0.0:
		ph2 = sin((1.0 - atk / 0.3) * PI)
	var hand := p + Vector2(fx * 11.0 * sc, -26.0 * sc + bob)
	if kind == "katana":
		var ang: float = deg_to_rad(-128.0 + 105.0 * ph2)
		var dirv := Vector2(fx * cos(ang), sin(ang))
		var ln: float = (32.0 if fancy else 25.0) * sc
		draw_line(hand - dirv * 5.0 * sc, hand, Color("#5a3c1e"), 3.6 * sc)
		draw_line(hand, hand + dirv * ln, Color("#c8ccd4"), 3.0 * sc)
		draw_line(hand, hand + dirv * ln * 0.55, Color("#e8ecf2"), 1.4 * sc)
	else:
		var ang2: float = deg_to_rad(-64.0 + 52.0 * ph2)
		var dirv2 := Vector2(fx * cos(ang2), sin(ang2))
		var tail := hand - dirv2 * 14.0 * sc
		var tip := hand + dirv2 * (30.0 + ph2 * 14.0) * sc
		draw_line(tail, tip, Color("#8a6a38") if fancy else Color("#7a5a30"), 3.2 * sc)
		var perp := Vector2(-dirv2.y, dirv2.x)
		draw_colored_polygon(PackedVector2Array([tip + dirv2 * 9.0 * sc, tip + perp * 2.8 * sc, tip - perp * 2.8 * sc]), Color("#d6dae2"))
		if fancy:
			draw_line(tip, tip + Vector2(0, 5.0 * sc), Color("#aa2822"), 2.0)

func draw_unit(u: Dictionary) -> void:
	var p := iso(u["x"], u["y"])
	var bob: float = sin(game_time * 14.0 + u["ph"]) * 4.4 if u["moving"] else 0.0
	var sc := 1.0
	if u["type"] == "spear2":
		sc = 1.3
	elif UDEFS[u["type"]].has("tier"):
		sc = 1.15
	var armored: bool = float(UDEFS[u["type"]].get("armor", 0.0)) > 0.0
	if sel_units.has(u):
		ering(p + Vector2(0, 4), 30.0 * sc, 13.0 * sc, Color(0.47, 1, 0.47, 0.9), 4.0)
	if armored:
		var bb := 0.55 + 0.25 * sin(game_time * 4.0 + u["ph"])
		ering(p + Vector2(0, 4), 26.0 * sc, 10.5 * sc, Color(0.35, 0.6, 1.0, bb), 3.5)
		ering(p + Vector2(0, 4), 18.0 * sc, 7.5 * sc, Color(0.6, 0.8, 1.0, bb * 0.6), 2.0)
		var sy: float = -82.0 * sc + 3.0 * sin(game_time * 3.0 + u["ph"])
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, sy - 8), p + Vector2(7, sy - 5), p + Vector2(6, sy + 3), p + Vector2(0, sy + 9), p + Vector2(-6, sy + 3), p + Vector2(-7, sy - 5)]), Color(0.45, 0.7, 1.0, bb))
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, sy - 5), p + Vector2(4, sy - 3), p + Vector2(3.5, sy + 2), p + Vector2(0, sy + 6), p + Vector2(-3.5, sy + 2), p + Vector2(-4, sy - 3)]), Color(0.78, 0.9, 1.0, bb * 0.8))
	draw_spr_flip("u_" + u["type"], p, u["fx"], bob, sc)
	if u["type"] == "spear" or u["type"] == "spear2":
		_draw_melee_weapon(p, u["fx"], bob, float(u.get("atk_t", 0.0)), sc, "spear", u["type"] == "spear2")
	if u["flash"] > 0.0:
		var fcol := Color(0.55, 0.75, 1, minf(1.0, u["flash"] * 6.0)) if armored else Color(1, 1, 1, minf(1.0, u["flash"] * 6.0))
		draw_circle(p + Vector2(0, -30), 32.0 * sc, fcol)
	if u["hp"] < u["maxhp"]:
		hp_bar(p + Vector2(-32, -84), 64.0, u["hp"] / u["maxhp"])

func draw_enemy(e: Dictionary) -> void:
	if not tile_visible(e["x"], e["y"]):
		return
	var p := iso(e["x"], e["y"])
	var d: Dictionary = EDEFS[e["type"]]
	var bob: float = sin(game_time * 14.0 + e["ph"]) * 4.4 if e["moving"] else 0.0
	var esc := 1.0
	if e["type"] == "sam":
		esc = 1.3
	elif e["type"] == "lord":
		esc = 2.0
	if bool(e.get("bf", false)):
		var ba := 0.7 + 0.3 * sin(game_time * 9.0 + e["ph"])
		ering(p + Vector2(0, 4), 30.0 * esc, 12.5 * esc, Color(1, 0.22, 0.1, ba), 5.0)
		ering(p + Vector2(0, 4), 20.0 * esc, 8.5 * esc, Color(1, 0.55, 0.2, ba * 0.7), 3.0)
		var ry2: float = fmod(game_time * 40.0 + e["ph"] * 20.0, 26.0)
		for kk in 2:
			var ay: float = -66.0 - ry2 - kk * 13.0
			var aa: float = ba * (1.0 - (ry2 + kk * 13.0) / 42.0)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-9, ay), p + Vector2(9, ay), p + Vector2(0, ay - 10)]), Color(1, 0.35, 0.12, maxf(aa, 0.0)))
		ering(p, LORD_AURA * TILE * 3.6, LORD_AURA * TILE * 1.8, Color(1, 0.3, 0.2, 0.16 + 0.08 * sin(game_time * 4.0)), 3.0)
	draw_spr_flip("u_" + e["type"], p, e["fx"], bob, esc)
	if e["flash"] > 0.0:
		draw_circle(p + Vector2(0, -30), (d["r"] + 3.0) * 4.0, Color(1, 1, 1, minf(1.0, e["flash"] * 6.0)))
	if e["hp"] < e["maxhp"]:
		hp_bar(p + Vector2(-36, -d["r"] * 4.0 - 64.0), 72.0, e["hp"] / e["maxhp"], Color("#e74c3c"))

# 도구 스윙 위상 → 0(치켜든 상태) ~ 1(내려친 상태)
# 등속 sin 대신: 내려칠 때 가속, 타격 순간 멈칫, 되돌릴 때 천천히
func _swing01(t: float) -> float:
	var ph := fposmod(t, 1.0)
	if ph < SWING_DOWN:
		var k := ph / SWING_DOWN
		return k * k                                  # 가속 구간
	if ph < SWING_DOWN + SWING_HOLD:
		return 1.0                                    # 타격 순간 정지
	var k2 := (ph - SWING_DOWN - SWING_HOLD) / (1.0 - SWING_DOWN - SWING_HOLD)
	return 1.0 - smoothstep(0.0, 1.0, k2)             # 감속하며 복귀

func _draw_tool(k: String, pivot: Vector2, s: float, ang: float, sc: float) -> void:
	# 손잡이 끝(ANCH)을 pivot에 맞추고 회전. s<0이면 좌우 반전(수직축 대칭 = 각도 반전 + x스케일 반전)
	draw_set_transform(pivot + shake_off, ang if s > 0.0 else -ang, Vector2(sc * s, sc))
	draw_texture(TEX[k], -ANCH[k])
	draw_set_transform(shake_off, 0.0, Vector2.ONE)

func draw_worker(wk: Dictionary) -> void:
	var p := iso(wk["x"], wk["y"])
	var walking: bool = wk["state"] != "work"
	var bob: float = sin(game_time * 14.0 + wk["ph"]) * 4.0 if walking else 0.0
	var task: String = wk["task"]
	var wtex := "u_worker"
	var tool := "tool_hammer"
	if task.begins_with("farm"):
		wtex = "u_worker_farm"
		tool = "tool_hoe"
	elif task == "lumber":
		wtex = "u_worker_lumber"
		tool = "tool_axe"
	elif task == "mine":
		wtex = "u_worker_mine"
		tool = "tool_pick"
	var sc := 0.8
	draw_spr_flip(wtex, p, wk["fx"], bob, sc)
	var s: float = wk["fx"]
	# 0 = 치켜든 상태, 1 = 내려친 상태
	var sw01: float = _swing01(game_time * SWING_HZ + wk["ph"]) if not walking else SWING_IDLE
	var pivot := p + Vector2(s * 12.0 * sc, (-22.0 + bob) * sc)
	_draw_tool(tool, pivot, s, SWING_ANG_UP + sw01 * (SWING_ANG_HIT - SWING_ANG_UP), sc)

# 이동 목표 표식 — 지면에 깔리도록 유닛보다 먼저 그린다
func _draw_move_marker() -> void:
	if move_marker == null:
		return
	var c := iso(move_marker["x"], move_marker["y"])
	var t: float = move_marker["t"]
	var col := Color(0.47, 1.0, 0.55, 0.85)
	# 바깥으로 퍼지는 링 2개 (0.9초 주기, 위상 반바퀴 차이)
	for k in 2:
		var ph := fposmod(t * 1.1 + k * 0.5, 1.0)
		var rr: float = 10.0 + ph * 26.0
		var fade: float = (1.0 - ph) * 0.7
		ering(c, rr * 2.0, rr, Color(col.r, col.g, col.b, fade), 2.0)
	# 중심 다이아몬드 + 아래로 까딱이는 화살표
	var pulse: float = 1.0 + sin(t * 6.0) * 0.08
	draw_colored_polygon(diamond(c, 11.0 * pulse, 5.5 * pulse), Color(col.r, col.g, col.b, 0.3))
	var bob: float = sin(t * 6.0) * 2.5
	var tip := c + Vector2(0, -6.0 + bob)
	draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-6.0, -9.0), tip + Vector2(6.0, -9.0)]), col)
	draw_line(tip + Vector2(0, -9.0), tip + Vector2(0, -19.0), col, 2.4)

func draw_cliff(cp: Vector2) -> void:
	draw_texture(TEX["tile_cliff"], iso(cp.x, cp.y) - ANCH["tile_cliff"])

func draw_tree(t: Dictionary) -> void:
	var p := iso(t["x"], t["y"])
	var k := "pine" if t["pine"] else "tree"
	var tex: Texture2D = TEX[k]
	var s: float = t["s"]
	draw_texture_rect(tex, Rect2(p - ANCH[k] * s, tex.get_size() * s), false)

# ---------- 메인 드로우 ----------
func _draw() -> void:
	shake_off = Vector2.ZERO
	if shake > 0.3:
		shake_off = Vector2(randf_range(-shake, shake), randf_range(-shake, shake))
	draw_set_transform(shake_off, 0.0, Vector2.ONE)
	for i in tile_pos.size():
		draw_texture(TEX[tile_tex[i]], tile_pos[i])
	# 데칼
	for d in decals:
		var p := iso(d["x"], d["y"])
		var al: float = clamp(d["a"], 0.0, 1.0)
		if d["type"] == "blood":
			var col: Color = d["col"]
			col.a = al
			ell(p, d["s"], d["s"] * 0.5, col)
			ell(p + Vector2(d["s"] * 0.8, d["s"] * 0.2), d["s"] * 0.35, d["s"] * 0.18, col)
		elif d["type"] == "scorch":
			ell(p, d["s"], d["s"] * 0.5, Color(0.08, 0.06, 0.04, al * 0.7))
			ell(p, d["s"] * 0.5, d["s"] * 0.25, Color(0.05, 0.04, 0.03, al * 0.85))
		else:
			var col2: Color = d["col"]
			col2.a = al
			var sc: float = d["s"]
			ell(p, 5.0 * sc, 2.1 * sc, col2)
			draw_circle(p + Vector2(5.6 * sc, 0), 1.7 * sc, Color(0.79, 0.65, 0.51, al))
	_draw_move_marker()
	# 깊이 정렬 드로잉
	var items := []
	for b in buildings:
		items.append([b["x"] + b["y"] + (b["size"] - 1) * TILE * 0.75, 0, b])
	for t in trees:
		items.append([t["x"] + t["y"], 1, t])
	for u in units:
		items.append([u["x"] + u["y"], 2, u])
	for e in enemies:
		items.append([e["x"] + e["y"], 3, e])
	if not workers_hidden:
		for wk in workers:
			var wkey: float = wk["x"] + wk["y"]
			if wk["state"] == "work":
				var hb: Dictionary = wk["home"]
				wkey = hb["x"] + hb["y"] + (hb["size"] - 1) * TILE * 0.75 + 0.5
			items.append([wkey, 4, wk])
	for cp in cliffs:
		items.append([cp.x + cp.y, 5, cp])
	items.sort_custom(func(a, b): return a[0] < b[0])
	for it in items:
		match it[1]:
			0: draw_building(it[2])
			1: draw_tree(it[2])
			2: draw_unit(it[2])
			3: draw_enemy(it[2])
			4: draw_worker(it[2])
			5: draw_cliff(it[2])
	# 생산량·전리품 플로팅 표시
	for fl in floats:
		var pr: float = clamp(fl["t"] / fl["max"], 0.0, 1.0)
		var fsz := 21
		var foff := Vector2(-60, -96 - (1.0 - pr) * 44.0)
		if fl.get("small", false):
			fsz = 15
			foff = Vector2(-60, -44 - (1.0 - pr) * 30.0)
		var fp := iso(fl["x"], fl["y"]) + foff
		var fc: Color = fl["col"]
		fc.a = minf(1.0, pr * 2.0)
		draw_string(kfont, fp + Vector2(2, 2), fl["txt"], HORIZONTAL_ALIGNMENT_CENTER, 120, fsz, Color(0, 0, 0, fc.a * 0.8))
		draw_string(kfont, fp, fl["txt"], HORIZONTAL_ALIGNMENT_CENTER, 120, fsz, fc)
	# 투사체
	for p in projs:
		var h: float = sin(clamp(p["trav"] / p["tot"], 0.0, 1.0) * PI) * p["z"]
		var sp := iso(p["x"], p["y"]) + Vector2(0, -h)
		var dirv := (iso(p["tx"], p["ty"]) - iso(p["x"], p["y"])).normalized()
		if p["cannon"]:
			draw_line(sp - dirv * 40.0, sp, Color(1, 0.55, 0.16, 0.45), 8.0)
			draw_circle(sp, 12.0, Color("#1c1c20"))
			draw_circle(sp - dirv * 12.0, 5.6, Color(1, 0.7, 0.3, 0.8))
		elif p["hostile"]:
			draw_line(sp - dirv * 28.0, sp, Color("#ffe9a0"), 5.0)
		else:
			draw_line(sp - dirv * 32.0, sp, Color("#d8cba8"), 4.0)
			draw_circle(sp, 4.8, Color("#8a8a92"))
	# 폭발 링
	for bm in booms:
		ering(iso(bm["x"], bm["y"]), bm["r"] * 3.6, bm["r"] * 1.8, Color(1, 0.59, 0.2, clamp(bm["life"] * 3.0, 0.0, 1.0)), 8.0)
		ering(iso(bm["x"], bm["y"]), bm["r"] * 2.33, bm["r"] * 1.17, Color(1, 0.9, 0.59, clamp(bm["life"] * 2.4, 0.0, 1.0)), 4.0)
	# 워포그 — 미탐사 완전 흑색 + 맵 외곽 여유 차폐 + 탐사 경계 페이드
	if fog_dirty:
		_recalc_fog_lv()
	var fog_col := Color(0.016, 0.015, 0.02, 1.0)
	var m_t := iso(0, 0)
	var m_r := iso(W, 0)
	var m_b := iso(W, H)
	var m_l := iso(0, H)
	const MG := 6000.0
	draw_colored_polygon(PackedVector2Array([m_t, m_r, m_r + Vector2(MG, -MG), m_t + Vector2(MG, -MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_r, m_b, m_b + Vector2(MG, MG), m_r + Vector2(MG, MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_b, m_l, m_l + Vector2(-MG, MG), m_b + Vector2(-MG, MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_l, m_t, m_t + Vector2(-MG, -MG), m_l + Vector2(-MG, -MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_t, m_t + Vector2(MG, -MG), m_t + Vector2(-MG, -MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_r, m_r + Vector2(MG, MG), m_r + Vector2(MG, -MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_b, m_b + Vector2(-MG, MG), m_b + Vector2(MG, MG)]), fog_col)
	draw_colored_polygon(PackedVector2Array([m_l, m_l + Vector2(-MG, -MG), m_l + Vector2(-MG, MG)]), fog_col)
	for i in tile_pos.size():
		var lv := fog_lv[i]
		if lv <= 0.0:
			continue
		var tp: Vector2 = tile_pos[i] + Vector2(56.0, 28.0)
		if lv >= 1.0:
			draw_colored_polygon(diamond(tp, 56.8, 28.4), fog_col)
		else:
			draw_colored_polygon(diamond(tp, 56.8, 28.4), Color(fog_col.r, fog_col.g, fog_col.b, lv))
	# 파티클 (화면좌표)
	for pt in particles:
		var col: Color = pt["col"]
		col.a = clamp(pt["life"] / pt["max"], 0.0, 1.0)
		draw_circle(Vector2(pt["x"], pt["y"]), pt["r"], col)
	# 공세 방향 경고 (대형: 가장자리 띠 + 화살표 3개 + 카운트다운)
	var w = next_wave()
	if w != null and not w.has("started") and w.has("side") and not w.has("final"):
		var remain: float = float(w["day"]) * DAY_LEN - DAY_LEN - game_time
		if remain < WARN_TIME and remain > 0.0:
			var side := int(w["side"])
			var pulse := 0.5 + 0.5 * sin(game_time * 5.0)
			var band: Array = [
				[Vector2(0, 0), Vector2(W, 0), Vector2(W, 55), Vector2(0, 55)],
				[Vector2(W, 0), Vector2(W, H), Vector2(W - 55, H), Vector2(W - 55, 0)],
				[Vector2(W, H), Vector2(0, H), Vector2(0, H - 55), Vector2(W, H - 55)],
				[Vector2(0, H), Vector2(0, 0), Vector2(55, 0), Vector2(55, H)],
			][side]
			var bpts := PackedVector2Array()
			for bp in band:
				bpts.append(iso(bp.x, bp.y))
			draw_colored_polygon(bpts, Color(1, 0.15, 0.1, 0.08 + 0.14 * pulse))
			var epos: Vector2 = [Vector2(W / 2.0, 20), Vector2(W - 20, H / 2.0), Vector2(W / 2.0, H - 20), Vector2(20, H / 2.0)][side]
			var outd: Vector2 = [Vector2(0, -1), Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0)][side]
			var p0 := iso(epos.x, epos.y)
			var dv := (iso(epos.x + outd.x * 30.0, epos.y + outd.y * 30.0) - p0).normalized()
			var col3 := Color(1, 0.25, 0.2, 0.45 + 0.45 * pulse)
			for k in 3:
				var base := p0 + dv * (30.0 + k * 52.0 + pulse * 22.0)
				var perp := Vector2(-dv.y, dv.x)
				draw_colored_polygon(PackedVector2Array([base + dv * 46.0, base + perp * 42.0, base - perp * 42.0]), col3)
			var msg := "%s 공세 임박  %d초" % [SIDE_NAME[side], int(ceil(remain))]
			var tp2 := p0 + Vector2(-220, -60)
			for off in [Vector2(2, 2), Vector2(-2, 2), Vector2(2, -2), Vector2(-2, -2)]:
				draw_string(kfont, tp2 + off, msg, HORIZONTAL_ALIGNMENT_CENTER, 440, 40, Color(0, 0, 0, col3.a))
			draw_string(kfont, tp2, msg, HORIZONTAL_ALIGNMENT_CENTER, 440, 40, Color(1, 0.85, 0.6, 0.6 + 0.4 * pulse))
			var cmsg := wave_comp_str(w)
			var tp3 := p0 + Vector2(-260, -14)
			draw_string(kfont, tp3 + Vector2(2, 2), cmsg, HORIZONTAL_ALIGNMENT_CENTER, 520, 22, Color(0, 0, 0, col3.a * 0.9))
			draw_string(kfont, tp3, cmsg, HORIZONTAL_ALIGNMENT_CENTER, 520, 22, Color(1, 0.75, 0.6, 0.55 + 0.35 * pulse))
	# 선택 건물 하이라이트
	if sel_building != null and buildings.has(sel_building):
		var bsel: Dictionary = sel_building
		ering(iso(bsel["x"], bsel["y"]), bsel["size"] * TILE * 3.2, bsel["size"] * TILE * 1.6, Color(1, 0.9, 0.5, 0.6), 3.0)
	# 건설 미리보기
	if build_sel != "" and build_sel != "demolish":
		var gx := hover.x
		var gy := hover.y
		var d2: Dictionary = BDEFS[build_sel]
		var s2: int = d2["size"]
		var ok := can_place(build_sel, gx, gy) and can_afford(d2["cost"])
		var cc := iso((gx + s2 / 2.0) * TILE, (gy + s2 / 2.0) * TILE)
		draw_texture(TEX[build_sel], cc - ANCH[build_sel], Color(1, 1, 1, 0.55))
		draw_colored_polygon(diamond(cc, s2 * TILE * ISO_SX, s2 * TILE * ISO_SY),
			Color(0.47, 1, 0.47, 0.3) if ok else Color(1, 0.3, 0.3, 0.4))
		if d2.has("rng") and ok:
			ering(cc, d2["rng"] * 3.6, d2["rng"] * 1.8, Color(1, 1, 1, 0.25), 3.0)
	if build_sel == "demolish":
		var b2 = occ_at((hover.x + 0.5) * TILE, (hover.y + 0.5) * TILE)
		if b2 != null and b2["type"] != "hq":
			var cc2 := iso(b2["x"], b2["y"])
			draw_colored_polygon(diamond(cc2, b2["size"] * TILE * ISO_SX, b2["size"] * TILE * ISO_SY), Color(1, 0.24, 0.24, 0.4))
	# 드래그 박스
	if dragging and drag_box.size.length() > 4.0:
		draw_rect(drag_box, Color(0.47, 1, 0.47, 0.08))
		draw_rect(drag_box, Color(0.47, 1, 0.47, 0.9), false, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
