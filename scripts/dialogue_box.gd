extends Control

# Caixa de diálogo da história: retrato, nome, texto com efeito de digitação.
# Uso: dialogue.play(Story.prologue()) e esperar o sinal "finished".
# Clique, ENTER ou ESPAÇO: completa o texto ou passa para a próxima fala.
# ESC ou PULAR: pula o diálogo inteiro.

signal finished

const PANEL_COLOR = Color("#172033")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")
const NARRATION = Color("#DCE7F7")
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

var portrait
var portrait_frame
var name_label
var text_label
var name_row
var name_edit
var name_ok
var continue_button
var skip_button


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	visible = false
	set_process(false)


func is_open():
	return visible


func play(new_lines):
	lines = new_lines
	index = -1
	if lines.is_empty():
		finished.emit()
		return
	visible = true
	_next()


func _build():
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var panel = PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 24
	panel.offset_right = -24
	panel.offset_top = -290
	panel.offset_bottom = -24
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _panel_style())
	Assets.apply_panel(panel, "painel_janela")
	add_child(panel)

	var margin = MarginContainer.new()
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 26)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 22)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(margin)

	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(row)

	portrait_frame = PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(200, 200)
	portrait_frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	portrait_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	portrait_frame.add_theme_stylebox_override("panel", _portrait_style())
	row.add_child(portrait_frame)

	portrait = TextureRect.new()
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(200, 200)
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
	text_label.add_theme_font_size_override("font_size", 22)
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
	name_edit.text_changed.connect(_on_name_changed)
	name_edit.text_submitted.connect(_on_name_submitted)
	name_row.add_child(name_edit)

	name_ok = Button.new()
	name_ok.text = "OK"
	name_ok.custom_minimum_size = Vector2(90, 44)
	name_ok.disabled = true
	name_ok.pressed.connect(_confirm_name)
	Assets.apply_button(name_ok)
	name_row.add_child(name_ok)

	var actions = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_END
	actions.add_theme_constant_override("separation", 12)
	column.add_child(actions)

	skip_button = Button.new()
	skip_button.text = "PULAR"
	skip_button.custom_minimum_size = Vector2(120, 42)
	skip_button.add_theme_font_size_override("font_size", 15)
	skip_button.pressed.connect(_skip_all)
	Assets.apply_button(skip_button)
	actions.add_child(skip_button)

	continue_button = Button.new()
	continue_button.text = "CONTINUAR ▸"
	continue_button.custom_minimum_size = Vector2(190, 42)
	continue_button.add_theme_font_size_override("font_size", 16)
	continue_button.pressed.connect(_advance)
	Assets.apply_button(continue_button)
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

	var texture = null
	if SPEAKERS.has(who):
		var mood = str(line.get("mood", SPEAKERS[who]["default_mood"]))
		texture = Assets.texture("personagens/%s_%s" % [who, mood])
		if texture == null:
			texture = Assets.texture("personagens/%s_%s" % [who, SPEAKERS[who]["default_mood"]])
		name_label.text = SPEAKERS[who]["name"]
	else:
		name_label.text = "" if narration else who.to_upper()

	portrait.texture = texture
	portrait_frame.visible = texture != null
	name_label.visible = name_label.text != ""

	text_label.text = str(line.get("text", "")).replace("[NOME]", _player_name())
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if narration else HORIZONTAL_ALIGNMENT_LEFT
	text_label.add_theme_color_override("font_color", NARRATION if narration else TEXT)

	asking_name = bool(line.get("ask_name", false))
	name_row.visible = false
	continue_button.visible = not asking_name

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
	else:
		continue_button.grab_focus()


func _advance():
	if not visible or (asking_name and not typing):
		return
	if typing:
		_end_typing()
	else:
		_next()


func _skip_all():
	if asking_name:
		# O nome é necessário para as falas seguintes; usa o padrão se pular.
		_save_name(DEFAULT_NAME)
	_finish()


func _finish():
	typing = false
	set_process(false)
	asking_name = false
	visible = false
	finished.emit()


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
		if not asking_name:
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

func _panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = ACCENT
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, 2)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 16)
	return style


func _portrait_style():
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#F5F2EA")
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 14)
	return style
