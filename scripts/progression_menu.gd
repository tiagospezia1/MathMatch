extends Control

const Story = preload("res://scripts/story.gd")
const UiStyle = preload("res://scripts/ui_style.gd")

const BG = Color("#0B1120")
const PANEL = Color("#172033")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")
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
var pages_label
var pages_bar
var stage_positions = {}
var outer_margin


func _ready():
	_build_interface()
	Audio.play_music("menu")
	call_deferred("_scroll_to_current_stage")


func _build_interface():
	Assets.make_background(self, "fundo_mapa", BG)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_margin = margin
	_fit_width()
	resized.connect(_fit_width)
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

	var book_button = _make_rect_button("LIVRO")
	book_button.custom_minimum_size = Vector2(100, 44)
	book_button.tooltip_text = "O Grande Livro dos Números: páginas recuperadas e cenas para rever."
	book_button.pressed.connect(_on_book_pressed)
	header.add_child(book_button)

	var continue_button = _make_rect_button("CONTINUAR →")
	continue_button.custom_minimum_size = Vector2(145, 44)
	UiStyle.button(continue_button, "primary", 15)
	continue_button.pressed.connect(_on_continue_pressed)
	header.add_child(continue_button)

	var profile_panel = PanelContainer.new()
	profile_panel.add_theme_stylebox_override("panel", UiStyle.leather(4))
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

	# Contador do Grande Livro dos Números: uma página por fase concluída.
	pages_label = Label.new()
	pages_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pages_label.add_theme_font_size_override("font_size", 22)
	pages_label.add_theme_color_override("font_color", ACCENT)
	profile.add_child(pages_label)

	pages_bar = ProgressBar.new()
	pages_bar.custom_minimum_size = Vector2(1, 12)
	pages_bar.show_percentage = false
	pages_bar.add_theme_stylebox_override("fill", _bar_style(ACCENT))
	profile.add_child(pages_bar)

	level_label = Label.new()
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 17)
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
	hint.text = "Siga o caminho e recupere as páginas que o Barão Embaralho espalhou pelos seis lugares."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", MUTED)
	main.add_child(hint)

	scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(scroll)

	# O mapa fica no meio, mesmo com a tela larga.
	var map_center = CenterContainer.new()
	map_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(map_center)

	map_canvas = Control.new()
	map_canvas.custom_minimum_size = Vector2(MAP_WIDTH, MAP_HEIGHT)
	map_center.add_child(map_canvas)

	_refresh_progress()
	_build_map()


# Em tela larga, a coluna do mapa mantém a largura de uma tela quadrada e fica no meio.
func _fit_width():
	if outer_margin == null:
		return
	var side = 34 + max(0, int((size.x - 900) / 2))
	outer_margin.add_theme_constant_override("margin_left", side)
	outer_margin.add_theme_constant_override("margin_right", side)


func _refresh_progress():
	var progress = GameState.get_level_progress()
	var current_id = GameState.get_continue_stage()
	var current_data = GameState.get_stage(current_id)

	var pages = GameState.get_pages_recovered()
	var total_pages = GameState.get_stage_count()
	pages_label.text = "PÁGINAS RECUPERADAS: %d/%d" % [pages, total_pages]
	pages_bar.max_value = total_pages
	pages_bar.value = pages

	level_label.text = "NÍVEL %d  •  %s  •  %d XP TOTAL" % [progress["level"], GameState.get_level_title(progress["level"]).to_upper(), GameState.total_xp]
	xp_label.text = "%d / %d XP para o próximo nível" % [progress["current_xp"], progress["needed_xp"]]
	xp_bar.max_value = progress["needed_xp"]
	xp_bar.value = progress["current_xp"]

	if GameState.is_stage_completed(GameState.get_stage_count()):
		current_stage_label.text = "JORNADA CONCLUÍDA • O Grande Livro dos Números está completo!"
	elif not current_data.is_empty():
		current_stage_label.text = "VOCÊ ESTÁ NA FASE %02d • %s • %s" % [current_id, current_data["title"], Story.world_name(current_id)]


func _build_map():
	for child in map_canvas.get_children():
		child.queue_free()

	stage_positions.clear()

	var parchment = Assets.texture("mapa/pergaminho")
	if parchment != null:
		var paper = TextureRect.new()
		paper.texture = parchment
		paper.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		paper.stretch_mode = TextureRect.STRETCH_SCALE
		paper.size = Vector2(MAP_WIDTH, MAP_HEIGHT)
		paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
		map_canvas.add_child(paper)

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
	var region_top = first_pos.y - 95

	# Lugar ainda não alcançado: um pedaço de papel cobre essa parte do mapa.
	if first_stage_id > GameState.unlocked_stage:
		var hidden_tex = Assets.texture("mapa/regiao_oculta")
		if hidden_tex != null:
			var cover = TextureRect.new()
			cover.texture = hidden_tex
			cover.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			cover.stretch_mode = TextureRect.STRETCH_SCALE
			cover.position = Vector2(10, region_top + 2)
			cover.size = Vector2(760, 384)
			cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cover.z_index = 6
			map_canvas.add_child(cover)

	# Faixa com o nome do lugar, como uma etiqueta colada no mapa.
	var world_label = Label.new()
	world_label.position = Vector2(80, region_top + 4)
	world_label.size = Vector2(620, 38)
	var world_pages = GameState.get_pages_recovered(first_stage_id, first_stage_id + 2)
	# Sem o símbolo da operação: o "−" da subtração parecia um traço sobrando.
	world_label.text = "%s  •  %s  •  PÁGINAS %d/3" % [
		Story.WORLD_NAMES[group_index].to_upper(),
		GameState.get_mode_title(first_stage["operation"]),
		world_pages
	]
	world_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	world_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	world_label.add_theme_font_size_override("font_size", 17)
	world_label.add_theme_color_override("font_color", UiStyle.INK)
	world_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var band = UiStyle.box(UiStyle.PAPER, UiStyle.LEATHER_LIGHT, 2, 8, 6)
	band.shadow_color = Color(0, 0, 0, 0.25)
	band.shadow_size = 4
	world_label.add_theme_stylebox_override("normal", band)
	world_label.z_index = 7
	# A faixa do título tem tamanho fixo; o texto não acompanha a opção de tamanho.
	world_label.set_meta("fixed_text_size", true)
	map_canvas.add_child(world_label)


