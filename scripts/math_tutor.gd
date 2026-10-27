extends RefCounted

# Conteúdo pedagógico do MathMatch.
# - get_lesson(): mini-aula prática mostrada ao começar um conteúdo novo.
# - get_hint(): dica para o desafio atual quando o jogador erra várias vezes.
#     nível 1 = estratégia (não entrega a resposta)
#     nível 2 = resolução passo a passo (entrega a resposta)

const DOT = "●"
const EMPTY_DOT = "○"


static func get_lesson(operation):
	match operation:
		"addition":
			return {
				"name": "ADIÇÃO",
				"idea": "Somar é JUNTAR. Junte tudo e conte quantos ficaram.",
				"example": "3 + 2 = ?",
				"lines": [
					"%s  +  %s" % [_dots(3), _dots(2)],
					"Juntando: %s" % _dots(5),
					"Conte: 1, 2, 3, 4, 5  →  3 + 2 = 5"
				],
				"tip": "Truque: comece no número maior e conte o resto nos dedos (3 → 4, 5).",
				"practice": [
					{"text": "2 + 4 = ?", "answer": 6, "options": [5, 6, 7]},
					{"text": "3 + 3 = ?", "answer": 6, "options": [5, 6, 8]},
					{"text": "4 + 1 = ?", "answer": 5, "options": [4, 5, 6]}
				]
			}
		"subtraction":
			return {
				"name": "SUBTRAÇÃO",
				"idea": "Subtrair é TIRAR. Comece com tudo e tire uma parte.",
				"example": "5 − 2 = ?",
				"lines": [
					"Você tem:  %s" % _dots(5),
					"Tira 2:     %s%s" % [_dots(3), EMPTY_DOT.repeat(2)],
					"Sobram:    %s  →  5 − 2 = 3" % _dots(3)
				],
				"tip": "Truque: pense ao contrário. Quanto falta do 2 para chegar no 5?",
				"practice": [
					{"text": "6 − 2 = ?", "answer": 4, "options": [3, 4, 5]},
					{"text": "7 − 3 = ?", "answer": 4, "options": [4, 5, 3]},
					{"text": "8 − 5 = ?", "answer": 3, "options": [2, 3, 4]}
				]
			}
		"multiplication":
			return {
				"name": "MULTIPLICAÇÃO",
				"idea": "Multiplicar é somar GRUPOS IGUAIS.",
				"example": "3 × 2 = ?",
				"lines": [
					"3 grupos de 2:",
					_groups(3, 2),
					"2 + 2 + 2 = 6  →  3 × 2 = 6"
				],
				"tip": "Truque: se esquecer a tabuada, some o mesmo número várias vezes.",
				"practice": [
					{"text": "2 × 3 = ?", "answer": 6, "options": [5, 6, 8]},
					{"text": "2 × 4 = ?", "answer": 8, "options": [6, 8, 10]},
					{"text": "3 × 3 = ?", "answer": 9, "options": [6, 9, 12]}
				]
			}
		"division":
			return {
				"name": "DIVISÃO",
				"idea": "Dividir é REPARTIR igualmente, sem sobrar nada.",
				"example": "6 ÷ 3 = ?",
				"lines": [
					"6 balas para 3 amigos:",
					_split(6, 3),
					"Cada um ganha 2  →  6 ÷ 3 = 2"
				],
				"tip": "Truque: use a multiplicação ao contrário. 3 × ? = 6",
				"practice": [
					{"text": "8 ÷ 2 = ?", "answer": 4, "options": [3, 4, 6]},
					{"text": "9 ÷ 3 = ?", "answer": 3, "options": [2, 3, 6]},
					{"text": "10 ÷ 2 = ?", "answer": 5, "options": [4, 5, 8]}
				]
			}
		"fraction":
			return {
				"name": "FRAÇÕES",
				"idea": "Em 1/2, o número de BAIXO diz em quantas partes dividir. O de CIMA diz quantas partes pegar.",
				"example": "1/2 de 8 = ?",
				"lines": [
					"Divida 8 em 2 partes iguais:",
					_split(8, 2),
					"Pegue 1 parte: %s  →  4" % _dots(4)
				],
				"tip": "Como numa pizza: 1/4 é dividir em 4 pedaços e pegar 1.",
				"practice": [
					{"text": "1/2 de 6 = ?", "answer": 3, "options": [2, 3, 4]},
					{"text": "1/3 de 9 = ?", "answer": 3, "options": [3, 4, 6]},
					{"text": "2/3 de 6 = ?", "answer": 4, "options": [2, 3, 4]}
				]
			}
		"percentage":
			return {
				"name": "PORCENTAGEM",
				"idea": "% quer dizer \"de cada 100\". 100% é o total e 50% é a metade.",
				"example": "50% de 10 = ?",
				"lines": [
					"100%% = %s" % _dots(10),
					"50%% = metade: %s | %s" % [_dots(5), _dots(5)],
					"50% de 10 = 5"
				],
				"tip": "Atalhos: 50% = metade • 25% = metade da metade • 10% = dividir por 10.",
				"practice": [
					{"text": "50% de 8 = ?", "answer": 4, "options": [2, 4, 6]},
					{"text": "25% de 8 = ?", "answer": 2, "options": [2, 4, 6]},
					{"text": "10% de 30 = ?", "answer": 3, "options": [3, 10, 30]}
				]
			}

	return {}


