extends Control

# O Grande Livro dos Números: as 18 páginas recuperadas, os carimbos de ouro
# (estrelas) de cada uma e as cenas da história para rever.

const Story = preload("res://scripts/story.gd")
const Professor = preload("res://scripts/professor.gd")
const DialogueBox = preload("res://scripts/dialogue_box.gd")
const Lousa = preload("res://scripts/lousa.gd")
const UiStyle = preload("res://scripts/ui_style.gd")

const BG = Color("#0B1120")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")
const PAPER = Color("#F3EBD8")
const PAPER_DARK = Color("#E4D7B9")
const INK = Color("#3B2A1A")
const INK_SOFT = Color("#7A6248")
const LEATHER = Color("#7A4A26")

var dialogue
var page_overlay
var page_chapter
var page_title
var page_stamps
var page_stamps_label
var page_text
var page_lousa
var scene_button
var lesson_button
var prev_button
var next_button
var current_page = 0


func _ready():
	_build()
	Audio.play_music("menu")


func _build():
	Assets.make_background(self, "fundo_mapa", BG)

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 28)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 18)
	add_child(margin)

	var main = VBoxContainer.new()
	main.add_theme_constant_override("separation", 10)
	margin.add_child(main)

	var header = HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	main.add_child(header)

	var back = _button("← MAPA", Vector2(125, 44))
	back.pressed.connect(_on_back_pressed)
	header.add_child(back)

	var title = Label.new()
	title.text = "O Grande Livro dos Números"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", ACCENT)
	header.add_child(title)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(125, 44)
	header.add_child(spacer)

	var pages = GameState.get_pages_recovered()
	var stamps = 0
	for id in range(1, GameState.get_stage_count() + 1):
		stamps += GameState.get_best_stars(id)

	var counter = Label.new()
	counter.text = "PÁGINAS RECUPERADAS: %d/%d   •   CARIMBOS DE OURO: %d/%d" % [pages, GameState.get_stage_count(), stamps, GameState.get_stage_count() * 3]
	counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	counter.add_theme_font_size_override("font_size", 17)
	counter.add_theme_color_override("font_color", TEXT)
	main.add_child(counter)

	# Cenas que já foram vistas podem ser revistas.
	var scenes = HBoxContainer.new()
	scenes.alignment = BoxContainer.ALIGNMENT_CENTER
	scenes.add_theme_constant_override("separation", 12)
	main.add_child(scenes)
	if GameState.has_seen_story("prologo"):
		var prologue = _button("▶ REVER O PRÓLOGO", Vector2(210, 38), 14)
		prologue.pressed.connect(_play.bind(Story.prologue().filter(func(line): return not line.has("ask_name"))))
		scenes.add_child(prologue)
	if GameState.has_seen_story("pagina_18"):
		var ending = _button("▶ REVER O FINAL", Vector2(210, 38), 14)
		ending.pressed.connect(_play.bind(Story.epilogue()))
		scenes.add_child(ending)
	if scenes.get_child_count() == 0:
		var hint = Label.new()
		hint.text = "Vença as fases para recuperar as páginas que o Barão espalhou."
		hint.add_theme_font_size_override("font_size", 14)
		hint.add_theme_color_override("font_color", MUTED)
		scenes.add_child(hint)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)

	for chapter in range(6):
		grid.add_child(_chapter_card(chapter))

	_build_page_overlay()

	dialogue = DialogueBox.new()
	add_child(dialogue)


# ---------------------------------------------------------------------
# Capítulos
# ---------------------------------------------------------------------