func _create_route_lines():
	var points = []
	for stage_id in range(1, GameState.get_stage_count() + 1):
		points.append(stage_positions[stage_id])
	var road = MapRoad.new()
	road.size = Vector2(MAP_WIDTH, MAP_HEIGHT)
	road.mouse_filter = Control.MOUSE_FILTER_IGNORE
	road.z_index = 1
	road.setup(points, GameState.get_continue_stage() - 1)
	map_canvas.add_child(road)


# Estrada do mapa: uma curva suave passando pelas fases. O trecho já percorrido
# é uma linha de tinta vermelha; o resto, um tracejado marrom.
class MapRoad extends Control:
	const ROAD = Color("#7A5A3A")
	const DONE = Color("#9E2F26")
	var curve = []
	var reached_index = 0

	func setup(points, reached):
		reached_index = reached
		curve.clear()
		for i in range(points.size() - 1):
			var p0 = points[max(i - 1, 0)]
			var p1 = points[i]
			var p2 = points[i + 1]
			var p3 = points[min(i + 2, points.size() - 1)]
			var piece = []
			for k in range(16):
				var t = k / 16.0
				# Catmull-Rom: passa exatamente por cada fase.
				piece.append(0.5 * ((2.0 * p1) + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t * t + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t * t * t))
			curve.append(piece)
		curve.append([points[points.size() - 1]])
		queue_redraw()

	func _draw():
		for i in range(curve.size() - 1):
			var piece = curve[i] + [curve[i + 1][0]]
			if i < reached_index:
				draw_polyline(PackedVector2Array(piece), DONE, 6.0, true)
			else:
				_dashed(piece)

	func _dashed(piece):
		var carry = 0.0
		for k in range(piece.size() - 1):
			var a = piece[k]
			var b = piece[k + 1]
			var length = a.distance_to(b)
			var dir = (b - a).normalized()
			var d = carry
			while d < length:
				var end = min(d + 12.0, length)
				draw_line(a + dir * d, a + dir * end, ROAD, 5.0, true)
				d += 22.0
			carry = d - length


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
	# Selo de cera e moeda: número claro. Papel e pedra: número em tinta.
	var light_text = completed or is_current
	var number_color = TEXT if light_text else UiStyle.INK
	button.add_theme_color_override("font_color", number_color)
	button.add_theme_color_override("font_hover_color", number_color)
	button.add_theme_color_override("font_pressed_color", number_color)
	button.add_theme_color_override("font_disabled_color", UiStyle.INK_SOFT)

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
		if light_text:
			button.add_theme_color_override("font_outline_color", Color(0.2, 0.08, 0.02, 0.85))
			button.add_theme_constant_override("outline_size", 5)

	button.disabled = not unlocked

	var best_score = GameState.get_best_score(stage_id)
	var best_stars = GameState.get_best_stars(stage_id)
	var status_text = "Disponível"
	if completed:
		status_text = "Concluída"
	elif not unlocked:
		status_text = "Bloqueada"

	var tooltip = "FASE %02d • %s\nPágina %d do livro • %s\n%s • %s\n%d desafios • %d jogadas\n%s" % [
		stage_id,
		stage["title"],
		stage_id,
		Story.world_name(stage_id),
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
	info.add_theme_color_override("font_color", UiStyle.INK if unlocked else UiStyle.INK_SOFT)
	# Contorno cor de papel: o texto continua legível por cima dos desenhos do mapa.
	info.add_theme_color_override("font_outline_color", Color("#F3E6C4"))
	info.add_theme_constant_override("outline_size", 5)
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
	marker.size = Vector2(110, 34)
	# Na primeira fase de cada lugar, a faixa com o nome fica logo acima:
	# o selo vai para baixo da fase para não cobrir o texto.
	if (current_id - 1) % 3 == 0:
		marker.position = Vector2(pos.x - 55, pos.y + 50)
		marker.text = "▲  VOCÊ  ▲"
	else:
		marker.position = Vector2(pos.x - 55, pos.y - 87)
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
	finish.add_theme_color_override("font_color", UiStyle.LEATHER)
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
	UiStyle.button(button, "secondary", 15)
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


func _open_stage(stage_id):
	if GameState.start_campaign_stage(stage_id):
		get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_continue_pressed():
	_open_stage(GameState.get_continue_stage())


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_book_pressed():
	get_tree().change_scene_to_file("res://scenes/BookMenu.tscn")


func _bar_style(color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	return style
