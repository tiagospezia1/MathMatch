extends Control

# Créditos do MathMatch: sobem pela tela como no fim de um filme.
# Segurar o clique (ou ESPAÇO) acelera. Quem já terminou o jogo vê, no
# final, a página misteriosa do Capítulo 7.

const Story = preload("res://scripts/story.gd")
const DialogueBox = preload("res://scripts/dialogue_box.gd")
const UiStyle = preload("res://scripts/ui_style.gd")

const BG = Color("#0B1120")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")
const PAPER = Color("#F3EBD8")
const INK = Color("#3B2A1A")
const LEATHER = Color("#7A4A26")
const SCROLL_SPEED = 55.0

const TEAM = [
	"Tiago Spezia",
	"Matheus Machado",
	"Samuel Ballock",
	"Eduardo de Souza",
	"Mateus Wroblewski"
]

var viewport_clip
var content
var roll_tween
var dialogue
var end_box
var mystery_card
var speed_hint


func _ready():
	_build()
	Audio.play_music("menu")
	await get_tree().process_frame
	await get_tree().process_frame
	_roll()


func _build():
	Assets.make_background(self, "fundo_menu", BG)

	viewport_clip = Control.new()
	viewport_clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	viewport_clip.clip_contents = true
	viewport_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(viewport_clip)

	content = VBoxContainer.new()
	content.custom_minimum_size = Vector2(700, 0)
	content.add_theme_constant_override("separation", 10)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport_clip.add_child(content)

	var logo = Assets.make_logo("MathMatch", 64, ACCENT, Vector2(640, 300))
	logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(logo)
	content.add_child(_line("Combine peças. Resolva desafios. Avance pela matemática.", 18, MUTED))
	content.add_child(_space(30))

	var portraits = HBoxContainer.new()
	portraits.alignment = BoxContainer.ALIGNMENT_CENTER
	portraits.add_theme_constant_override("separation", 60)
	content.add_child(portraits)
	portraits.add_child(_portrait("personagens/professor_orgulhoso", "Professor Aurélio"))
	portraits.add_child(_portrait("personagens/barao_envergonhado", "Barão Embaralho"))
	content.add_child(_space(30))

	_section("UMA AVENTURA CRIADA POR", TEAM)
	_section("PERSONAGENS", [
		"Professor Aurélio, o velho professor de matemática",
		"Barão Embaralho, o ladrão de páginas",
		"e %s, quem recuperou o Grande Livro dos Números" % _player_name()
	])
	_section("ARTE", [
		"Botões, painéis, fundos do menu e brilhos:",
		"Kenney (kenney.nl) • UI Pack, Boardgame Pack e Particle Pack • CC0",
		"Retratos dos personagens feitos com Open Peeps, de Pablo Stanley • CC0",
		"Logo, ícone, peças de madeira, mapa, fundos dos lugares e desenhos da lousa feitos para o MathMatch"
	])
	_section("MÚSICA", [
		"\"A Biblioteca do Professor\" (menu)",
		"\"Peças e Contas\" (partida)",
		"Trilhas originais compostas para o MathMatch"
	])
	_section("SOM", ["Efeitos sonoros: Kenney • Interface Sounds • CC0"])
	_section("FONTE", ["Cormorant Garamond, de Christian Thalmann • SIL Open Font License 1.1"])
	_section("FEITO COM", ["Godot Engine 4.3 e GDScript"])
	_section("AGRADECIMENTOS", [
		"A todos os professores que ensinam com paciência",
		"e a você, por jogar até o fim!"
	])
	content.add_child(_space(60))
	content.add_child(_line("Obrigado por jogar!", 40, ACCENT))
	content.add_child(_space(40))

	var back = Button.new()
	back.text = "← MENU"
	back.position = Vector2(20, 18)
	back.custom_minimum_size = Vector2(120, 42)
	back.pressed.connect(_on_back_pressed)
	UiStyle.button(back, "secondary", 15)
	add_child(back)

	speed_hint = _line("Segure o clique para acelerar", 13, MUTED)
	speed_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	speed_hint.offset_top = -30
	speed_hint.offset_bottom = -10
	add_child(speed_hint)

	end_box = VBoxContainer.new()
	end_box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	end_box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	end_box.grow_vertical = Control.GROW_DIRECTION_BOTH
	end_box.alignment = BoxContainer.ALIGNMENT_CENTER
	end_box.add_theme_constant_override("separation", 14)
	end_box.visible = false
	add_child(end_box)

	mystery_card = PanelContainer.new()
	mystery_card.custom_minimum_size = Vector2(380, 0)
	mystery_card.visible = false
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = PAPER
	card_style.border_color = LEATHER
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		card_style.set(side, 5)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		card_style.set(corner, 12)
	for side in ["content_margin_left", "content_margin_right", "content_margin_top", "content_margin_bottom"]:
		card_style.set(side, 22)
	mystery_card.add_theme_stylebox_override("panel", card_style)
	var card_box = VBoxContainer.new()
	card_box.add_theme_constant_override("separation", 6)
	mystery_card.add_child(card_box)
	card_box.add_child(_line("CAPÍTULO 7", 16, Color("#7A6248")))
	card_box.add_child(_line("Geometria", 36, INK))
	card_box.add_child(_line("? ? ?", 28, Color("#9C8C6E")))
	end_box.add_child(mystery_card)

	var menu_button = Button.new()
	menu_button.text = "VOLTAR AO MENU"
	menu_button.custom_minimum_size = Vector2(240, 48)
	menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_button.pressed.connect(_on_back_pressed)
	UiStyle.button(menu_button, "primary", 17)
	end_box.add_child(menu_button)

	dialogue = DialogueBox.new()
	add_child(dialogue)