func _chapter_card(chapter):
	var first_id = chapter * 3 + 1
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_theme_stylebox_override("panel", _paper_style(PAPER, LEATHER, 4))

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	card.add_child(box)

	var number = _label("CAPÍTULO %d" % (chapter + 1), 13, INK_SOFT)
	box.add_child(number)
	box.add_child(_label(Story.CHAPTER_NAMES[chapter], 20, INK))
	var found = GameState.get_pages_recovered(first_id, first_id + 2)
	box.add_child(_label("%s  •  %d/3 páginas" % [Story.WORLD_NAMES[chapter], found], 13, INK_SOFT))

	var pages = HBoxContainer.new()
	pages.add_theme_constant_override("separation", 8)
	box.add_child(pages)
	for stage_id in range(first_id, first_id + 3):
		pages.add_child(_page_tile(stage_id))

	if GameState.has_seen_story("mundo_%d" % (chapter + 1)):
		var intro = Button.new()
		intro.text = "▶ Rever a chegada em %s" % Story.WORLD_NAMES[chapter]
		intro.flat = true
		intro.add_theme_font_size_override("font_size", 13)
		intro.add_theme_color_override("font_color", LEATHER)
		intro.add_theme_color_override("font_hover_color", INK)
		intro.pressed.connect(_play.bind(Story.world_intro(chapter)))
		box.add_child(intro)

	return card


func _page_tile(stage_id):
	var recovered = GameState.is_stage_completed(stage_id)
	var tile = Button.new()
	tile.custom_minimum_size = Vector2(118, 132)
	tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tile.focus_mode = Control.FOCUS_NONE
	var style = _paper_style(Color("#FFF9EC") if recovered else PAPER_DARK, ACCENT if recovered else Color("#B9A98A"), 3 if recovered else 2)
	tile.add_theme_stylebox_override("normal", style)
	tile.add_theme_stylebox_override("hover", _paper_style(Color("#FFFDF5") if recovered else PAPER_DARK, ACCENT if recovered else Color("#B9A98A"), 4 if recovered else 2))
	tile.add_theme_stylebox_override("pressed", style)
	tile.add_theme_stylebox_override("disabled", style)
	tile.disabled = not recovered
	if recovered:
		tile.pressed.connect(_open_page.bind(stage_id))
	else:
		tile.tooltip_text = "Vença a fase %02d para recuperar esta página." % stage_id

	var content = VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 6
	content.offset_right = -6
	content.offset_top = 6
	content.offset_bottom = -6
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 4)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(content)

	content.add_child(_label("PÁG. %02d" % stage_id, 13, INK_SOFT if recovered else Color("#9C8C6E"), true))
	if recovered:
		content.add_child(_label(Story.page_name(stage_id), 15, INK, true))
		var stamps = Assets.make_star_row(GameState.get_best_stars(stage_id), 3, 20)
		if stamps != null:
			stamps.mouse_filter = Control.MOUSE_FILTER_IGNORE
			content.add_child(stamps)
	else:
		content.add_child(_label("?", 40, Color("#9C8C6E"), true))
		content.add_child(_label("página perdida", 12, Color("#9C8C6E"), true))
	return tile


# ---------------------------------------------------------------------
# Página aberta
# ---------------------------------------------------------------------

func _build_page_overlay():
	page_overlay = Control.new()
	page_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	page_overlay.visible = false
	add_child(page_overlay)

	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	page_overlay.add_child(shade)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_overlay.add_child(center)

	var paper = PanelContainer.new()
	paper.custom_minimum_size = Vector2(830, 0)
	paper.add_theme_stylebox_override("panel", _paper_style(PAPER, LEATHER, 6))
	center.add_child(paper)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	paper.add_child(box)

	page_chapter = _label("", 14, INK_SOFT, true)
	box.add_child(page_chapter)
	page_title = _label("", 26, INK, true)
	box.add_child(page_title)

	var stamp_row = HBoxContainer.new()
	stamp_row.alignment = BoxContainer.ALIGNMENT_CENTER
	stamp_row.add_theme_constant_override("separation", 10)
	box.add_child(stamp_row)
	page_stamps = HBoxContainer.new()
	stamp_row.add_child(page_stamps)
	page_stamps_label = _label("", 14, INK_SOFT)
	page_stamps_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	stamp_row.add_child(page_stamps_label)

	page_text = _label("", 19, INK, true)
	box.add_child(page_text)

	var board = PanelContainer.new()
	board.custom_minimum_size = Vector2(780, 420)
	board.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var board_style = StyleBoxFlat.new()
	board_style.bg_color = Color("#1F3A2E")
	board_style.border_color = Color("#8B5A2B")
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		board_style.set(side, 8)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		board_style.set(corner, 10)
	board.add_theme_stylebox_override("panel", board_style)
	box.add_child(board)

	page_lousa = Lousa.new()
	page_lousa.custom_minimum_size = Vector2(760, 400)
	page_lousa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_child(page_lousa)

	var actions = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 10)
	box.add_child(actions)

	prev_button = _button("◀", Vector2(56, 42))
	prev_button.pressed.connect(_step_page.bind(-1))
	actions.add_child(prev_button)

	scene_button = _button("▶ REVER A CENA", Vector2(190, 42), 14)
	scene_button.pressed.connect(_replay_page_scene)
	actions.add_child(scene_button)

	lesson_button = _button("AULA", Vector2(200, 42), 14)
	lesson_button.pressed.connect(_replay_lesson)
	actions.add_child(lesson_button)

	var close = _button("FECHAR", Vector2(130, 42), 14)
	close.pressed.connect(_close_page)
	actions.add_child(close)

	next_button = _button("▶", Vector2(56, 42))
	next_button.pressed.connect(_step_page.bind(1))
	actions.add_child(next_button)


