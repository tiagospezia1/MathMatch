extends Control

const BG = Color("#0B1120")
const PANEL = Color("#172033")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")

var selected_difficulty = 1
var difficulty_label


func _ready():
	_build_interface()


func _build_interface():
	Assets.make_background(self, "fundo_menu", BG)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(690, 760)
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_top", 28)
	margin.add_theme_constant_override("margin_bottom", 28)
	panel.add_child(margin)

	var content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 14)
	margin.add_child(content)

	var dev_tag = Label.new()
	dev_tag.text = "MODO DESENVOLVEDOR"
	dev_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dev_tag.add_theme_font_size_override("font_size", 14)
	dev_tag.add_theme_color_override("font_color", ACCENT)
	content.add_child(dev_tag)

	var title = Label.new()
	title.text = "Testar mecânicas"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", TEXT)
	content.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Escolha a dificuldade e abra qualquer operação sem precisar desbloquear fases."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 15)
	subtitle.add_theme_color_override("font_color", MUTED)
	content.add_child(subtitle)

	difficulty_label = Label.new()
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty_label.add_theme_font_size_override("font_size", 16)
	difficulty_label.add_theme_color_override("font_color", ACCENT)
	content.add_child(difficulty_label)
	_update_difficulty_label()

	var difficulty_row = HBoxContainer.new()
	difficulty_row.alignment = BoxContainer.ALIGNMENT_CENTER
	difficulty_row.add_theme_constant_override("separation", 10)
	content.add_child(difficulty_row)

	_add_difficulty_button(difficulty_row, "FÁCIL", 1)
	_add_difficulty_button(difficulty_row, "MÉDIO", 2)
	_add_difficulty_button(difficulty_row, "DIFÍCIL", 3)

	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	content.add_child(grid)

	_add_phase_button(grid, "ADIÇÃO", "addition", "+")
	_add_phase_button(grid, "SUBTRAÇÃO", "subtraction", "−")
	_add_phase_button(grid, "MULTIPLICAÇÃO", "multiplication", "×")
	_add_phase_button(grid, "DIVISÃO", "division", "÷")
	_add_phase_button(grid, "FRAÇÃO", "fraction", "½")
	_add_phase_button(grid, "PORCENTAGEM", "percentage", "%")

	var classic = _make_button("TABULEIRO CLÁSSICO")
	classic.custom_minimum_size = Vector2(350, 48)
	classic.pressed.connect(_open_classic)
	content.add_child(classic)

	var info = Label.new()
	info.text = "No DEV, a resposta esperada fica visível. Dentro da fase, use CONCLUIR E AVANÇAR para creditar XP/pontuação, desbloquear e abrir a próxima fase automaticamente."
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_theme_font_size_override("font_size", 13)
	info.add_theme_color_override("font_color", Color("#8291A8"))
	content.add_child(info)

	var back = _make_button("← VOLTAR AO MENU")
	back.custom_minimum_size = Vector2(350, 48)
	back.pressed.connect(_on_back_pressed)
	content.add_child(back)


func _add_difficulty_button(parent, title, difficulty):
	var button = _make_button(title)
	button.custom_minimum_size = Vector2(135, 42)
	button.pressed.connect(_set_difficulty.bind(difficulty))
	parent.add_child(button)


func _set_difficulty(difficulty):
	selected_difficulty = int(difficulty)
	_update_difficulty_label()


func _update_difficulty_label():
	difficulty_label.text = "DIFICULDADE: " + GameState.get_difficulty_title(selected_difficulty)


func _add_phase_button(parent, title, mode, symbol):
	var button = _make_button(symbol + "   " + title)
	button.custom_minimum_size = Vector2(255, 70)
	button.pressed.connect(_open_phase.bind(mode))
	parent.add_child(button)


func _make_button(text_value):
	var button = Button.new()
	button.text = text_value
	button.add_theme_font_size_override("font_size", 16)
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
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = Color("#334155")
	return style


func _open_phase(mode):
	GameState.start_developer(mode, selected_difficulty)
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _open_classic():
	GameState.start_classic()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
