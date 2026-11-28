extends RefCounted

# Visual dos menus do MathMatch, inspirado no Grande Livro dos Números:
# capa de couro, páginas de papel, tinta marrom e detalhes dourados.
# Uso: UiStyle.button(botao, "primary"), UiStyle.paper(), UiStyle.leather()...

const NAVY = Color("#0B1120")
const LEATHER = Color("#5A3A22")
const LEATHER_LIGHT = Color("#7A4A26")
const PAPER = Color("#F3EBD8")
const PAPER_HOVER = Color("#FFF8E6")
const PAPER_PRESSED = Color("#E4D7B9")
const INK = Color("#3B2A1A")
const INK_SOFT = Color("#7A6248")
const GOLD = Color("#F2C94C")
const GOLD_DARK = Color("#C99A1E")
const CHALKBOARD = Color("#1F3A2E")
const WOOD = Color("#8B5A2B")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#C9D3E2")
const DANGER = Color("#9B2C2C")


static func box(fill, border = Color.TRANSPARENT, border_width = 0, radius = 14, margin = 14):
	var style = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, border_width)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, radius)
	for side in ["content_margin_left", "content_margin_right", "content_margin_top", "content_margin_bottom"]:
		style.set(side, margin)
	return style


# Página de papel com borda de couro.
static func paper(margin = 22):
	var style = box(PAPER, LEATHER_LIGHT, 4, 16, margin)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 12
	return style


# Capa de couro com filete dourado.
static func leather(margin = 18):
	var style = box(LEATHER, GOLD_DARK, 3, 20, margin)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 14
	return style


# Lousa verde com moldura de madeira.
static func chalkboard(margin = 18):
	var style = box(CHALKBOARD, WOOD, 8, 14, margin)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 12
	return style


# Estilos de botão:
#   primary   dourado com tinta escura (a ação principal)
#   secondary papel com tinta marrom
#   link      sem fundo, texto claro (ações pequenas)
#   danger    sem fundo, texto vermelho claro (resetar)
static func button(node, kind = "secondary", font_size = 18):
	var normal
	var hover
	var pressed
	var font = INK
	match kind:
		"primary":
			normal = box(GOLD, GOLD_DARK, 3, 14, 12)
			hover = box(Color("#FFD966"), Color("#FFF1B8"), 3, 14, 12)
			pressed = box(GOLD_DARK, GOLD_DARK, 3, 14, 12)
			for st in [normal, hover]:
				st.shadow_color = Color(0, 0, 0, 0.35)
				st.shadow_size = 6
				st.shadow_offset = Vector2(0, 3)
		"link", "danger":
			normal = box(Color(0, 0, 0, 0), Color.TRANSPARENT, 0, 10, 8)
			hover = box(Color(1, 1, 1, 0.08), Color.TRANSPARENT, 0, 10, 8)
			pressed = box(Color(1, 1, 1, 0.14), Color.TRANSPARENT, 0, 10, 8)
			font = Color("#FCA5A5") if kind == "danger" else MUTED
		_:
			normal = box(PAPER, LEATHER_LIGHT, 2, 12, 10)
			hover = box(PAPER_HOVER, GOLD_DARK, 3, 12, 10)
			pressed = box(PAPER_PRESSED, LEATHER_LIGHT, 2, 12, 10)
	var disabled = normal.duplicate()
	disabled.bg_color = Color(normal.bg_color, normal.bg_color.a * 0.5)

	node.add_theme_stylebox_override("normal", normal)
	node.add_theme_stylebox_override("hover", hover)
	node.add_theme_stylebox_override("pressed", pressed)
	node.add_theme_stylebox_override("focus", hover)
	node.add_theme_stylebox_override("disabled", disabled)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		node.add_theme_color_override(state, font if kind != "link" or state == "font_color" else TEXT)
	node.add_theme_color_override("font_disabled_color", Color(font, 0.5))
	node.add_theme_font_size_override("font_size", font_size)
	return node


static func make_button(text_value, kind = "secondary", min_size = Vector2(0, 48), font_size = 18):
	var node = Button.new()
	node.text = text_value
	node.custom_minimum_size = min_size
	return button(node, kind, font_size)


static func label(text_value, font_size, color, centered = true):
	var node = Label.new()
	node.text = tidy(text_value)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if centered:
		node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	return node


# Ajeita um texto antes de mostrar num rótulo com quebra de linha:
#  - "7 − 3", "9 × 10 = 90" e "50% de 20" não se dividem entre duas linhas;
#  - a última palavra de cada parágrafo não fica sozinha na última linha.
# Usa o espaço que não quebra (U+00A0), que o Godot respeita.
static func tidy(value):
	var text = str(value)
	var math = RegEx.new()
	math.compile("(\\S) ([+−×÷=]) (?=\\S)")
	text = math.sub(text, "$1\u00a0$2\u00a0", true)
	var percent = RegEx.new()
	percent.compile("(\\d+%) (de|são|é) (?=\\S)")
	text = percent.sub(text, "$1\u00a0$2\u00a0", true)
	var lines = text.split("\n")
	for i in range(lines.size()):
		var line = lines[i]
		var last = line.rfind(" ")
		# Só junta quando a última palavra é curta e a linha é longa (texto que quebra).
		if last > 20 and line.length() - last <= 14:
			lines[i] = line.substr(0, last) + "\u00a0" + line.substr(last + 1)
	return "\n".join(lines)
