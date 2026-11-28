extends Control

# Caixa de diálogo da história e das aulas: retrato, nome, texto com efeito
# de digitação e, quando a fala pede, a lousa do professor e exercícios.
# Uso: dialogue.play(linhas) e esperar o sinal "finished".
# Clique, ENTER ou ESPAÇO: completa o texto ou passa para a próxima fala.
# ESC ou PULAR: pula o diálogo inteiro (quando permitido).
#
# Campos de cada fala:
#   who, mood, text   quem fala, a expressão e o texto ([NOME] = nome do jogador)
#   ask_name          pede o nome do jogador
#   board             desenho da lousa (veja lousa.gd)
#   quiz              exercício: choices, answer, feedback, right, solution, solution_board
#   menu              lista de opções; a escolhida fica em "choice"

signal finished

const Lousa = preload("res://scripts/lousa.gd")
const UiStyle = preload("res://scripts/ui_style.gd")

const PANEL_COLOR = Color("#F3EBD8")
const ACCENT = Color("#8A5A1E")
const TEXT = Color("#3B2A1A")
const MUTED = Color("#7A6248")
const NARRATION = Color("#5C4630")
const BOARD_COLOR = Color("#1F3A2E")
const BOARD_FRAME = Color("#8B5A2B")
const CHARS_PER_SECOND = 55.0
const DEFAULT_NAME = "Aprendiz"

const SPEAKERS = {
	"professor": {"name": "PROFESSOR AURÉLIO", "default_mood": "feliz"},
	"barao": {"name": "BARÃO EMBARALHO", "default_mood": "rindo"}
}

var lines = []
var index = -1
var typing = false
var shown_chars = 0.0
var asking_name = false
var can_skip = true

# Exercício / menu da fala atual
var quiz = {}
var quiz_wrong = 0
var waiting_choice = false
var choice = -1

var portrait
var portrait_frame
var name_label
var text_label
var name_row
var name_edit
var name_ok
var choices_row
var continue_button
var skip_button
var board_panel
var dialog_panel
var lousa


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	visible = false
	set_process(false)


func is_open():
	return visible


func play(new_lines, skippable = true):
	lines = new_lines
	index = -1
	choice = -1
	can_skip = skippable
	skip_button.visible = can_skip
	if lines.is_empty():
		finished.emit()
		return
	visible = true
	_next()


func _build():
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	# Lousa do professor (só aparece nas falas com "board").
	board_panel = PanelContainer.new()
	board_panel.anchor_right = 1.0
	board_panel.offset_left = 40
	board_panel.offset_right = -40
	board_panel.offset_top = 28
	board_panel.offset_bottom = 548
	board_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_panel.add_theme_stylebox_override("panel", _board_style())
	board_panel.visible = false
	add_child(board_panel)

	lousa = Lousa.new()
	lousa.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board_panel.add_child(lousa)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = -296
	panel.offset_bottom = -24
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Uma página do Grande Livro: papel com borda de couro.
	panel.add_theme_stylebox_override("panel", UiStyle.paper(0))
	add_child(panel)
	dialog_panel = panel
	_fit_width()
	resized.connect(_fit_width)

	var margin = MarginContainer.new()
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 26)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 20)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	portrait_frame = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(170, 170)
	portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel", _portrait_style())
	row.add_child(portrait_frame)

	portrait = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(170, 170)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_child(portrait)

	var column = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(column)

	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", ACCENT)
	column.add_child(name_label)

	text_label = Label.new()
	text_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.add_theme_font_size_override("font_size", 21)
	text_label.add_theme_color_override("font_color", TEXT)
	column.add_child(text_label)

	name_row = HBoxContainer.new()
	name_row.add_theme_constant_override("separation", 10)
	name_row.visible = false
	column.add_child(name_row)

	name_edit = LineEdit.new()
	name_edit.placeholder_text = "Digite seu nome"
	name_edit.max_length = 16
	name_edit.custom_minimum_size = Vector2(260, 44)
	name_edit.add_theme_font_size_override("font_size", 20)
	# Campo do nome no estilo das páginas do livro.
	name_edit.add_theme_stylebox_override("normal", UiStyle.box(Color("#FFF8E6"), UiStyle.LEATHER_LIGHT, 2, 10, 10))
	name_edit.add_theme_stylebox_override("focus", UiStyle.box(Color("#FFF8E6"), UiStyle.GOLD_DARK, 3, 10, 10))
	name_edit.add_theme_color_override("font_color", UiStyle.INK)
	name_edit.add_theme_color_override("font_placeholder_color", UiStyle.INK_SOFT)
	name_edit.add_theme_color_override("caret_color", UiStyle.INK)
	name_edit.text_changed.connect(_on_name_changed)
	name_edit.text_submitted.connect(_on_name_submitted)
	name_row.add_child(name_edit)

	name_ok = Button.new()
	name_ok.text = "OK"
	name_ok.custom_minimum_size = Vector2(90, 44)
	name_ok.disabled = true
	name_ok.pressed.connect(_confirm_name)
	UiStyle.button(name_ok, "primary", 18)
	name_row.add_child(name_ok)

	choices_row = HBoxContainer.new()
	choices_row.add_theme_constant_override("separation", 12)
	choices_row.visible = false
	column.add_child(choices_row)

	var actions = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 12)
	column.add_child(actions)

	skip_button = Button.new()
	skip_button.text = "PULAR"
	skip_button.custom_minimum_size = Vector2(120, 42)
	skip_button.add_theme_font_size_override("font_size", 15)
	skip_button.pressed.connect(_skip_all)
	UiStyle.button(skip_button, "secondary", 15)
	actions.add_child(skip_button)

	continue_button = Button.new()
	continue_button.text = "CONTINUAR ▸"
	continue_button.custom_minimum_size = Vector2(190, 42)
	continue_button.add_theme_font_size_override("font_size", 16)
	continue_button.pressed.connect(_advance)
	UiStyle.button(continue_button, "primary", 16)
	actions.add_child(continue_button)


