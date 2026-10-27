extends Control

const BG = Color("#0B1120")
const PANEL = Color("#172033")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")
const PATH_COLOR = Color("#334155")
const COMPLETED_COLOR = Color("#22C55E")
const LOCKED_COLOR = Color("#1B2638")
const AVAILABLE_COLOR = Color("#334155")

const MAP_WIDTH = 780
const MAP_HEIGHT = 2460

var scroll
var map_canvas
var level_label
var xp_label
var xp_bar
var current_stage_label
var stage_positions = {}


func _ready():
	_build_interface()
	Audio.play_music("menu")
	call_deferred("_scroll_to_current_stage")


func _build_interface():
	Assets.make_background(self, "fundo_mapa", BG)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var main = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)

	var header = HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	header.add_theme_constant_override("separation", 16)
	main.add_child(header)

	var back = _make_rect_button("← MENU")
	back.custom_minimum_size = Vector2(125, 44)
	back.pressed.connect(_on_back_pressed)
	header.add_child(back)

	var title = Label.new()
	title.text = "Jornada MathMatch"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", ACCENT)
	header.add_child(title)

	var continue_button = _make_rect_button("CONTINUAR →")
	continue_button.custom_minimum_size = Vector2(145, 44)
	continue_button.pressed.connect(_on_continue_pressed)
	header.add_child(continue_button)

	var profile_panel = PanelContainer.new()
	profile_panel.add_theme_stylebox_override("panel", _panel_style())
	Assets.apply_panel(profile_panel)
	main.add_child(profile_panel)

	var profile_margin = MarginContainer.new()
	profile_margin.add_theme_constant_override("margin_left", 18)
	profile_margin.add_theme_constant_override("margin_right", 18)
	profile_margin.add_theme_constant_override("margin_top", 10)
	profile_margin.add_theme_constant_override("margin_bottom", 10)
	profile_panel.add_child(profile_margin)

	var profile = VBoxContainer.new()
	profile.add_theme_constant_override("separation", 5)
	profile_margin.add_child(profile)

	level_label = Label.new()
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 20)
	level_label.add_theme_color_override("font_color", TEXT)
	profile.add_child(level_label)

	current_stage_label = Label.new()
	current_stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	current_stage_label.add_theme_font_size_override("font_size", 14)
	current_stage_label.add_theme_color_override("font_color", ACCENT)
	profile.add_child(current_stage_label)

	xp_label = Label.new()
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_label.add_theme_font_size_override("font_size", 13)
	xp_label.add_theme_color_override("font_color", MUTED)
	profile.add_child(xp_label)

	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(1, 16)
	xp_bar.show_percentage = false
	profile.add_child(xp_bar)

	var hint = Label.new()
	hint.text = "Siga o caminho, complete as fases e desbloqueie os próximos desafios."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", MUTED)
	main.add_child(hint)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(scroll)

	map_canvas = Control.new()
	map_canvas.custom_minimum_size = Vector2(MAP_WIDTH, MAP_HEIGHT)
	scroll.add_child(map_canvas)

	_refresh_progress()
	_build_map()


func _refresh_progress():
	var progress = GameState.get_level_progress()
	var current_id = GameState.get_continue_stage()
	var current_data = GameState.get_stage(current_id)

	level_label.text = "NÍVEL %d  •  %d XP TOTAL" % [progress["level"], GameState.total_xp]
	xp_label.text = "%d / %d XP para o próximo nível" % [progress["current_xp"], progress["needed_xp"]]
	xp_bar.max_value = progress["needed_xp"]
	xp_bar.value = progress["current_xp"]

	if GameState.is_stage_completed(GameState.get_stage_count()):
		current_stage_label.text = "JORNADA CONCLUÍDA • Todas as 18 fases completas"
	elif not current_data.is_empty():
		current_stage_label.text = "VOCÊ ESTÁ NA FASE %02d • %s" % [current_id, current_data["title"]]


func _build_map():
	for child in map_canvas.get_children():
		child.queue_free()

	stage_positions.clear()

	for group_index in range(6):
		_create_world_section(group_index)

	for stage in GameState.STAGES:
		var stage_id = int(stage["id"])
		stage_positions[stage_id] = _get_stage_position(stage_id)

	_create_route_lines()

	for stage in GameState.STAGES:
		_create_stage_node(stage)

	_create_player_marker()
	_create_finish_marker()


