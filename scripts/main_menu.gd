extends Control

const BG = Color("#111827")
const PANEL = Color("#1F2937")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F9FAFB")
const MUTED = Color("#CBD5E1")

const OptionsPanel = preload("res://scripts/options_panel.gd")

var info_label
var reset_dialog
var options_panel


func _ready():
	_build_interface()
	Audio.play_music("menu")


func _build_interface():
	Assets.make_background(self, "fundo_menu", BG)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 610)
	panel.add_theme_stylebox_override("panel", _make_panel_style())
	Assets.apply_panel(panel, "painel_menu")
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)

	var content = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 16)
	margin.add_child(content)

	var title = Assets.make_logo("MathMatch", 48, ACCENT)
	content.add_child(title)

	var subtitle = Label.new()
	subtitle.text = "Combine peças. Resolva desafios.\nAvance pela matemática."
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 19)
	subtitle.add_theme_color_override("font_color", MUTED)
	content.add_child(subtitle)

	var progress = GameState.get_level_progress()
	var profile = Label.new()
	profile.text = "NÍVEL %d  •  %d XP  •  FASE %02d LIBERADA" % [progress["level"], GameState.total_xp, GameState.unlocked_stage]
	profile.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	profile.add_theme_font_size_override("font_size", 14)
	profile.add_theme_color_override("font_color", ACCENT)
	content.add_child(profile)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(1, 10)
	content.add_child(spacer)

	var play = _make_menu_button("JOGAR")
	play.pressed.connect(_on_play_pressed)
	content.add_child(play)

	var tutorial = _make_menu_button("TUTORIAL")
	tutorial.pressed.connect(_on_tutorial_pressed)
	content.add_child(tutorial)

	var how_to = _make_menu_button("COMO JOGAR")
	how_to.pressed.connect(_on_how_to_pressed)
	content.add_child(how_to)

	var options = _make_menu_button("OPÇÕES")
	options.pressed.connect(_on_options_pressed)
	content.add_child(options)

	var reset = _make_menu_button("RESETAR PROGRESSO")
	reset.pressed.connect(_on_reset_pressed)
	reset.add_theme_color_override("font_color", Color("#FCA5A5"))
	reset.add_theme_color_override("font_hover_color", Color("#FCA5A5"))
	content.add_child(reset)

	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Resetar progresso"
	reset_dialog.dialog_text = "Isso apaga XP, nível, fases concluídas, recordes, estrelas e o tutorial.\nEssa ação não pode ser desfeita. Continuar?"
	reset_dialog.ok_button_text = "Apagar tudo"
	reset_dialog.cancel_button_text = "Cancelar"
	reset_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(reset_dialog)

	# O modo desenvolvedor só aparece rodando pelo editor (ou em build de debug).
	# No jogo exportado em modo release ele some automaticamente.
	if OS.is_debug_build():
		var developer = _make_menu_button("MODO DESENVOLVEDOR")
		developer.pressed.connect(_on_developer_pressed)
		developer.add_theme_color_override("font_color", ACCENT)
		developer.add_theme_color_override("font_hover_color", ACCENT)
		content.add_child(developer)

	var quit = _make_menu_button("SAIR")
	quit.pressed.connect(_on_quit_pressed)
	content.add_child(quit)

	info_label = Label.new()
	info_label.text = ""
	info_label.visible = false
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 15)
	info_label.add_theme_color_override("font_color", MUTED)
	content.add_child(info_label)


	options_panel = OptionsPanel.new()
	add_child(options_panel)


func _make_menu_button(label_text):
	var button = Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(320, 54)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_stylebox_override("normal", _button_style(Color("#374151")))
	button.add_theme_stylebox_override("hover", _button_style(Color("#4B5563")))
	button.add_theme_stylebox_override("pressed", _button_style(Color("#263244")))
	button.add_theme_stylebox_override("focus", _button_style(Color("#4B5563")))
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


func _make_panel_style():
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


func _on_play_pressed():
	# Na primeira vez, o jogador passa pelo tutorial (Fase 0) antes do mapa.
	if not GameState.tutorial_done:
		_on_tutorial_pressed()
		return
	get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")


func _on_tutorial_pressed():
	GameState.start_tutorial()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_how_to_pressed():
	info_label.visible = not info_label.visible
	info_label.text = "Selecione uma peça e depois uma peça vizinha para trocar.\nForme linhas ou colunas com 3 ou mais peças iguais.\nNas fases matemáticas, resolva o desafio e combine a peça com a resposta."


func _on_options_pressed():
	options_panel.open()


func _on_reset_pressed():
	reset_dialog.popup_centered()


func _on_reset_confirmed():
	GameState.reset_progress()
	# Recarrega o menu para atualizar a linha de nível/XP.
	get_tree().reload_current_scene()


func _on_developer_pressed():
	get_tree().change_scene_to_file("res://scenes/DeveloperMenu.tscn")


func _on_quit_pressed():
	get_tree().quit()