# ---------------------------------------------------------------------
# Andamento
# ---------------------------------------------------------------------

func _next():
	index += 1
	if index >= lines.size():
		_finish()
		return
	_show_line(lines[index])


func _show_line(line):
	var who = str(line.get("who", "narracao"))
	var narration = who == "narracao"

	if SPEAKERS.has(who):
		_set_portrait(who, str(line.get("mood", SPEAKERS[who]["default_mood"])))
		name_label.text = SPEAKERS[who]["name"]
	else:
		portrait.texture = null
		portrait_frame.visible = false
		name_label.text = "" if narration else who.to_upper()
	name_label.visible = name_label.text != ""

	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narration else HORIZONTAL_ALIGNMENT_LEFT
	text_label.add_theme_color_override("font_color", NARRATION if narration else TEXT)

	if line.has("board"):
		board_panel.visible = true
		lousa.show_spec(line["board"], bool(line.get("board_animate", true)))
	else:
		board_panel.visible = false

	asking_name = bool(line.get("ask_name", false))
	name_row.visible = false
	# Sem retrato (narração), a caixa fica mais baixa: não sobra espaço vazio.
	dialog_panel.offset_top = -296 if portrait_frame.visible else -240
	# Na hora de digitar o nome, PULAR some: quem clica em sequência não pula o nome sem ver.
	skip_button.visible = can_skip and not asking_name

	quiz = line.get("quiz", {})
	quiz_wrong = 0
	_clear_choices()
	if not quiz.is_empty():
		for value in quiz.get("choices", []):
			_add_choice(str(value), _on_quiz_choice.bind(int(value)))
	elif line.has("menu"):
		var options = line["menu"]
		for i in range(options.size()):
			_add_choice(str(options[i]), _on_menu_choice.bind(i))
	waiting_choice = choices_row.get_child_count() > 0
	continue_button.visible = not asking_name and not waiting_choice

	_type(str(line.get("text", "")))


func _type(value):
	text_label.text = UiStyle.tidy(value.replace("[NOME]", _player_name()))
	shown_chars = 0.0
	text_label.visible_characters = 0
	typing = true
	set_process(true)


func _process(delta):
	if not typing:
		return
	shown_chars += CHARS_PER_SECOND * delta
	text_label.visible_characters = int(shown_chars)
	if text_label.visible_characters >= text_label.get_total_character_count():
		_end_typing()


func _end_typing():
	typing = false
	set_process(false)
	text_label.visible_characters = -1
	if asking_name:
		name_row.visible = true
		name_edit.text = ""
		name_ok.disabled = true
		name_edit.grab_focus()
	elif choices_row.get_child_count() > 0:
		choices_row.visible = true
		if not waiting_choice:
			continue_button.grab_focus()
	else:
		continue_button.grab_focus()


func _advance():
	if not visible or (asking_name and not typing):
		return
	if typing:
		_end_typing()
	elif not waiting_choice:
		_next()


func _skip_all():
	if not can_skip:
		return
	if asking_name:
		# O nome é necessário para as falas seguintes; usa o padrão se pular.
		_save_name(DEFAULT_NAME)
	_finish()


func _finish():
	typing = false
	set_process(false)
	asking_name = false
	waiting_choice = false
	_clear_choices()
	board_panel.visible = false
	visible = false
	finished.emit()