func _open_page(stage_id):
	current_page = int(stage_id)
	var content = Story.page_content(current_page)
	var stars = GameState.get_best_stars(current_page)
	var stage = GameState.get_stage(current_page)

	page_chapter.text = "CAPÍTULO %d  •  %s  •  %s" % [Story.world_index(current_page) + 1, Story.chapter_name(current_page).to_upper(), Story.world_name(current_page)]
	page_title.text = "Página %02d — %s" % [current_page, Story.page_name(current_page)]
	page_text.text = UiStyle.tidy(content["text"])

	for child in page_stamps.get_children():
		child.queue_free()
	var row = Assets.make_star_row(stars, 3, 28)
	if row != null:
		page_stamps.add_child(row)
	page_stamps_label.text = "%d de 3 carimbos de ouro" % stars

	page_lousa.show_spec(content["board"])
	lesson_button.text = "AULA: %s" % Professor.TITLES.get(stage.get("operation", ""), "").to_upper()
	scene_button.visible = GameState.has_seen_story("pagina_%d" % current_page) and not Story.stage_victory(current_page).is_empty()
	prev_button.disabled = _neighbor_page(-1) == 0
	next_button.disabled = _neighbor_page(1) == 0
	page_overlay.visible = true


func _neighbor_page(direction):
	var id = current_page + direction
	while id >= 1 and id <= GameState.get_stage_count():
		if GameState.is_stage_completed(id):
			return id
		id += direction
	return 0


func _step_page(direction):
	var id = _neighbor_page(direction)
	if id > 0:
		_open_page(id)


func _close_page():
	page_overlay.visible = false


func _replay_page_scene():
	_play(Story.stage_victory(current_page))


func _replay_lesson():
	var stage = GameState.get_stage(current_page)
	_play(Professor.lesson(stage.get("operation", "addition"), false))


func _play(lines):
	if dialogue.is_open() or lines.is_empty():
		return
	dialogue.play(lines)


# ---------------------------------------------------------------------
# Navegação e estilos
# ---------------------------------------------------------------------

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")


func _unhandled_input(event):
	if not event.is_action_pressed("ui_cancel") or dialogue.is_open():
		return
	get_viewport().set_input_as_handled()
	if page_overlay.visible:
		_close_page()
	else:
		_on_back_pressed()


func _label(text_value, font_size, color, centered = false):
	var label = Label.new()
	label.text = UiStyle.tidy(text_value)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if centered:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text_value, min_size, font_size = 15):
	var button = Button.new()
	button.text = text_value
	button.custom_minimum_size = min_size
	UiStyle.button(button, "secondary", font_size)
	return button


func _paper_style(fill, border, width):
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, width)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 12)
	for side in ["content_margin_left", "content_margin_right", "content_margin_top", "content_margin_bottom"]:
		style.set(side, 14)
	return style
