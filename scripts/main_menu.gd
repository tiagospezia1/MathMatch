extends Control

# Tela inicial: o Professor Aurélio recebe o jogador numa lousa, o menu é a
# capa do Grande Livro dos Números e o Barão Embaralho espia no canto.

const OptionsPanel = preload("res://scripts/options_panel.gd")
const DialogueBox = preload("res://scripts/dialogue_box.gd")
const UiStyle = preload("res://scripts/ui_style.gd")
const Story = preload("res://scripts/story.gd")

const BG = Color("#0B1120")
const FLOATING_PIECES = 12

var reset_dialog
var options_panel
var dialogue
var floaters = []
var baron


func _ready():
	randomize()
	_build_interface()
	Audio.play_music("menu")


func _build_interface():
	Assets.make_background(self, "fundo_menu", BG)
	_build_floaters()

	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 30)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 24)
	add_child(margin)

	var main = VBoxContainer.new()
	main.alignment = BoxContainer.ALIGNMENT_CENTER
	main.add_theme_constant_override("separation", 18)
	margin.add_child(main)

	var logo = Assets.make_logo("MathMatch", 78, UiStyle.GOLD, Vector2(600, 280))
	logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main.add_child(logo)
	if logo is Label:
		# Sem a imagem do logo, o título e o subtítulo são escritos com a fonte do jogo.
		logo.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		logo.add_theme_constant_override("shadow_offset_y", 4)
		main.add_child(UiStyle.label("As Páginas Roubadas", 28, UiStyle.PAPER))

	var columns = HBoxContainer.new()
	columns.alignment = BoxContainer.ALIGNMENT_CENTER
	columns.add_theme_constant_override("separation", 26)
	main.add_child(columns)

	columns.add_child(_professor_card())
	columns.add_child(_menu_book())

	_build_baron()

	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Resetar progresso"
	reset_dialog.dialog_text = "Isso apaga XP, nível, fases concluídas, recordes, estrelas, o tutorial e a história (incluindo o seu nome).\nEssa ação não pode ser desfeita. Continuar?"
	reset_dialog.ok_button_text = "Apagar tudo"
	reset_dialog.cancel_button_text = "Cancelar"
	reset_dialog.confirmed.connect(_on_reset_confirmed)
	add_child(reset_dialog)

	options_panel = OptionsPanel.new()
	add_child(options_panel)

	dialogue = DialogueBox.new()
	add_child(dialogue)


# ---------------------------------------------------------------------
# Lousa com o professor
# ---------------------------------------------------------------------

func _professor_card():
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(360, 0)
	card.add_theme_stylebox_override("panel", UiStyle.chalkboard(20))

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)

	var frame = PanelContainer.new()
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame.add_theme_stylebox_override("panel", UiStyle.box(Color("#F5F2EA"), Color.TRANSPARENT, 0, 16, 0))
	box.add_child(frame)
	var portrait = TextureRect.new()
	portrait.texture = Assets.texture("personagens/" + ("professor_orgulhoso" if GameState.get_pages_recovered() >= GameState.get_stage_count() else "professor_feliz"))
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(190, 190)
	frame.add_child(portrait)

	var bubble = PanelContainer.new()
	bubble.add_theme_stylebox_override("panel", UiStyle.box(UiStyle.PAPER, UiStyle.LEATHER_LIGHT, 2, 14, 12))
	box.add_child(bubble)
	bubble.add_child(UiStyle.label(_greeting(), 17, UiStyle.INK))

	var level = GameState.get_player_level()
	box.add_child(UiStyle.label("NÍVEL %d  •  %s" % [level, GameState.get_level_title(level).to_upper()], 15, UiStyle.GOLD))

	var pages = ProgressBar.new()
	pages.custom_minimum_size = Vector2(1, 12)
	pages.show_percentage = false
	pages.max_value = GameState.get_stage_count()
	pages.value = GameState.get_pages_recovered()
	pages.add_theme_stylebox_override("background", UiStyle.box(Color(0, 0, 0, 0.35), Color.TRANSPARENT, 0, 6, 0))
	pages.add_theme_stylebox_override("fill", UiStyle.box(UiStyle.GOLD, Color.TRANSPARENT, 0, 6, 0))
	box.add_child(pages)
	box.add_child(UiStyle.label("%d de %d páginas recuperadas" % [GameState.get_pages_recovered(), GameState.get_stage_count()], 14, UiStyle.MUTED))
	return card


func _greeting():
	var pages = GameState.get_pages_recovered()
	var total = GameState.get_stage_count()
	var player = str(GameState.player_name).strip_edges()
	if not GameState.tutorial_done:
		return "Olá! Eu sou o Professor Aurélio. Um vilão roubou as páginas do meu livro. Você me ajuda a recuperá-las?"
	if pages >= total:
		return "Mestre dos Números! O livro está completo. Obrigado, %s!" % (player if player != "" else "meu aprendiz")
	if pages == 0:
		return "Que bom ver você%s! A primeira página está na Vila do Pomar." % (", " + player if player != "" else "")
	return "Bem-vindo de volta%s! Já recuperamos %d páginas. Faltam %d." % [", " + player if player != "" else "", pages, total - pages]


# ---------------------------------------------------------------------
# Menu: a capa do livro
# ---------------------------------------------------------------------