func _set_portrait(who, mood):
	var texture = Assets.texture("personagens/%s_%s" % [who, mood])
	if texture == null and SPEAKERS.has(who):
		texture = Assets.texture("personagens/%s_%s" % [who, SPEAKERS[who]["default_mood"]])
	portrait.texture = texture
	portrait_frame.visible = texture != null


# ---------------------------------------------------------------------
# Exercícios e menus
# ---------------------------------------------------------------------

func _clear_choices():
	for child in choices_row.get_children():
		choices_row.remove_child(child)
		child.queue_free()
	choices_row.visible = false


func _add_choice(label_text, callback):
	var button = Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(96 if label_text.length() <= 3 else 150, 46)
	button.add_theme_font_size_override("font_size", 22 if label_text.length() <= 3 else 15)
	button.set_meta("no_click_sound", true)
	button.pressed.connect(callback)
	UiStyle.button(button, "secondary", 22 if label_text.length() <= 3 else 15)
	# Nenhuma opção começa destacada, para não parecer que já está escolhida.
	button.focus_mode = Control.FOCUS_NONE
	choices_row.add_child(button)


func _on_menu_choice(option_index):
	Audio.play("clique")
	choice = option_index
	waiting_choice = false
	_next()


func _on_quiz_choice(value):
	if not waiting_choice:
		return
	var answer = int(quiz.get("answer", -1))
	var button = _choice_button(value)

	if value == answer:
		Audio.play("acerto")
		if button != null:
			button.modulate = Color("#86EFAC")
		_close_quiz()
		_set_portrait("professor", "orgulhoso")
		if quiz.has("solution_board"):
			lousa.show_spec(quiz["solution_board"])
		_type(str(quiz.get("right", "Isso!")))
		return

	Audio.play("troca_invalida")
	quiz_wrong += 1
	if button != null:
		button.disabled = true
		button.modulate = Color("#FCA5A5")
	var feedback = str(quiz.get("feedback", {}).get(str(value), "Ainda não. Tente de novo."))

	if quiz_wrong >= 2:
		# Segunda tentativa errada: o professor resolve junto e mostra a resposta.
		_close_quiz()
		var right_button = _choice_button(answer)
		if right_button != null:
			right_button.modulate = Color("#86EFAC")
		_set_portrait("professor", "explicando")
		if quiz.has("solution_board"):
			lousa.show_spec(quiz["solution_board"])
		_type("%s Vamos resolver juntos: %s" % [feedback, str(quiz.get("solution", ""))])
	else:
		_set_portrait("professor", "preocupado")
		_type(feedback)


func _choice_button(value):
	for button in choices_row.get_children():
		if button.text == str(value):
			return button
	return null


func _close_quiz():
	waiting_choice = false
	for button in choices_row.get_children():
		button.disabled = true
	continue_button.visible = true


# ---------------------------------------------------------------------
# Nome do jogador
# ---------------------------------------------------------------------

func _player_name():
	var saved = str(GameState.player_name).strip_edges()
	return saved if saved != "" else DEFAULT_NAME


func _on_name_changed(new_text):
	name_ok.disabled = new_text.strip_edges() == ""


func _on_name_submitted(_text):
	_confirm_name()


func _confirm_name():
	var typed = name_edit.text.strip_edges()
	if typed == "":
		return
	_save_name(typed)
	asking_name = false
	name_row.visible = false
	_next()


func _save_name(value):
	GameState.set_player_name(value)


# ---------------------------------------------------------------------
# Entrada
# ---------------------------------------------------------------------

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if not asking_name and (typing or not waiting_choice):
			Audio.play("clique")
			_advance()


func _unhandled_input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_skip_all()
	elif event.is_action_pressed("ui_accept") and not asking_name:
		get_viewport().set_input_as_handled()
		_advance()


# ---------------------------------------------------------------------
# Estilos
# ---------------------------------------------------------------------

# Em tela larga, a lousa e a caixa de fala não passam de 1000 de largura e ficam no meio.
func _fit_width():
	if dialog_panel == null:
		return
	var extra = max(0, int((size.x - 1000) / 2))
	board_panel.offset_left = 40 + extra
	board_panel.offset_right = -40 - extra
	dialog_panel.offset_left = 24 + extra
	dialog_panel.offset_right = -24 - extra


func _board_style():
	var style = StyleBoxFlat.new()
	style.bg_color = BOARD_COLOR
	style.border_color = BOARD_FRAME
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, 10)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 12)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 10
	return style


func _portrait_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#FFF8E6")
	style.border_color = UiStyle.LEATHER_LIGHT
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, 3)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 14)
	return style
