extends CanvasLayer

const WINDOW_SIZE := Vector2(600, 680)
const C_BG := Color(0.04, 0.045, 0.05, 0.96)
const C_PANEL := Color(0.075, 0.085, 0.095, 0.98)
const C_PANEL_2 := Color(0.105, 0.118, 0.132, 1.0)
const C_LINE := Color(0.25, 0.30, 0.35, 1.0)
const C_TEXT := Color(0.92, 0.95, 0.97, 1.0)
const C_MUTED := Color(0.62, 0.68, 0.72, 1.0)
const C_ACCENT := Color(0.26, 0.58, 0.88, 1.0)
const C_ACCENT_HOVER := Color(0.34, 0.67, 0.96, 1.0)
const C_DANGER := Color(0.62, 0.18, 0.16, 1.0)
const C_DANGER_HOVER := Color(0.78, 0.23, 0.2, 1.0)

var _root: Control
var _window: PanelContainer
var _status_label: Label
var _battle_label: Label
var _currency_label: Label
var _speed_buttons: Array[Button] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 200
	_build_ui()
	_refresh()
	print("[SirWeHaveAModMenu] loaded. Press F1 to open the mod menu.")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_F1 and event.is_released() and not event.echo:
		_toggle_menu()
		get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if _window != null and _window.visible:
		_refresh()

func _toggle_menu() -> void:
	_window.visible = not _window.visible
	if _window.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_refresh()

func _build_ui() -> void:
	_root = Control.new()
	_root.name = "SirWeHaveAModMenuRoot"
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)

	_window = PanelContainer.new()
	_window.name = "Window"
	_window.visible = false
	_window.custom_minimum_size = WINDOW_SIZE
	_window.set_anchors_preset(Control.PRESET_CENTER)
	_window.offset_left = -WINDOW_SIZE.x * 0.5
	_window.offset_top = -WINDOW_SIZE.y * 0.5
	_window.offset_right = WINDOW_SIZE.x * 0.5
	_window.offset_bottom = WINDOW_SIZE.y * 0.5
	_window.mouse_filter = Control.MOUSE_FILTER_STOP
	_window.add_theme_stylebox_override("panel", _box(C_BG, C_LINE, 0, 8))
	_root.add_child(_window)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_window.add_child(margin)

	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	margin.add_child(body)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	body.add_child(header)

	var title_box := VBoxContainer.new()
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)

	var title := Label.new()
	title.text = "Mod Menu"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", C_TEXT)
	title_box.add_child(title)

	_status_label = Label.new()
	_status_label.text = "F1 toggles this menu"
	_status_label.add_theme_color_override("font_color", C_MUTED)
	title_box.add_child(_status_label)

	var close_btn := Button.new()
	close_btn.text = "Close"
	close_btn.custom_minimum_size = Vector2(84, 36)
	_style_button(close_btn, C_PANEL_2, C_LINE, C_ACCENT, C_ACCENT_HOVER)
	close_btn.pressed.connect(func() -> void: _window.visible = false)
	header.add_child(close_btn)

	_battle_label = _info_label("Battle: not in a battle")
	body.add_child(_battle_label)

	_currency_label = _info_label("Currencies: unavailable")
	body.add_child(_currency_label)

	body.add_child(_section_title("Currencies"))
	var currency_grid := GridContainer.new()
	currency_grid.columns = 3
	currency_grid.add_theme_constant_override("h_separation", 8)
	currency_grid.add_theme_constant_override("v_separation", 8)
	body.add_child(currency_grid)
	_add_action_button(currency_grid, "+100 Marks", func() -> void: _earn_currency(Currency.Type.UPGRADE_MARKS, 100))
	_add_action_button(currency_grid, "+1000 Marks", func() -> void: _earn_currency(Currency.Type.UPGRADE_MARKS, 1000))
	_add_action_button(currency_grid, "+1 Level Mark", func() -> void: _earn_currency(Currency.Type.LEVEL_FINISHED, 1))
	_add_action_button(currency_grid, "+5 Level Marks", func() -> void: _earn_currency(Currency.Type.LEVEL_FINISHED, 5))
	_add_action_button(currency_grid, "+1 Perfect Mark", func() -> void: _earn_currency(Currency.Type.ALL_KILLED_CHALLENGE, 1))
	_add_action_button(currency_grid, "Save", _save_progress)

	body.add_child(_section_title("Battle"))
	var battle_grid := GridContainer.new()
	battle_grid.columns = 3
	battle_grid.add_theme_constant_override("h_separation", 8)
	battle_grid.add_theme_constant_override("v_separation", 8)
	body.add_child(battle_grid)
	_add_action_button(battle_grid, "Heal Base", _heal_base)
	_add_action_button(battle_grid, "Toggle Pause", _toggle_pause)
	_add_action_button(battle_grid, "Win Battle", _win_battle)
	_add_action_button(battle_grid, "Kill Enemies", _clear_enemies)
	_add_action_button(battle_grid, "Start Wave", _start_wave)
	_add_action_button(battle_grid, "Reload Level", _reload_level)

	body.add_child(_section_title("Game Speed"))
	var speed_row := HBoxContainer.new()
	speed_row.add_theme_constant_override("separation", 8)
	body.add_child(speed_row)
	for speed in [0.5, 1.0, 2.0, 5.0]:
		_add_speed_button(speed_row, float(speed))

	body.add_child(_section_title("Dev Flags"))
	var flag_grid := GridContainer.new()
	flag_grid.columns = 3
	flag_grid.add_theme_constant_override("h_separation", 8)
	flag_grid.add_theme_constant_override("v_separation", 8)
	body.add_child(flag_grid)
	_add_action_button(flag_grid, "Enable Cheats", _enable_cheats)
	_add_action_button(flag_grid, "Refund On", func() -> void: _set_dev_flag("can_refund_upgrades", true))
	_add_action_button(flag_grid, "Skip End On", func() -> void: _set_dev_flag("skip_end_of_battle", true))
	_add_action_button(flag_grid, "Unlock Levels", _unlock_all_levels)
	_add_action_button(flag_grid, "Max Ready Upgrades", _max_ready_upgrades)
	_add_danger_button(flag_grid, "Reset Speed", func() -> void:
		Engine.time_scale = 1.0
		_refresh()
	)

	var footer := Label.new()
	footer.text = "Only the menu key is global. Battle actions are ignored outside battle scenes."
	footer.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer.add_theme_color_override("font_color", C_MUTED)
	body.add_child(footer)

