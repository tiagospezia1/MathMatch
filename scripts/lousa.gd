extends Control

# Lousa do Professor Aurélio: desenha a conta com bolinhas, grupos, pratos
# e barras, para o aluno VER o que a operação faz. Usada pela caixa de
# diálogo (campo "board" de cada fala).
#
# Tipos (campo "kind"):
#   add      a, b, (c)          bolinhas de cada parcela; joined = junta tudo; count = numera
#   take     total, take, (take2) bolinhas; cross = risca as tiradas; result = destaca o que sobra
#   groups   groups, size       grupos iguais dentro de círculos
#   share    total, groups      bolinhas repartidas em pratos
#   fraction parts, take, total barra dividida em partes; shade = pinta; values = valor de cada parte
#   percent  percent, total     barra de 0% a 100%; shade = pinta; values = valor de cada parte
#   text     só as linhas
# Campo "lines": frases escritas com giz embaixo do desenho ("!" no começo = destaque).

const CHALK = Color("#F5F2EA")
const CHALK_SOFT = Color(0.96, 0.95, 0.92, 0.55)
const GOLD = Color("#F2C94C")
const BLUE = Color("#8EC5FF")
const PINK = Color("#F28B82")
const GREEN = Color("#9BE59B")
const DOT_R = 13.0
const DOT_GAP = 34.0
const DRAW_HEIGHT = 270.0

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
	var font = _font()
	if align == HORIZONTAL_ALIGNMENT_CENTER and width < 0:
		width = 400.0
		pos.x -= width / 2.0
	draw_string(font, pos, str(value), align, width, font_size, color)


func _dot(center, color, filled = true):
	if filled:
		draw_circle(center, DOT_R, color)
	draw_arc(center, DOT_R, 0, TAU, 24, CHALK, 2.0)


func _cross(center):
	var d = DOT_R + 4
	draw_line(center + Vector2(-d, -d), center + Vector2(d, d), PINK, 5.0)
	draw_line(center + Vector2(-d, d), center + Vector2(d, -d), PINK, 5.0)


# Quantas bolinhas já aparecem (animação de "giz").
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
	var width = total * DOT_GAP + sign_gap * (parts.size() - 1)
	var x = (size.x - width) / 2.0 + DOT_GAP / 2.0
	var y = 120.0
	var shown = _visible_count(total)
	var index = 0

	for i in range(parts.size()):
		if i > 0 and not joined:
			_text(Vector2(x + sign_gap / 2.0 - DOT_GAP / 2.0, y + 16), "+", 44, CHALK)
			x += sign_gap
		for k in range(parts[i]):
			if index < shown:
				_dot(Vector2(x, y), colors[i])
				if count:
					_text(Vector2(x, y + 52), index + 1, 22, CHALK)
			index += 1
			x += DOT_GAP

	if not joined and progress >= 0.999:
		# Quantidade de cada grupo embaixo.
		x = (size.x - width) / 2.0
		for i in range(parts.size()):
			var group_width = parts[i] * DOT_GAP
			_text(Vector2(x + group_width / 2.0, y + 60), parts[i], 30, colors[i])
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
	var per_row = 15
	var rows = int(ceil(total / float(per_row)))
	var shown = _visible_count(total)
	var start_y = 120.0 - (rows - 1) * 26.0

	for i in range(total):
		var row = int(i / per_row)
		var col = i % per_row
		var in_row = min(per_row, total - row * per_row)
		var x = (size.x - in_row * DOT_GAP) / 2.0 + DOT_GAP / 2.0 + col * DOT_GAP
		var y = start_y + row * 52.0
		if i >= shown:
			continue
		var removed_first = cross and i >= total - take
		var removed_second = cross and take2 > 0 and i >= total - take - take2 and i < total - take
		var stays = not removed_first and not removed_second
		var color = GREEN if (result and stays) else GOLD
		if removed_first or removed_second:
			color = Color(GOLD, 0.35)
		_dot(Vector2(x, y), color)
		if (removed_first or removed_second) and progress >= 0.6:
			_cross(Vector2(x, y))


# ---------------------------------------------------------------------
# Multiplicação: grupos iguais
# ---------------------------------------------------------------------