static func get_hint(operation, text, answer, level, mention_tiles = true):
	var n = _numbers(text)
	var hint = ""

	match operation:
		"addition":
			hint = _addition_hint(n, answer, level)
		"subtraction":
			hint = _subtraction_hint(n, answer, level)
		"multiplication":
			hint = _multiplication_hint(n, answer, level)
		"division":
			hint = _division_hint(n, answer, level)
		"fraction":
			hint = _fraction_hint(n, answer, level)
		"percentage":
			hint = _percentage_hint(n, answer, level)

	if hint == "":
		hint = "Leia a conta com calma e resolva uma parte de cada vez."
		if level >= 2:
			hint = "A resposta é %d." % answer

	if level >= 2 and mention_tiles:
		hint += " Procure as peças %d!" % answer

	return hint


# ---------- dicas por operação ----------

static func _addition_hint(n, answer, level):
	if n.size() < 2:
		return ""

	if n.size() >= 3:
		var partial = n[0] + n[1]
		if level == 1:
			return "Some por partes: primeiro %d + %d, depois some o %d." % [n[0], n[1], n[2]]
		return "%d + %d = %d, depois %d + %d = %d." % [n[0], n[1], partial, partial, n[2], answer]

	var big = max(n[0], n[1])
	var small = min(n[0], n[1])
	if level == 1:
		return "Comece no %d e conte mais %d nos dedos." % [big, small]

	if small <= 6:
		var steps = []
		for i in range(1, small + 1):
			steps.append(str(big + i))
		return "Contando a partir do %d: %s." % [big, ", ".join(PackedStringArray(steps))]
	return "%d + %d = %d." % [big, small, answer]


static func _subtraction_hint(n, answer, level):
	if n.size() < 2:
		return ""

	if n.size() >= 3:
		var partial = n[0] - n[1]
		if level == 1:
			return "Tire um de cada vez: primeiro %d − %d, depois tire %d." % [n[0], n[1], n[2]]
		return "%d − %d = %d, depois %d − %d = %d." % [n[0], n[1], partial, partial, n[2], answer]

	if level == 1:
		return "Pense ao contrário: %d + ? = %d. Quanto falta?" % [n[1], n[0]]
	return "%d + %d = %d, então %d − %d = %d." % [n[1], answer, n[0], n[0], n[1], answer]


