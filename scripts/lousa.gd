extends Control

# Lousa do Professor Aurélio: desenha a conta com frutas, doces e objetos
# (assets/imagens/lousa/), para o aluno VER o que a operação faz.
# Usada pela caixa de diálogo (campo "board" de cada fala).
#
# Tipos (campo "kind"):
#   add      a, b, (c)            itens de cada parcela; joined = junta tudo; count = numera
#   take     total, take, (take2) itens; cross = risca os que saem; result = destaca o que sobra
#   groups   groups, size         grupos iguais dentro de círculos
#   share    total, groups        itens repartidos em pratos
#   fraction parts, take, total   barra de chocolate em pedaços; shade = destaca os pegos; values = valor de cada pedaço
#   percent  percent, total       barra de chocolate de 0% a 100%
#   text     só as linhas
# Campo "item" (ou "items" na adição, um por parcela): maca, laranja, morango,
# caixa, pote_mel, pao, bala, bombom. Sem a imagem, a lousa desenha bolinhas.
# Campo "lines": frases escritas com giz embaixo do desenho ("!" no começo = destaque).

const CHALK = Color("#F5F2EA")
const CHALK_SOFT = Color(0.96, 0.95, 0.92, 0.55)
const GOLD = Color("#F2C94C")
const BLUE = Color("#8EC5FF")
const PINK = Color("#F28B82")
const GREEN = Color("#9BE59B")
const CHOCOLATE = Color("#6B3E26")
const CHOCOLATE_LIGHT = Color("#8D5A3A")
const DRAW_HEIGHT = 270.0
const DEFAULT_ITEMS = {
	"add": ["maca", "laranja", "morango"],
	"take": "bala",
	"groups": "pote_mel",
	"share": "pao"
}

var spec = {}
var progress = 1.0:
	set(value):
		progress = value
		queue_redraw()

var _tween


func show_spec(new_spec, animate = true):
	spec = new_spec
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if animate and str(spec.get("kind", "text")) != "text":
		progress = 0.0
		_tween = create_tween()
		_tween.tween_property(self, "progress", 1.0, 1.1)
	else:
		progress = 1.0


func _font():
	return get_theme_default_font()


func _draw():
	if spec.is_empty():
		return
	var kind = str(spec.get("kind", "text"))
	match kind:
		"add":
			_draw_add()
		"take":
			_draw_take()
		"groups":
			_draw_groups()
		"share":
			_draw_share()
		"fraction":
			_draw_fraction()
		"percent":
			_draw_percent()
	_draw_lines(kind == "text")


# ---------------------------------------------------------------------
# Auxiliares
# ---------------------------------------------------------------------

func _text(pos, value, font_size, color, align = HORIZONTAL_ALIGNMENT_CENTER, width = -1.0):
	if align == HORIZONTAL_ALIGNMENT_CENTER and width < 0:
		width = 400.0
		pos.x -= width / 2.0
	draw_string(_font(), pos, str(value), align, width, font_size, color)


func _item_name(index = 0):
	var kind = str(spec.get("kind", ""))
	if spec.has("items"):
		var list = spec["items"]
		return str(list[min(index, list.size() - 1)])
	if spec.has("item"):
		return str(spec["item"])
	var fallback = DEFAULT_ITEMS.get(kind, "")
	if typeof(fallback) == TYPE_ARRAY:
		return str(fallback[min(index, fallback.size() - 1)])
	return str(fallback)


# Desenha um item (fruta, doce, objeto) ou, sem a imagem, uma bolinha.
func _item(center, item_name, item_size, color = GOLD, alpha = 1.0):
	var tex = Assets.texture("lousa/" + item_name) if item_name != "" else null
	if tex != null:
		var rect = Rect2(center - Vector2(item_size, item_size) / 2.0, Vector2(item_size, item_size))
		draw_texture_rect(tex, rect, false, Color(1, 1, 1, alpha))
	else:
		var radius = item_size * 0.38
		draw_circle(center, radius, Color(color, alpha))
		draw_arc(center, radius, 0, TAU, 24, Color(CHALK, alpha), 2.0)


func _cross(center, item_size):
	var d = item_size * 0.45
	draw_line(center + Vector2(-d, -d), center + Vector2(d, d), PINK, 6.0)
	draw_line(center + Vector2(-d, d), center + Vector2(d, -d), PINK, 6.0)


func _ring(center, item_size):
	draw_arc(center, item_size * 0.56, 0, TAU, 32, GREEN, 4.0)


# Espaço de cada item numa fileira, para caber na lousa.
func _gap_for(count, extra = 0.0, max_gap = 72.0):
	if count <= 0:
		return max_gap
	return min(max_gap, (size.x - 60.0 - extra) / count)


# Quantos itens já aparecem (animação de "giz").
func _visible_count(total):
	return int(ceil(progress * total))