func _section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", C_TEXT)
	return label

func _info_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", C_MUTED)
	return label

func _add_action_button(parent: Container, text: String, callback: Callable) -> void:
	var btn := _make_button(text)
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _add_danger_button(parent: Container, text: String, callback: Callable) -> void:
	var btn := _make_button(text)
	_style_button(btn, C_DANGER, Color(0.86, 0.33, 0.28), C_DANGER_HOVER, Color(0.9, 0.29, 0.24))
	btn.pressed.connect(callback)
	parent.add_child(btn)

func _make_button(text: String) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(128, 36)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(btn, C_PANEL_2, C_LINE, C_ACCENT, C_ACCENT_HOVER)
	return btn

func _add_speed_button(parent: Container, speed: float) -> void:
	var btn := _make_button("%sx" % speed)
	btn.pressed.connect(func() -> void:
		Engine.time_scale = speed
		_refresh()
	)
	_speed_buttons.append(btn)
	parent.add_child(btn)

func _style_button(btn: Button, normal: Color, border: Color, hover: Color, pressed: Color) -> void:
	btn.add_theme_stylebox_override("normal", _box(normal, border, 8, 6))
	btn.add_theme_stylebox_override("hover", _box(hover, border, 8, 6))
	btn.add_theme_stylebox_override("pressed", _box(pressed, border, 8, 6))
	btn.add_theme_stylebox_override("focus", _box(pressed, C_TEXT, 8, 6))
	btn.add_theme_color_override("font_color", C_TEXT)