func _menu_book():
	var book = PanelContainer.new()
	book.custom_minimum_size = Vector2(360, 0)
	book.add_theme_stylebox_override("panel", UiStyle.leather(24))

	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 12)
	book.add_child(box)

	box.add_child(UiStyle.label("~  O GRANDE LIVRO DOS NÚMEROS  ~", 13, UiStyle.GOLD))

	var play_text = "COMEÇAR A AVENTURA" if not GameState.tutorial_done else "CONTINUAR A JORNADA"
	var play = UiStyle.make_button(play_text, "primary", Vector2(0, 64), 21)
	play.pressed.connect(_on_play_pressed)
	box.add_child(play)

	if GameState.tutorial_done:
		var book_button = UiStyle.make_button("O LIVRO", "secondary", Vector2(0, 50))
		book_button.pressed.connect(_on_book_pressed)
		box.add_child(book_button)

	for entry in [["TUTORIAL", _on_tutorial_pressed], ["OPÇÕES", _on_options_pressed], ["CRÉDITOS", _on_credits_pressed]]:
		var button = UiStyle.make_button(entry[0], "secondary", Vector2(0, 50))
		button.pressed.connect(entry[1])
		box.add_child(button)

	var links = HBoxContainer.new()
	links.alignment = BoxContainer.ALIGNMENT_CENTER
	links.add_theme_constant_override("separation", 6)
	box.add_child(links)
	var how_to = UiStyle.make_button("Como jogar", "link", Vector2(0, 36), 16)
	how_to.pressed.connect(_on_how_to_pressed)
	links.add_child(how_to)
	var quit = UiStyle.make_button("Sair", "link", Vector2(0, 36), 16)
	quit.pressed.connect(_on_quit_pressed)
	links.add_child(quit)

	var reset = UiStyle.make_button("Resetar progresso", "danger", Vector2(0, 32), 14)
	reset.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	reset.pressed.connect(_on_reset_pressed)
	box.add_child(reset)

	# O modo desenvolvedor só aparece rodando pelo editor (ou em build de debug).
	# No jogo exportado em modo release ele some automaticamente.
	if OS.is_debug_build():
		var developer = UiStyle.make_button("Modo desenvolvedor", "link", Vector2(0, 30), 13)
		developer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		developer.add_theme_color_override("font_color", UiStyle.GOLD)
		developer.pressed.connect(_on_developer_pressed)
		box.add_child(developer)
	return book


# ---------------------------------------------------------------------
# Enfeites: peças flutuando e o Barão espiando
# ---------------------------------------------------------------------

func _build_floaters():
	var layer = Control.new()
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)
	for i in range(FLOATING_PIECES):
		var tex = Assets.texture("pecas/peca_%02d" % (i % 12 + 1))
		if tex == null:
			continue
		var piece = TextureRect.new()
		piece.texture = tex
		piece.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		piece.size = Vector2.ONE * randf_range(36, 60)
		piece.pivot_offset = piece.size / 2.0
		piece.position = Vector2(randf_range(0, 860), randf_range(0, 900))
		piece.rotation = randf_range(-0.4, 0.4)
		piece.modulate = Color(1, 1, 1, randf_range(0.12, 0.22))
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		piece.set_meta("speed", randf_range(12, 26))
		piece.set_meta("spin", randf_range(-0.25, 0.25))
		layer.add_child(piece)
		floaters.append(piece)


func _process(delta):
	var height = get_viewport_rect().size.y
	for piece in floaters:
		piece.position.y -= float(piece.get_meta("speed")) * delta
		piece.rotation += float(piece.get_meta("spin")) * delta
		if piece.position.y < -80:
			piece.position = Vector2(randf_range(0, get_viewport_rect().size.x - 40), height + 20)


func _build_baron():
	var tex = Assets.texture("personagens/barao_rindo")
	if tex == null:
		return
	baron = TextureRect.new()
	baron.texture = tex
	baron.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	baron.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	baron.size = Vector2(150, 150)
	baron.anchor_left = 1.0
	baron.anchor_top = 1.0
	baron.anchor_right = 1.0
	baron.anchor_bottom = 1.0
	baron.offset_left = -140
	baron.offset_top = -110
	baron.offset_right = 10
	baron.offset_bottom = 40
	baron.rotation = -0.18
	baron.tooltip_text = "Barão Embaralho"
	baron.gui_input.connect(_on_baron_input)
	add_child(baron)
	var bob = create_tween().set_loops()
	bob.tween_property(baron, "offset_top", -122.0, 1.6).set_trans(Tween.TRANS_SINE)
	bob.tween_property(baron, "offset_top", -110.0, 1.6).set_trans(Tween.TRANS_SINE)


func _on_baron_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not dialogue.is_open():
			dialogue.play(Story.baron_taunt(GameState.get_pages_recovered()))


# ---------------------------------------------------------------------
# Ações
# ---------------------------------------------------------------------

func _on_play_pressed():
	# Na primeira vez, o jogador passa pelo tutorial (Fase 0) antes do mapa.
	if not GameState.tutorial_done:
		_on_tutorial_pressed()
		return
	get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")


func _on_book_pressed():
	get_tree().change_scene_to_file("res://scenes/BookMenu.tscn")


func _on_tutorial_pressed():
	GameState.start_tutorial()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")


func _on_how_to_pressed():
	if not dialogue.is_open():
		dialogue.play(Story.how_to_play())


func _on_options_pressed():
	options_panel.open()


func _on_reset_pressed():
	reset_dialog.popup_centered()


func _on_reset_confirmed():
	GameState.reset_progress()
	# Recarrega o menu para atualizar o progresso e a fala do professor.
	get_tree().reload_current_scene()


func _on_developer_pressed():
	get_tree().change_scene_to_file("res://scenes/DeveloperMenu.tscn")


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/CreditsMenu.tscn")


func _on_quit_pressed():
	get_tree().quit()