func _create_world_section(group_index):
	var first_stage_id = group_index * 3 + 1
	var first_stage = GameState.get_stage(first_stage_id)
	if first_stage.is_empty():
		return

	var first_pos = _get_stage_position(first_stage_id)
	var section = PanelContainer.new()
	section.position = Vector2(18, first_pos.y - 88)
	section.size = Vector2(744, 350)
	section.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var section_style = StyleBoxFlat.new()
	if group_index % 2 == 0:
		section_style.bg_color = Color("#111C30")
	else:
		section_style.bg_color = Color("#132238")
	section_style.corner_radius_top_left = 24
	section_style.corner_radius_top_right = 24
	section_style.corner_radius_bottom_left = 24
	section_style.corner_radius_bottom_right = 24
	section_style.border_width_left = 1
	section_style.border_width_right = 1
	section_style.border_width_top = 1
	section_style.border_width_bottom = 1
	section_style.border_color = Color("#243650")
	section.add_theme_stylebox_override("panel", section_style)
	var world_tex = Assets.texture("mapa/mundo_%d" % (group_index + 1))
	if world_tex != null:
		section.add_theme_stylebox_override("panel", Assets.texture_style(world_tex))
	map_canvas.add_child(section)

	var world_label = Label.new()
	world_label.position = Vector2(42, first_pos.y - 72)
	world_label.size = Vector2(696, 36)
	world_label.text = "MUNDO %d  •  %s  %s" % [
		group_index + 1,
		_operation_symbol(first_stage["operation"]),
		GameState.get_mode_title(first_stage["operation"])
	]
	world_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_label.add_theme_font_size_override("font_size", 19)
	world_label.add_theme_color_override("font_color", Color("#DCE7F7"))
	world_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	map_canvas.add_child(world_label)


func _create_route_lines():
	var full_path = Line2D.new()
	full_path.width = 9.0
	full_path.default_color = PATH_COLOR
	full_path.z_index = 1
	map_canvas.add_child(full_path)

	for stage_id in range(1, GameState.get_stage_count() + 1):
		full_path.add_point(stage_positions[stage_id])

	var reached_stage = GameState.get_continue_stage()
	if reached_stage > 1:
		var reached_path = Line2D.new()
		reached_path.width = 9.0
		reached_path.default_color = COMPLETED_COLOR
		reached_path.z_index = 2
		map_canvas.add_child(reached_path)

		for stage_id in range(1, reached_stage + 1):
			reached_path.add_point(stage_positions[stage_id])


func _create_stage_node(stage):
	var stage_id = int(stage["id"])
	var pos = stage_positions[stage_id]
	var unlocked = stage_id <= GameState.unlocked_stage
	var completed = GameState.is_stage_completed(stage_id)
	var is_current = stage_id == GameState.get_continue_stage() and not GameState.is_stage_completed(GameState.get_stage_count())

	var button = Button.new()
	button.position = Vector2(pos.x - 43, pos.y - 43)
	button.size = Vector2(86, 86)
	button.focus_mode = Control.FOCUS_ALL
	button.z_index = 5

	if completed:
		button.text = "✓\n%02d" % stage_id
	elif not unlocked:
		button.text = "—\n%02d" % stage_id
	else:
		button.text = "%02d" % stage_id

	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color("#718096"))

	var fill_color = AVAILABLE_COLOR
	var border_color = Color("#64748B")
	var state_name = "fase_disponivel"
	if completed:
		state_name = "fase_concluida"
	elif is_current:
		state_name = "fase_atual"
	elif not unlocked:
		state_name = "fase_bloqueada"

	if completed:
		fill_color = Color("#166534")
		border_color = COMPLETED_COLOR
	elif is_current:
		fill_color = Color("#70560B")
		border_color = ACCENT
	elif not unlocked:
		fill_color = LOCKED_COLOR
		border_color = Color("#334155")

	button.add_theme_stylebox_override("normal", _stage_style(fill_color, border_color, 3))
	button.add_theme_stylebox_override("hover", _stage_style(fill_color.lightened(0.10), border_color, 4))
	button.add_theme_stylebox_override("pressed", _stage_style(fill_color.darkened(0.08), border_color, 4))
	button.add_theme_stylebox_override("focus", _stage_style(fill_color, ACCENT, 4))
	button.add_theme_stylebox_override("disabled", _stage_style(LOCKED_COLOR, Color("#334155"), 2))

	var node_tex = Assets.texture("mapa/" + state_name)
	if node_tex != null:
		button.add_theme_stylebox_override("normal", Assets.texture_style(node_tex))
		button.add_theme_stylebox_override("hover", Assets.texture_style(node_tex, 0, Color(1.1, 1.1, 1.1)))
		button.add_theme_stylebox_override("pressed", Assets.texture_style(node_tex, 0, Color(0.85, 0.85, 0.85)))
		button.add_theme_stylebox_override("disabled", Assets.texture_style(node_tex))
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
		button.add_theme_constant_override("outline_size", 5)

	button.disabled = not unlocked

	var best_score = GameState.get_best_score(stage_id)
	var best_stars = GameState.get_best_stars(stage_id)
	var status_text = "Disponível"
	if completed:
		status_text = "Concluída"
	elif not unlocked:
		status_text = "Bloqueada"

	var tooltip = "FASE %02d • %s\n%s • %s\n%d desafios • %d jogadas\n%s" % [
		stage_id,
		stage["title"],
		GameState.get_mode_title(stage["operation"]),
		GameState.get_difficulty_title(stage["difficulty"]),
		stage["required"],
		stage["moves"],
		status_text
	]

	if best_score > 0:
		tooltip += "\nRecorde: %d" % best_score
	if best_stars > 0:
		tooltip += "\nEstrelas: %s" % GameState.stars_text(best_stars)

	button.tooltip_text = tooltip

	if unlocked:
		button.pressed.connect(_open_stage.bind(stage_id))

	map_canvas.add_child(button)

	var info = Label.new()
	info.size = Vector2(210, 70)
	info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size", 13)
	info.add_theme_color_override("font_color", TEXT if unlocked else Color("#718096"))
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.z_index = 4

	var info_text = "%s\n%s" % [
		stage["title"],
		GameState.get_difficulty_title(stage["difficulty"])
	]

	if completed:
		if best_stars > 0:
			info_text += "  •  %s" % GameState.stars_text(best_stars)
		else:
			# Fases concluídas pelo modo dev ou por saves antigos não têm estrelas.
			info_text += "  •  ✓"
	elif not unlocked:
		info_text += "  •  BLOQUEADA"

	info.text = info_text

	if pos.x < MAP_WIDTH / 2:
		info.position = Vector2(pos.x + 58, pos.y - 34)
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	else:
		info.position = Vector2(pos.x - 268, pos.y - 34)
		info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

	map_canvas.add_child(info)