static func _multiplication_hint(n, answer, level):
	if n.size() < 2:
		return ""

	var groups = n[0]
	var size = n[1]
	var parts = []
	for i in range(groups):
		parts.append(str(size))
	var sum_text = " + ".join(PackedStringArray(parts))

	if level == 1:
		if groups * size <= 12:
			return "São %d grupos de %d: %s. Conte tudo!" % [groups, size, _groups(groups, size)]
		return "São %d grupos de %d. Some: %s." % [groups, size, sum_text]
	return "%s = %d." % [sum_text, answer]


static func _division_hint(n, answer, level):
	if n.size() < 2:
		return ""

	if level == 1:
		return "Reparta %d em %d grupos iguais. Ou pense: %d × ? = %d." % [n[0], n[1], n[1], n[0]]
	return "%d × %d = %d, então %d ÷ %d = %d." % [n[1], answer, n[0], n[0], n[1], answer]


static func _fraction_hint(n, answer, level):
	if n.size() < 3:
		return ""

	var top = n[0]
	var bottom = n[1]
	var total = n[2]
	var part = total / bottom

	if level == 1:
		var take = "1 parte" if top == 1 else "%d partes" % top
		return "Divida %d em %d partes iguais (%d ÷ %d) e pegue %s." % [total, bottom, total, bottom, take]

	if top == 1:
		return "%d ÷ %d = %d em cada parte. Pegando 1 parte: %d." % [total, bottom, part, answer]
	return "%d ÷ %d = %d em cada parte. Pegando %d partes: %d × %d = %d." % [total, bottom, part, top, top, part, answer]


static func _percentage_hint(n, answer, level):
	if n.size() < 2:
		return ""

	var p = n[0]
	var total = n[1]

	if p == 100:
		if level == 1:
			return "100% é o número inteiro, sem tirar nada."
		return "100%% de %d é o próprio %d." % [total, answer]

	if p == 50:
		if level == 1:
			return "50%% é a metade. Qual é a metade de %d?" % total
		return "Metade de %d: %d ÷ 2 = %d." % [total, total, answer]

	# 10% é o caminho mais prático quando o total é múltiplo de 10.
	if total % 10 == 0 and p != 25 and p != 75:
		var ten = total / 10
		var tens = p / 10
		var has_five = p % 10 == 5

		if level == 1:
			var msg = "10%% de %d é %d (%d ÷ 10)." % [total, ten, total]
			if tens > 1:
				msg += " %d%% são %d vezes isso." % [tens * 10, tens]
			if has_five:
				msg += " E 5% é a metade de 10%."
			return msg

		var result = "10%% = %d" % ten
		if tens > 1:
			result += ", %d%% = %d × %d = %d" % [tens * 10, tens, ten, tens * ten]
		if has_five:
			result += ", 5%% = %d" % (ten / 2)
		return result + ". Total: %d." % answer

	# Senão, transforma em fração: 25% = 1/4, 20% = 1/5, 75% = 3/4...
	var g = _gcd(p, 100)
	var top = p / g
	var bottom = 100 / g
	var part = total / bottom

	if level == 1:
		var take = "1 parte" if top == 1 else "%d partes" % top
		return "%d%% é o mesmo que %d/%d: divida %d em %d partes e pegue %s." % [p, top, bottom, total, bottom, take]
	if top == 1:
		return "%d%% = %d/%d. %d ÷ %d = %d." % [p, top, bottom, total, bottom, answer]
	return "%d%% = %d/%d. %d ÷ %d = %d, vezes %d = %d." % [p, top, bottom, total, bottom, part, top, answer]


# ---------- auxiliares ----------

static func _numbers(text):
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = []
	for m in regex.search_all(text):
		result.append(int(m.get_string()))
	return result


static func _gcd(a, b):
	while b != 0:
		var t = b
		b = a % b
		a = t
	return a


static func _dots(count):
	return DOT.repeat(count)


static func _groups(groups, size):
	var parts = []
	for i in range(groups):
		parts.append(_dots(size))
	return "   ".join(PackedStringArray(parts))


static func _split(total, groups):
	var parts = []
	for i in range(groups):
		parts.append(_dots(total / groups))
	return " | ".join(PackedStringArray(parts))