func _box(bg: Color, border: Color, margin: int, radius: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.border_width_left = 1
	sb.border_width_top = 1
	sb.border_width_right = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius
	sb.content_margin_left = margin
	sb.content_margin_top = margin
	sb.content_margin_right = margin
	sb.content_margin_bottom = margin
	return sb

func _refresh() -> void:
	_status_label.text = "F1 toggles this menu | time scale %.1fx" % Engine.time_scale
	var battle := _get_battle()
	if battle == null:
		_battle_label.text = "Battle: not in a battle"
	else:
		_battle_label.text = "Battle: health %.0f | spawned %s/%s | killed %s | alive %s | paused %s" % [
			float(battle.get("health")),
			int(battle.get("total_enemies_spawned")),
			int(battle.get("total_enemies_to_spawn")),
			int(battle.get("total_enemies_killed")),
			int(battle.get("total_enemies_alive")),
			str(bool(battle.get("is_paused")))
		]

	var gm := _get_singleton("GameManager")
	if gm == null:
		_currency_label.text = "Currencies: GameManager unavailable"
	else:
		var amounts: Dictionary = gm.get("currency_amounts")
		_currency_label.text = "Currencies: marks %s | level %s | perfect %s" % [
			int(amounts.get(Currency.Type.UPGRADE_MARKS, 0)),
			int(amounts.get(Currency.Type.LEVEL_FINISHED, 0)),
			int(amounts.get(Currency.Type.ALL_KILLED_CHALLENGE, 0))
		]

	for btn: Button in _speed_buttons:
		btn.button_pressed = btn.text == "%sx" % Engine.time_scale

func _get_singleton(node_name: String) -> Node:
	return get_tree().root.get_node_or_null(node_name)

func _get_battle() -> Node:
	return get_tree().get_first_node_in_group("battle")

func _earn_currency(type: int, amount: int) -> void:
	var gm := _get_singleton("GameManager")
	if gm != null and gm.has_method("earn_currency"):
		gm.call("earn_currency", type, amount)
		_save_progress()
	_refresh()

func _save_progress() -> void:
	var save_system := _get_singleton("SaveSystem")
	if save_system != null and save_system.has_method("save_save_data"):
		save_system.call("save_save_data")

func _heal_base() -> void:
	var battle := _get_battle()
	if battle == null:
		return
	var max_health := 50.0
	var tech_tree := _get_singleton("TechTree")
	if tech_tree != null and tech_tree.has_method("get_upgrade"):
		var hp_1 = tech_tree.call("get_upgrade", &"base_hp")
		var hp_2 = tech_tree.call("get_upgrade", &"base_hp_2")
		if hp_1 != null:
			max_health += float(hp_1.current_value)
		if hp_2 != null:
			max_health += float(hp_2.current_value)
	battle.set("health", max_health)
	_refresh()

func _toggle_pause() -> void:
	var battle := _get_battle()
	if battle != null and battle.has_method("toggle_pause"):
		battle.call("toggle_pause")
	_refresh()

func _win_battle() -> void:
	var battle := _get_battle()
	if battle == null:
		return
	battle.set("health", max(float(battle.get("health")), 1.0))
	battle.set("total_enemies_spawned", int(battle.get("total_enemies_to_spawn")))
	battle.set("total_enemies_alive", 0)
	if battle.has_method("check_for_survival"):
		battle.call("check_for_survival")
	_refresh()

func _clear_enemies() -> void:
	var gpu := _get_singleton("GPUSim")
	if gpu != null and gpu.has_method("remove_rigidbodies_in_area"):
		gpu.call("remove_rigidbodies_in_area", Vector2(0, 0), 1000000.0)
	var battle := _get_battle()
	if battle != null:
		battle.set("total_enemies_alive", 0)
		if battle.has_signal("enemies_alive_updated"):
			battle.emit_signal("enemies_alive_updated", 0)
		if battle.has_method("check_for_survival"):
			battle.call("check_for_survival")
	_refresh()

func _start_wave() -> void:
	var battle := _get_battle()
	if battle != null and bool(battle.get("is_paused")) and battle.has_method("toggle_pause"):
		battle.call("toggle_pause")
	_refresh()

func _reload_level() -> void:
	var gm := _get_singleton("GameManager")
	if gm != null and gm.has_method("load_level"):
		gm.call("load_level", int(gm.get("selected_level")))

func _enable_cheats() -> void:
	_set_dev_flag("cheats_enabled", true)

func _set_dev_flag(property_name: String, value: bool) -> void:
	var dev := _get_singleton("DevOptions")
	if dev != null:
		dev.set(property_name, value)
	_refresh()

func _unlock_all_levels() -> void:
	var gm := _get_singleton("GameManager")
	if gm == null:
		return
	var progresses: Dictionary = gm.get("level_progresses")
	for level in progresses.keys():
		var progress = progresses[level]
		progress.is_unlocked = true
	_save_progress()
	_refresh()

func _max_ready_upgrades() -> void:
	var tech_tree := _get_singleton("TechTree")
	if tech_tree == null:
		return
	var upgrades: Dictionary = tech_tree.get("_upgrades")
	for upgrade in upgrades.values():
		if upgrade.state >= Upgrade.State.READY:
			upgrade.level = upgrade.data.max_level
			upgrade.change_state(Upgrade.State.LEVELED)
	if tech_tree.has_method("emit_upgrades_changed"):
		tech_tree.call("emit_upgrades_changed")
	_save_progress()
	_refresh()