func _draw_groups():
	var groups = int(spec.get("groups", 1))
	var group_size = int(spec.get("size", 1))
	var cols = min(group_size, 3)
	var rows = int(ceil(group_size / float(cols)))
	var circle_r = max(cols, rows) * 17.0 + 16.0
	var gap = 24.0
	var width = groups * circle_r * 2.0 + (groups - 1) * gap
	var x0 = (size.x - width) / 2.0 + circle_r
	var y = 125.0
	var total = groups * group_size
	var shown = _visible_count(total)
	var index = 0

	for g in range(groups):
		var center = Vector2(x0 + g * (circle_r * 2.0 + gap), y)
		draw_arc(center, circle_r, 0, TAU, 48, CHALK, 3.0)
		for k in range(group_size):
			var row = int(k / cols)
			var col = k % cols
			var in_row = min(cols, group_size - row * cols)
			var dx = (col - (in_row - 1) / 2.0) * 32.0
			var dy = (row - (rows - 1) / 2.0) * 32.0
			if index < shown:
				_dot(center + Vector2(dx, dy), GOLD)
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
	var cols = min(each, 4)
	var rows = int(ceil(each / float(max(cols, 1))))
	var plate_w = max(cols * 30.0 + 40.0, 110.0)
	var plate_h = max(rows * 30.0 + 34.0, 70.0)
	var gap = 22.0
	var width = groups * plate_w + (groups - 1) * gap
	var x0 = (size.x - width) / 2.0
	var y = 125.0
	# A animação distribui uma bolinha por prato de cada vez, como quem reparte.
	var shown = _visible_count(total)

	for g in range(groups):
		var rect = Rect2(Vector2(x0 + g * (plate_w + gap), y - plate_h / 2.0), Vector2(plate_w, plate_h))
		draw_rect(rect, Color(CHALK, 0.08), true)
		draw_rect(rect, CHALK, false, 3.0)
		for k in range(each):
			var order = k * groups + g
			if order >= shown:
				continue
			var row = int(k / cols)
			var col = k % cols
			var in_row = min(cols, each - row * cols)
			var dx = (col - (in_row - 1) / 2.0) * 30.0
			var dy = (row - (rows - 1) / 2.0) * 30.0
			_dot(rect.get_center() + Vector2(dx, dy), GOLD)
		if progress >= 0.999 and bool(spec.get("values", true)):
			_text(rect.get_center() + Vector2(0, plate_h / 2.0 + 34), each, 28, BLUE)


# ---------------------------------------------------------------------
# Fração e porcentagem: barra dividida em partes iguais
# ---------------------------------------------------------------------

func _draw_bar(parts, shaded, total, top_label, part_labels):
	var bar_w = min(size.x - 80.0, 680.0)
	var bar_h = 74.0
	var x0 = (size.x - bar_w) / 2.0
	var y0 = 95.0
	var part_w = bar_w / parts
	var shown_parts = int(ceil(progress * parts))

	if top_label != "":
		_text(Vector2(size.x / 2.0, y0 - 22), top_label, 28, CHALK)

	for i in range(parts):
		var rect = Rect2(Vector2(x0 + i * part_w, y0), Vector2(part_w, bar_h))
		if i < shaded and i < shown_parts:
			draw_rect(rect.grow(-3), Color(GOLD, 0.85), true)
		draw_rect(rect, CHALK, false, 3.0)
		if progress >= 0.999 and i < part_labels.size():
			_text(rect.get_center() + Vector2(0, bar_h / 2.0 + 38), part_labels[i], 26, BLUE)


func _draw_fraction():
	var parts = max(1, int(spec.get("parts", 1)))
	var take = int(spec.get("take", 0)) if bool(spec.get("shade", true)) else 0
	var total = int(spec.get("total", 0))
	var labels = []
	if bool(spec.get("values", false)) and total > 0:
		for i in range(parts):
			labels.append(str(total / parts))
	_draw_bar(parts, take, total, "%d" % total if total > 0 else "", labels)


func _draw_percent():
	var p = int(spec.get("percent", 0))
	var total = int(spec.get("total", 0))
	var parts = int(spec.get("parts", 10))
	var shaded = int(round(p * parts / 100.0)) if bool(spec.get("shade", true)) else 0
	var labels = []
	if bool(spec.get("values", false)) and total > 0:
		for i in range(parts):
			labels.append(str(total / parts) if total % parts == 0 else "%.1f" % (float(total) / parts))
	_draw_bar(parts, shaded, total, "100%% = %d" % total, labels)
	if progress >= 0.999:
		var bar_w = min(size.x - 80.0, 680.0)
		var x0 = (size.x - bar_w) / 2.0
		_text(Vector2(x0, 92 + 74 + 78), "0%", 22, CHALK_SOFT)
		_text(Vector2(x0 + bar_w, 92 + 74 + 78), "100%", 22, CHALK_SOFT)