func _draw_lines(centered_vertically):
	var lines = spec.get("lines", [])
	if lines.is_empty() or progress < 0.999:
		return
	var font_size = 40 if centered_vertically else 34
	var line_gap = 54.0 if centered_vertically else 46.0
	var y = DRAW_HEIGHT + 40.0
	if centered_vertically:
		y = (size.y - line_gap * lines.size()) / 2.0 + font_size
	for line in lines:
		var text = str(line)
		var color = CHALK
		if text.begins_with("!"):
			text = text.substr(1)
			color = GOLD
		_text(Vector2(10, y), text, font_size, color, HORIZONTAL_ALIGNMENT_CENTER, size.x - 20)
		y += line_gap


# ---------------------------------------------------------------------
# Adição: juntar
# ---------------------------------------------------------------------

func _draw_add():
	var parts = [int(spec.get("a", 0)), int(spec.get("b", 0))]
	if spec.has("c"):
		parts.append(int(spec.get("c", 0)))
	var colors = [GOLD, BLUE, PINK]
	var joined = bool(spec.get("joined", false))
	var count = bool(spec.get("count", false))

	var total = 0
	for p in parts:
		total += p
	var sign_gap = 0.0 if joined else 56.0
	var gap = _gap_for(total, sign_gap * (parts.size() - 1))
	var item_size = gap * 0.92
	var width = total * gap + sign_gap * (parts.size() - 1)
	var x = (size.x - width) / 2.0 + gap / 2.0
	var y = 120.0
	var shown = _visible_count(total)
	var index = 0

	for i in range(parts.size()):
		if i > 0 and not joined:
			_text(Vector2(x + sign_gap / 2.0 - gap / 2.0, y + 16), "+", 48, CHALK)
			x += sign_gap
		for k in range(parts[i]):
			if index < shown:
				_item(Vector2(x, y), _item_name(i), item_size, colors[i])
				if count:
					_text(Vector2(x, y + item_size / 2.0 + 30), index + 1, 22, CHALK)
			index += 1
			x += gap

	if not joined and progress >= 0.999:
		# Quantidade de cada grupo embaixo.
		x = (size.x - width) / 2.0
		for i in range(parts.size()):
			var group_width = parts[i] * gap
			_text(Vector2(x + group_width / 2.0, y + item_size / 2.0 + 36), parts[i], 30, colors[i])
			x += group_width + sign_gap


# ---------------------------------------------------------------------
# Subtração: tirar
# ---------------------------------------------------------------------

func _draw_take():
	var total = int(spec.get("total", 0))
	var take = int(spec.get("take", 0))
	var take2 = int(spec.get("take2", 0))
	var cross = bool(spec.get("cross", false))
	var result = bool(spec.get("result", false))
	var per_row = 12 if total > 12 else total
	var rows = int(ceil(total / float(max(per_row, 1))))
	var gap = _gap_for(per_row)
	var item_size = gap * 0.9
	var row_height = item_size + 14.0
	var start_y = 125.0 - (rows - 1) * row_height / 2.0
	var shown = _visible_count(total)
	var item_name = _item_name()

	for i in range(total):
		var row = int(i / per_row)
		var col = i % per_row
		var in_row = min(per_row, total - row * per_row)
		var center = Vector2((size.x - in_row * gap) / 2.0 + gap / 2.0 + col * gap, start_y + row * row_height)
		if i >= shown:
			continue
		var removed = cross and (i >= total - take or (take2 > 0 and i >= total - take - take2))
		if result and not removed:
			_ring(center, item_size)
		_item(center, item_name, item_size, GOLD, 0.5 if removed else 1.0)
		if removed and progress >= 0.6:
			_cross(center, item_size)


# ---------------------------------------------------------------------
# Multiplicação: grupos iguais
# ---------------------------------------------------------------------

func _draw_groups():
	var groups = int(spec.get("groups", 1))
	var group_size = int(spec.get("size", 1))
	var cols = min(group_size, 3)
	var rows = int(ceil(group_size / float(cols)))
	var item_size = 46.0 if groups <= 3 else 38.0
	var step = item_size + 4.0
	var circle_r = max(cols, rows) * step / 2.0 + 22.0
	var gap = 22.0
	var width = groups * circle_r * 2.0 + (groups - 1) * gap
	var x0 = (size.x - width) / 2.0 + circle_r
	var y = 125.0
	var total = groups * group_size
	var shown = _visible_count(total)
	var index = 0
	var item_name = _item_name()

	for g in range(groups):
		var center = Vector2(x0 + g * (circle_r * 2.0 + gap), y)
		draw_arc(center, circle_r, 0, TAU, 48, CHALK, 3.0)
		for k in range(group_size):
			var row = int(k / cols)
			var col = k % cols
			var in_row = min(cols, group_size - row * cols)
			var dx = (col - (in_row - 1) / 2.0) * step
			var dy = (row - (rows - 1) / 2.0) * step
			if index < shown:
				_item(center + Vector2(dx, dy), item_name, item_size)
			index += 1
		if progress >= 0.999:
			_text(center + Vector2(0, circle_r + 34), group_size, 28, BLUE)


# ---------------------------------------------------------------------
# Divisão: repartir em pratos
# ---------------------------------------------------------------------