func _create_player_marker():
	var current_id = GameState.get_continue_stage()
	if not stage_positions.has(current_id):
		return

	var pos = stage_positions[current_id]

	var marker = Label.new()
	marker.position = Vector2(pos.x - 55, pos.y - 87)
	marker.size = Vector2(110, 34)
	marker.text = "▼  VOCÊ  ▼"
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.add_theme_font_size_override("font_size", 14)
	marker.add_theme_color_override("font_color", Color("#111827"))
	marker.add_theme_stylebox_override("normal", _marker_style())
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.z_index = 8
	map_canvas.add_child(marker)


func _create_finish_marker():
	var final_pos = _get_stage_position(GameState.get_stage_count())

	var finish = Label.new()
	finish.position = Vector2(170, final_pos.y + 78)
	finish.size = Vector2(440, 72)
	finish.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	finish.add_theme_font_size_override("font_size", 18)
	finish.add_theme_color_override("font_color", ACCENT)
	finish.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if GameState.is_stage_completed(GameState.get_stage_count()):
		finish.text = "★  MESTRE MATHMATCH  ★\nJornada concluída!"
	else:
		finish.text = "★  META: MESTRE MATHMATCH  ★\nComplete as 18 fases para chegar aqui."

	map_canvas.add_child(finish)


func _get_stage_position(stage_id):
	var x_values = [
		160, 350, 570,
		620, 420, 210,
		155, 350, 575,
		625, 425, 215,
		160, 365, 590,
		620, 405, 190
	]

	var group_index = int((stage_id - 1) / 3)
	var index_in_group = (stage_id - 1) % 3
	var y = 135 + group_index * 390 + index_in_group * 100
	var x = x_values[stage_id - 1]

	return Vector2(x, y)


func _scroll_to_current_stage():
	if scroll == null:
		return

	var current_id = GameState.get_continue_stage()
	if not stage_positions.has(current_id):
		return

	var target_y = int(stage_positions[current_id].y - 310)
	if target_y < 0:
		target_y = 0

	scroll.scroll_vertical = target_y


func _operation_symbol(operation):
	match operation:
		"addition":
			return "+"
		"subtraction":
			return "−"
		"multiplication":
			return "×"
		"division":
			return "÷"
		"fraction":
			return "½"
		"percentage":
			return "%"
		_:
			return "•"


func _stage_style(fill_color, border_color, border_width):
	var style = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.corner_radius_top_left = 43
	style.corner_radius_top_right = 43
	style.corner_radius_bottom_left = 43
	style.corner_radius_bottom_right = 43
	style.border_width_left = border_width
	style.border_width_right = border_width
	style.border_width_top = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	return style


func _marker_style():
	var style = StyleBoxFlat.new()
	style.bg_color = ACCENT
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


func _make_rect_button(text_value):
	var button = Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_stylebox_override("normal", _button_style(Color("#28364E")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#354764")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#202C40")))
	button.add_theme_stylebox_override("focus", _button_style(Color("#354764")))
	Assets.apply_button(button)
	return button


func _button_style(color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 11
	style.corner_radius_top_right = 11
	style.corner_radius_bottom_left = 11
	style.corner_radius_bottom_right = 11
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color("#334155")
	return style


func _open_stage(stage_id):
	if GameState.start_campaign_stage(stage_id):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_continue_pressed():
	_open_stage(GameState.get_continue_stage())


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