func _roll():
	var screen = get_viewport_rect().size
	content.position = Vector2((screen.x - content.size.x) / 2.0, screen.y)
	# Para quando o "Obrigado por jogar!" chega perto do topo, sem tela vazia no fim.
	var end_y = screen.y * 0.28 - content.size.y
	var duration = (screen.y - end_y) / SCROLL_SPEED
	roll_tween = create_tween()
	roll_tween.tween_property(content, "position:y", end_y, duration)
	roll_tween.finished.connect(_on_roll_finished)


func _on_roll_finished():
	speed_hint.visible = false
	var hide = create_tween()
	hide.tween_property(content, "modulate:a", 0.0, 0.6)
	end_box.visible = true
	# Só quem terminou a jornada vê a página misteriosa.
	if GameState.has_seen_story("pagina_18"):
		mystery_card.visible = true
		mystery_card.modulate = Color(1, 1, 1, 0)
		var fade = create_tween()
		fade.tween_property(mystery_card, "modulate:a", 1.0, 1.2)
		await fade.finished
		dialogue.play(Story.mystery_page())


func _set_fast(fast):
	if roll_tween != null and roll_tween.is_valid():
		roll_tween.set_speed_scale(5.0 if fast else 1.0)


func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_set_fast(event.pressed)


func _unhandled_input(event):
	if dialogue.is_open():
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
	elif event.is_action("ui_accept"):
		_set_fast(event.is_pressed())


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


# ---------------------------------------------------------------------
# Auxiliares
# ---------------------------------------------------------------------

func _player_name():
	var saved = str(GameState.player_name).strip_edges()
	return saved if saved != "" else "você"


func _section(title, lines):
	content.add_child(_space(24))
	content.add_child(_line(title, 16, ACCENT))
	for text in lines:
		content.add_child(_line(text, 22, TEXT))


func _line(text_value, font_size, color):
	var label = Label.new()
	label.text = UiStyle.tidy(text_value)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _space(height):
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(1, height)
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


func _portrait(texture_name, caption):
	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#F5F2EA")
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 16)
	frame.add_theme_stylebox_override("panel", style)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(frame)
	var picture = TextureRect.new()
	picture.texture = Assets.texture(texture_name)
	picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	picture.custom_minimum_size = Vector2(170, 170)
	picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(picture)
	box.add_child(_line(caption, 18, TEXT))
	return box