func _draw_share():
	var total = int(spec.get("total", 0))
	var groups = max(1, int(spec.get("groups", 1)))
	var each = int(total / groups)
	var cols = min(each, 3)
	var rows = int(ceil(each / float(max(cols, 1))))
	var gap = 22.0
	var item_size = 44.0 if groups <= 4 else 32.0
	var step = item_size + 2.0
	var plate_w = min(max(cols * step + 30.0, 100.0), (size.x - 40.0 - (groups - 1) * gap) / groups)
	var plate_h = max(rows * step + 26.0, 70.0)
	var width = groups * plate_w + (groups - 1) * gap
	var x0 = (size.x - width) / 2.0
	var y = 125.0
	var item_name = _item_name()
	# A animação distribui um item por prato de cada vez, como quem reparte.
	var shown = _visible_count(total)

	for g in range(groups):
		var rect = Rect2(Vector2(x0 + g * (plate_w + gap), y - plate_h / 2.0), Vector2(plate_w, plate_h))
		_plate(rect)
		for k in range(each):
			var order = k * groups + g
			if order >= shown:
				continue
			var row = int(k / cols)
			var col = k % cols
			var in_row = min(cols, each - row * cols)
			var dx = (col - (in_row - 1) / 2.0) * step
			var dy = (row - (rows - 1) / 2.0) * step
			_item(rect.get_center() + Vector2(dx, dy), item_name, item_size)
		if progress >= 0.999 and bool(spec.get("values", true)):
			_text(rect.get_center() + Vector2(0, plate_h / 2.0 + 34), each, 28, BLUE)


# Prato visto de cima: uma bandeja clara com borda.
func _plate(rect):
	var style = StyleBoxFlat.new()
	style.bg_color = Color("#E9E4D8")
	style.border_color = Color("#B8B0A0")
	for side in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		style.set(side, 4)
	for corner in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		style.set(corner, 30)
	draw_style_box(style, rect)


# ---------------------------------------------------------------------
# Fração e porcentagem: barra de chocolate dividida em pedaços iguais
# ---------------------------------------------------------------------

func _draw_bar(parts, taken, top_label, part_labels):
	var bar_w = min(size.x - 80.0, 680.0)
	var bar_h = 80.0
	var x0 = (size.x - bar_w) / 2.0
	var y0 = 95.0
	var part_w = bar_w / parts
	var shown_parts = int(ceil(progress * parts))

	if top_label != "":
		_text(Vector2(size.x / 2.0, y0 - 22), top_label, 28, CHALK)

	for i in range(parts):
		if i >= shown_parts:
			continue
		var picked = i < taken
		# Os pedaços pegos sobem um pouco e ganham borda dourada.
		var lift = -12.0 if picked and progress >= 0.999 else 0.0
		var rect = Rect2(Vector2(x0 + i * part_w, y0 + lift), Vector2(part_w, bar_h))
		_chocolate_piece(rect, 1.0 if (picked or taken == 0) else 0.45, picked)
		if progress >= 0.999 and i < part_labels.size():
			_text(Vector2(rect.get_center().x, y0 + bar_h + 40), part_labels[i], 26, BLUE)


func _chocolate_piece(rect, alpha, picked):
	var inner = rect.grow(-3)
	draw_rect(inner, Color(CHOCOLATE, alpha), true)
	var bevel = inner.grow(-min(inner.size.x, inner.size.y) * 0.18)
	if bevel.size.x > 4 and bevel.size.y > 4:
		draw_rect(bevel, Color(CHOCOLATE_LIGHT, alpha), true)
	draw_rect(inner, GOLD if picked else Color("#2B1810", alpha), false, 4.0 if picked else 2.0)


func _draw_fraction():
	var parts = max(1, int(spec.get("parts", 1)))
	var take = int(spec.get("take", 0)) if bool(spec.get("shade", true)) else 0
	var total = int(spec.get("total", 0))
	var labels = []
	if bool(spec.get("values", false)) and total > 0:
		for i in range(parts):
			labels.append(str(total / parts))
	_draw_bar(parts, take, "%d" % total if total > 0 else "", labels)


func _draw_percent():
	var p = int(spec.get("percent", 0))
	var total = int(spec.get("total", 0))
	var parts = int(spec.get("parts", 10))
	var shaded = int(round(p * parts / 100.0)) if bool(spec.get("shade", true)) else 0
	if shaded >= parts:
		shaded = 0
	var labels = []
	if bool(spec.get("values", false)) and total > 0:
		for i in range(parts):
			labels.append(str(total / parts) if total % parts == 0 else "%.1f" % (float(total) / parts))
	_draw_bar(parts, shaded, "100%% = %d" % total, labels)
	if progress >= 0.999:
		var bar_w = min(size.x - 80.0, 680.0)
		var x0 = (size.x - bar_w) / 2.0
		_text(Vector2(x0, 95 + 80 + 80), "0%", 22, CHALK_SOFT)
		_text(Vector2(x0 + bar_w, 95 + 80 + 80), "100%", 22, CHALK_SOFT)
