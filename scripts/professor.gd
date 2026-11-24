extends RefCounted

# Aulas e explicações do Professor Aurélio.
#
# - lesson(): a aula completa de cada operação (ideia, exemplo resolvido na
#   lousa, truque, erro comum, exercícios com correção e resumo).
# - explain(): explica a conta ATUAL do jogo, com os números dela.
#     nível 1 = como pensar (sem dar a resposta)
#     nível 2 = resolução passo a passo (com a resposta)
# - misconception(): reconhece erros comuns ("juntou em vez de tirar"...)
#   e diz o que aconteceu.
#
# Tudo vira falas da caixa de diálogo (dialogue_box.gd); o campo "board" é
# desenhado na lousa (lousa.gd) e o campo "quiz" vira um exercício.

const MathTutor = preload("res://scripts/math_tutor.gd")

const TITLES = {
	"addition": "ADIÇÃO",
	"subtraction": "SUBTRAÇÃO",
	"multiplication": "MULTIPLICAÇÃO",
	"division": "DIVISÃO",
	"fraction": "FRAÇÕES",
	"percentage": "PORCENTAGEM"
}


static func _p(mood, text, board = {}):
	var line = {"who": "professor", "mood": mood, "text": text}
	if not board.is_empty():
		line["board"] = board
	return line


static func _board(kind, data = {}, lines = []):
	var spec = data.duplicate()
	spec["kind"] = kind
	spec["lines"] = lines
	return spec


static func _text_board(lines):
	return _board("text", {}, lines)


# Exercício da aula: o professor pergunta, o aluno escolhe e recebe correção.
static func _quiz(operation, prompt, question, choices, answer, board, right, solution_board):
	var feedback = {}
	for value in choices:
		if int(value) == answer:
			continue
		var note = misconception(operation, question, answer, int(value), true)
		feedback[str(value)] = note if note != "" else "Ainda não é %d. Olhe a lousa com calma e tente de novo." % int(value)
	return {
		"who": "professor",
		"mood": "explicando",
		"text": prompt,
		"board": board,
		"quiz": {
			"choices": choices,
			"answer": answer,
			"feedback": feedback,
			"right": right,
			"solution": MathTutor.get_hint(operation, question, answer, 2, false),
			"solution_board": solution_board
		}
	}


# =====================================================================
# AULA COMPLETA
# =====================================================================

static func lesson(operation, first_time = true):
	var title = TITLES.get(operation, "")
	var lines = []
	if first_time:
		lines.append(_p("explicando", "Antes de irmos ao tabuleiro, uma aula. Pegue o caderno, [NOME]: hoje é %s." % title.to_lower(), _text_board([title])))
	else:
		lines.append(_p("feliz", "Vamos rever %s juntos. Não tem pressa." % title.to_lower(), _text_board([title])))

	match operation:
		"addition":
			lines.append_array(_lesson_addition())
		"subtraction":
			lines.append_array(_lesson_subtraction())
		"multiplication":
			lines.append_array(_lesson_multiplication())
		"division":
			lines.append_array(_lesson_division())
		"fraction":
			lines.append_array(_lesson_fraction())
		"percentage":
			lines.append_array(_lesson_percentage())

	lines.append(_p("orgulhoso", "No tabuleiro é igual: resolva a conta e junte 3 peças com a resposta. Se travar, eu estou aqui."))
	return lines


static func _lesson_addition():
	return [
		_p("explicando", "Somar é JUNTAR. Lembra da moradora do Pomar? Ela tinha 3 maçãs e ganhou mais 2.",
			_board("add", {"a": 3, "b": 2}, ["3 + 2"])),
		_p("explicando", "Para saber quantas ela tem, juntamos tudo e contamos uma por uma: 1, 2, 3, 4, 5.",
			_board("add", {"a": 3, "b": 2, "joined": true, "count": true}, ["!3 + 2 = 5"])),
		_p("pensativo", "Um truque: não precisa contar desde o 1. Comece no número MAIOR e conte só o resto. Começo no 3... e conto mais 2: 4, 5.",
			_text_board(["Comece no maior: 3", "conte mais 2:  4, 5", "!3 + 2 = 5"])),
		_p("explicando", "E a ordem não muda o resultado: 2 + 3 dá o mesmo que 3 + 2. Por isso sempre podemos começar pelo maior.",
			_board("add", {"a": 2, "b": 3}, ["2 + 3  =  3 + 2  =  5"])),
		_p("explicando", "Quando aparecem três números, some por partes: primeiro os dois primeiros, depois junte o terceiro.",
			_text_board(["2 + 3 + 4", "2 + 3 = 5", "!5 + 4 = 9"])),
		_quiz("addition", "Sua vez! Quanto é 4 + 3?", "4 + 3 = ?", [6, 7, 8], 7,
			_board("add", {"a": 4, "b": 3}, ["4 + 3 = ?"]),
			"Isso! Começando no 4: 5, 6, 7. São 7.",
			_board("add", {"a": 4, "b": 3, "joined": true, "count": true}, ["!4 + 3 = 7"])),
		_quiz("addition", "Agora com três números. Quanto é 2 + 2 + 3?", "2 + 2 + 3 = ?", [4, 7, 8], 7,
			_text_board(["2 + 2 + 3 = ?"]),
			"Muito bem! 2 + 2 = 4, e 4 + 3 = 7.",
			_text_board(["2 + 2 = 4", "!4 + 3 = 7"])),
		_p("orgulhoso", "Guarde isso: somar é juntar; comece no maior e conte o resto; com três números, some por partes.",
			_text_board(["Somar é juntar", "Comece no maior e conte o resto", "!Três números? Some por partes"]))
	]


static func _lesson_subtraction():
	return [
		_p("explicando", "Subtrair é TIRAR. O marinheiro tinha 8 caixas no barco e descarregou 5.",
			_board("take", {"total": 8, "take": 5}, ["8 − 5"])),
		_p("explicando", "Riscamos as 5 caixas que saíram e contamos as que SOBRARAM: 3.",
			_board("take", {"total": 8, "take": 5, "cross": true, "result": true}, ["!8 − 5 = 3"])),
		_p("pensativo", "Um truque: pense ao contrário. 8 − 5 pergunta: 5 mais quanto chega em 8? Contando do 5: 6, 7, 8. Contei 3 vezes!",
			_text_board(["5 + ? = 8", "6, 7, 8  →  contei 3", "!8 − 5 = 3"])),
		_p("preocupado", "Cuidado: na subtração a ordem importa. Começamos sempre pelo total, o número que vem primeiro, e tiramos dele.",
			_text_board(["Começa com o total: 8", "e tira 5", "!sobram 3"])),
		_p("explicando", "Com duas subtrações, tire uma de cada vez: primeiro a primeira, depois a segunda.",
			_board("take", {"total": 12, "take": 3, "take2": 4, "cross": true, "result": true}, ["12 − 4 = 8", "!8 − 3 = 5"])),
		_quiz("subtraction", "Sua vez! Quanto é 7 − 3?", "7 − 3 = ?", [3, 4, 10], 4,
			_board("take", {"total": 7, "take": 3}, ["7 − 3 = ?"]),
			"Isso! Tirando 3 de 7, sobram 4. E confere: 3 + 4 = 7.",
			_board("take", {"total": 7, "take": 3, "cross": true, "result": true}, ["!7 − 3 = 4"])),
		_quiz("subtraction", "E agora: 10 − 4 − 2?", "10 − 4 − 2 = ?", [4, 6, 8], 4,
			_board("take", {"total": 10, "take": 2, "take2": 4}, ["10 − 4 − 2 = ?"]),
			"Muito bem! 10 − 4 = 6, e 6 − 2 = 4.",
			_board("take", {"total": 10, "take": 2, "take2": 4, "cross": true, "result": true}, ["10 − 4 = 6", "!6 − 2 = 4"])),
		_p("orgulhoso", "Guarde isso: subtrair é tirar; comece pelo total; e, se travar, pense ao contrário.",
			_text_board(["Subtrair é tirar", "Comece pelo total", "!Travou? Quanto falta?"]))
	]


static func _lesson_multiplication():
	return [
		_p("explicando", "Na floresta, o apicultor tem 3 colmeias, e cada uma tem 2 potes de mel.",
			_board("groups", {"groups": 3, "size": 2}, ["3 colmeias com 2 potes"])),
		_p("explicando", "Multiplicar é somar GRUPOS IGUAIS. 3 × 2 quer dizer: 3 grupos de 2. Então 2 + 2 + 2 = 6.",
			_board("groups", {"groups": 3, "size": 2}, ["2 + 2 + 2 = 6", "!3 × 2 = 6"])),
		_p("pensativo", "Um truque: a ordem não importa. 3 grupos de 2 dá o mesmo que 2 grupos de 3. Use a que for mais fácil!",
			_board("groups", {"groups": 2, "size": 3}, ["2 × 3  =  3 × 2  =  6"])),
		_p("explicando", "Se esquecer a tabuada, conte de tantos em tantos. Para 4 × 3, conte de 3 em 3, quatro vezes: 3, 6, 9, 12.",
			_board("groups", {"groups": 4, "size": 3}, ["3, 6, 9, 12", "!4 × 3 = 12"])),
		_p("preocupado", "Um erro muito comum é somar os dois números: 4 × 3 NÃO é 4 + 3. São 4 grupos de 3!",
			_text_board(["4 + 3 = 7   ← soma", "!4 × 3 = 12  ← grupos"])),
		_quiz("multiplication", "Sua vez! Quanto é 3 × 3?", "3 × 3 = ?", [6, 9, 12], 9,
			_board("groups", {"groups": 3, "size": 3}, ["3 × 3 = ?"]),
			"Isso! 3 grupos de 3: 3 + 3 + 3 = 9.",
			_board("groups", {"groups": 3, "size": 3}, ["3 + 3 + 3", "!3 × 3 = 9"])),
		_quiz("multiplication", "E 2 × 4?", "2 × 4 = ?", [6, 8, 10], 8,
			_board("groups", {"groups": 2, "size": 4}, ["2 × 4 = ?"]),
			"Muito bem! 2 grupos de 4: 4 + 4 = 8.",
			_board("groups", {"groups": 2, "size": 4}, ["4 + 4", "!2 × 4 = 8"])),
		_p("orgulhoso", "Guarde isso: multiplicar é somar grupos iguais; a ordem não importa; e dá para contar de tantos em tantos.",
			_text_board(["Multiplicar = grupos iguais", "A ordem não importa", "!Conte de tantos em tantos"]))
	]


static func _lesson_division():
	return [
		_p("explicando", "Na aldeia, a cozinheira tem 12 pães para 3 mesas. Dividir é REPARTIR em partes iguais.",
			_board("share", {"total": 12, "groups": 3, "values": false}, ["12 ÷ 3"])),
		_p("explicando", "Damos um pão para cada mesa, de novo e de novo, até acabar. No fim, cada mesa ficou com 4.",
			_board("share", {"total": 12, "groups": 3}, ["!12 ÷ 3 = 4"])),
		_p("pensativo", "Um truque: dividir é a multiplicação ao contrário. 12 ÷ 3 pergunta: 3 vezes quanto dá 12?",
			_text_board(["3 × ? = 12", "3 × 4 = 12", "!12 ÷ 3 = 4"])),
		_p("explicando", "Por isso quem sabe a tabuada divide rápido. Para 20 ÷ 5, pense: 5 × 4 = 20. Então 20 ÷ 5 = 4.",
			_text_board(["5 × ? = 20", "5 × 4 = 20", "!20 ÷ 5 = 4"])),
		_p("preocupado", "Cuidado para não confundir: dividir não é tirar. 12 ÷ 3 não é 12 − 3. É repartir em 3 partes iguais.",
			_text_board(["12 − 3 = 9   ← tirar", "!12 ÷ 3 = 4   ← repartir"])),
		_quiz("division", "Sua vez! Quanto é 8 ÷ 2?", "8 ÷ 2 = ?", [4, 6, 16], 4,
			_board("share", {"total": 8, "groups": 2, "values": false}, ["8 ÷ 2 = ?"]),
			"Isso! Repartindo 8 em 2 partes, cada uma fica com 4. E confere: 2 × 4 = 8.",
			_board("share", {"total": 8, "groups": 2}, ["!8 ÷ 2 = 4"])),
		_quiz("division", "E 15 ÷ 3?", "15 ÷ 3 = ?", [3, 5, 12], 5,
			_board("share", {"total": 15, "groups": 3, "values": false}, ["15 ÷ 3 = ?"]),
			"Muito bem! 3 × 5 = 15, então 15 ÷ 3 = 5.",
			_board("share", {"total": 15, "groups": 3}, ["3 × 5 = 15", "!15 ÷ 3 = 5"])),
		_p("orgulhoso", "Guarde isso: dividir é repartir igualmente; e, para achar a resposta, pense na multiplicação ao contrário.",
			_text_board(["Dividir = repartir igual", "!Pense: ? × divisor = total"]))
	]


static func _lesson_fraction():
	return [
		_p("explicando", "Uma fração é uma parte do todo. Olhe 3/4: o número de BAIXO diz em quantas partes iguais dividimos.",
			_board("fraction", {"parts": 4, "take": 0}, ["3/4  →  4 partes iguais"])),
		_p("explicando", "O número de CIMA diz quantas partes pegamos. 3/4 é pegar 3 das 4 partes.",
			_board("fraction", {"parts": 4, "take": 3}, ["!3 de 4 partes"])),
		_p("explicando", "Agora, 3/4 de 12. Primeiro dividimos 12 em 4 partes iguais: 12 ÷ 4 = 3 em cada parte.",
			_board("fraction", {"parts": 4, "take": 0, "total": 12, "values": true}, ["12 ÷ 4 = 3"])),
		_p("explicando", "Depois pegamos 3 partes: 3 + 3 + 3 = 9. Então 3/4 de 12 é 9.",
			_board("fraction", {"parts": 4, "take": 3, "total": 12, "values": true}, ["3 partes de 3", "!3/4 de 12 = 9"])),
		_p("pensativo", "O truque: divida pelo número de BAIXO e multiplique pelo de CIMA. E 1/2 é a metade: dividir por 2.",
			_text_board(["Divida pelo de BAIXO", "Multiplique pelo de CIMA", "!1/2 = metade"])),
		_p("preocupado", "Erro comum: parar no meio do caminho. 12 ÷ 4 = 3 é UMA parte só. Em 3/4 precisamos de 3 partes!",
			_text_board(["12 ÷ 4 = 3   ← uma parte", "!3 × 3 = 9   ← três partes"])),
		_quiz("fraction", "Sua vez! Quanto é 1/2 de 8?", "1/2 de 8 = ?", [2, 4, 6], 4,
			_board("fraction", {"parts": 2, "take": 1, "total": 8}, ["1/2 de 8 = ?"]),
			"Isso! Metade de 8: 8 ÷ 2 = 4.",
			_board("fraction", {"parts": 2, "take": 1, "total": 8, "values": true}, ["!1/2 de 8 = 4"])),
		_quiz("fraction", "E 2/3 de 9?", "2/3 de 9 = ?", [3, 6, 18], 6,
			_board("fraction", {"parts": 3, "take": 2, "total": 9}, ["2/3 de 9 = ?"]),
			"Muito bem! 9 ÷ 3 = 3 em cada parte, e 2 partes são 6.",
			_board("fraction", {"parts": 3, "take": 2, "total": 9, "values": true}, ["9 ÷ 3 = 3", "!2 × 3 = 6"])),
		_p("orgulhoso", "Guarde isso: o de baixo diz em quantas partes dividir; o de cima, quantas pegar.",
			_text_board(["Baixo: em quantas partes", "Cima: quantas partes pegar", "!Divida, depois multiplique"]))
	]


static func _lesson_percentage():
	return [
		_p("explicando", "Porcentagem quer dizer \"de cada cem\". 100% é o total, o inteiro.",
			_board("percent", {"percent": 100, "total": 20, "parts": 1}, ["100% = tudo"])),
		_p("explicando", "50% é a metade. Se uma barraca tem 20 balas, 50% delas são 10.",
			_board("percent", {"percent": 50, "total": 20, "parts": 2, "values": true}, ["!50% de 20 = 10"])),
		_p("explicando", "25% é a metade da metade: um quarto. 25% de 20 é 5.",
			_board("percent", {"percent": 25, "total": 20, "parts": 4, "values": true}, ["!25% de 20 = 5"])),
		_p("pensativo", "E 10% é dividir por 10. Com o 10%, achamos 20%, 30%... é só multiplicar: 30% de 20 é 3 × 2 = 6.",
			_board("percent", {"percent": 30, "total": 20, "parts": 10, "values": true}, ["10% de 20 = 2", "!30% = 3 × 2 = 6"])),
		_p("preocupado", "Cuidado com o Barão: 50% de desconto é pagar a METADE. Desconto nunca aumenta o preço!",
			_text_board(["Preço: 20", "50% de desconto: tira 10", "!Paga 10"])),
		_quiz("percentage", "Sua vez! Quanto é 50% de 8?", "50% de 8 = ?", [2, 4, 50], 4,
			_board("percent", {"percent": 50, "total": 8, "parts": 2}, ["50% de 8 = ?"]),
			"Isso! 50% é a metade: 8 ÷ 2 = 4.",
			_board("percent", {"percent": 50, "total": 8, "parts": 2, "values": true}, ["!50% de 8 = 4"])),
		_quiz("percentage", "E 10% de 30?", "10% de 30 = ?", [3, 10, 30], 3,
			_board("percent", {"percent": 10, "total": 30, "parts": 10}, ["10% de 30 = ?"]),
			"Muito bem! 10% é dividir por 10: 30 ÷ 10 = 3.",
			_board("percent", {"percent": 10, "total": 30, "parts": 10, "values": true}, ["!10% de 30 = 3"])),
		_p("orgulhoso", "Guarde isso: 50% é metade, 25% é um quarto e 10% é dividir por 10. O resto se monta a partir deles.",
			_text_board(["50% = metade", "25% = um quarto", "!10% = dividir por 10"]))
	]


# =====================================================================
# EXPLICAÇÃO DA CONTA ATUAL (dicas e botão AJUDA)
# =====================================================================

static func explain(operation, text, answer, level, closing = true):
	var n = MathTutor._numbers(text)
	var lines = []
	match operation:
		"addition":
			lines = _explain_addition(n, answer, level)
		"subtraction":
			lines = _explain_subtraction(n, answer, level)
		"multiplication":
			lines = _explain_multiplication(n, answer, level)
		"division":
			lines = _explain_division(n, answer, level)
		"fraction":
			lines = _explain_fraction(n, answer, level)
		"percentage":
			lines = _explain_percentage(n, answer, level)

	if lines.is_empty():
		lines = [_p("explicando", MathTutor.get_hint(operation, text, answer, level, false), _text_board([text]))]

	if level >= 2:
		lines.append(_p("orgulhoso", "Então a resposta é %d. Procure as peças %d no tabuleiro!" % [answer, answer], _text_board(["!%s" % text.replace("?", str(answer))])))
	elif closing:
		lines.append(_p("feliz", "Pense com calma e depois procure a resposta no tabuleiro. Você consegue!"))
	return lines


static func _explain_addition(n, answer, level):
	if n.size() < 2:
		return []
	if n.size() >= 3:
		var partial = n[0] + n[1]
		if level == 1:
			return [_p("explicando", "Três números? Vamos por partes: primeiro some %d + %d. Depois junte o %d." % [n[0], n[1], n[2]],
				_text_board(["%d + %d + %d" % [n[0], n[1], n[2]], "%d + %d = ?" % [n[0], n[1]], "e depois  + %d" % n[2]]))]
		return [
			_p("explicando", "Primeiro os dois primeiros: %d + %d = %d." % [n[0], n[1], partial],
				_board("add", {"a": n[0], "b": n[1], "joined": true, "count": true}, ["%d + %d = %d" % [n[0], n[1], partial]])),
			_p("explicando", "Agora juntamos o %d: começando no %d e contando mais %d, chegamos em %d." % [n[2], partial, n[2], answer],
				_text_board(["%d + %d = %d" % [n[0], n[1], partial], "!%d + %d = %d" % [partial, n[2], answer]]))
		]

	var big = max(n[0], n[1])
	var small = min(n[0], n[1])
	var dots = n[0] + n[1] <= 18
	if level == 1:
		var first = _p("explicando", "Somar é juntar: %d de um lado, %d do outro. Quantos são juntos?" % [n[0], n[1]],
			_board("add", {"a": n[0], "b": n[1]}, ["%d + %d" % [n[0], n[1]]]) if dots else _text_board(["%d + %d" % [n[0], n[1]]]))
		return [first, _p("pensativo", "Dica: comece no maior, o %d, e conte mais %d nos dedos." % [big, small],
			_text_board(["Comece no %d" % big, "e conte mais %d" % small]))]

	var steps = []
	for i in range(1, small + 1):
		steps.append(str(big + i))
	return [_p("explicando", "Começando no %d e contando mais %d: %s. Chegamos em %d." % [big, small, ", ".join(PackedStringArray(steps)), answer],
		_board("add", {"a": n[0], "b": n[1], "joined": true, "count": true}, ["!%d + %d = %d" % [n[0], n[1], answer]]) if dots else _text_board(["%d, depois %s" % [big, ", ".join(PackedStringArray(steps))], "!%d + %d = %d" % [n[0], n[1], answer]]))]


static func _explain_subtraction(n, answer, level):
	if n.size() < 2:
		return []
	if n.size() >= 3:
		var partial = n[0] - n[1]
		var board_ok = n[0] <= 30
		if level == 1:
			return [_p("explicando", "Duas subtrações? Tire uma de cada vez: primeiro %d − %d. Depois tire o %d do que sobrar." % [n[0], n[1], n[2]],
				_board("take", {"total": n[0], "take": n[2], "take2": n[1]}, ["%d − %d − %d" % [n[0], n[1], n[2]]]) if board_ok else _text_board(["%d − %d = ?" % [n[0], n[1]], "depois  − %d" % n[2]]))]
		return [
			_p("explicando", "Primeiro: %d − %d = %d." % [n[0], n[1], partial], _text_board(["!%d − %d = %d" % [n[0], n[1], partial]])),
			_p("explicando", "Depois tiramos o %d: %d − %d = %d." % [n[2], partial, n[2], answer],
				_board("take", {"total": n[0], "take": n[2], "take2": n[1], "cross": true, "result": true}, ["%d − %d = %d" % [n[0], n[1], partial], "!%d − %d = %d" % [partial, n[2], answer]]) if board_ok else _text_board(["%d − %d = %d" % [n[0], n[1], partial], "!%d − %d = %d" % [partial, n[2], answer]]))
		]

	var board_ok = n[0] <= 30
	if level == 1:
		return [
			_p("explicando", "Subtrair é tirar: começamos com %d e tiramos %d. Quantos sobram?" % [n[0], n[1]],
				_board("take", {"total": n[0], "take": n[1]}, ["%d − %d" % [n[0], n[1]]]) if board_ok else _text_board(["%d − %d" % [n[0], n[1]]])),
			_p("pensativo", "Dica: pense ao contrário. %d mais quanto chega em %d?" % [n[1], n[0]], _text_board(["%d + ? = %d" % [n[1], n[0]]]))
		]
	return [_p("explicando", "Riscando os %d que saíram, sobram %d. E confere: %d + %d = %d." % [n[1], answer, n[1], answer, n[0]],
		_board("take", {"total": n[0], "take": n[1], "cross": true, "result": true}, ["!%d − %d = %d" % [n[0], n[1], answer]]) if board_ok else _text_board(["%d + %d = %d" % [n[1], answer, n[0]], "!%d − %d = %d" % [n[0], n[1], answer]]))]


static func _explain_multiplication(n, answer, level):
	if n.size() < 2:
		return []
	var groups = n[0]
	var group_size = n[1]
	var parts = []
	for i in range(groups):
		parts.append(str(group_size))
	var sum_text = " + ".join(PackedStringArray(parts))
	var board_ok = groups <= 5 and group_size <= 6
	var board = _board("groups", {"groups": groups, "size": group_size}, ["%d × %d" % [groups, group_size]])
	if level == 1:
		return [
			_p("explicando", "%d × %d quer dizer %d grupos de %d." % [groups, group_size, groups, group_size], board if board_ok else _text_board(["%d grupos de %d" % [groups, group_size]])),
			_p("pensativo", "Some os grupos, %s, ou conte de %d em %d. Quanto dá?" % [sum_text, group_size, group_size], _text_board([sum_text + " = ?"]))
		]
	var counting = []
	for i in range(1, groups + 1):
		counting.append(str(group_size * i))
	board = _board("groups", {"groups": groups, "size": group_size}, [sum_text, "!%d × %d = %d" % [groups, group_size, answer]])
	return [_p("explicando", "São %d grupos de %d. Contando de %d em %d: %s." % [groups, group_size, group_size, group_size, ", ".join(PackedStringArray(counting))],
		board if board_ok else _text_board([sum_text, "!%d × %d = %d" % [groups, group_size, answer]]))]


static func _explain_division(n, answer, level):
	if n.size() < 2:
		return []
	var total = n[0]
	var divisor = n[1]
	var board_ok = total <= 24 and divisor <= 6
	if level == 1:
		var first = _p("explicando", "%d ÷ %d é repartir %d em %d partes iguais. Quanto fica em cada parte?" % [total, divisor, total, divisor],
			_board("share", {"total": total, "groups": divisor, "values": false}, ["%d ÷ %d" % [total, divisor]]) if board_ok else _text_board(["%d em %d partes iguais" % [total, divisor]]))
		return [first, _p("pensativo", "Dica: pense na tabuada ao contrário. %d vezes quanto dá %d?" % [divisor, total], _text_board(["%d × ? = %d" % [divisor, total]]))]

	var table = []
	var start = max(1, answer - 2)
	for i in range(start, answer + 1):
		table.append("%d × %d = %d" % [divisor, i, divisor * i])
	if board_ok:
		return [_p("explicando", "Repartindo %d em %d partes iguais, cada uma fica com %d. E confere: %d × %d = %d." % [total, divisor, answer, divisor, answer, total],
			_board("share", {"total": total, "groups": divisor}, ["!%d ÷ %d = %d" % [total, divisor, answer]]))]
	return [_p("explicando", "Vamos pela tabuada do %d até chegar em %d: ... %s." % [divisor, total, ", ".join(PackedStringArray(table))],
		_text_board([table[-1], "!%d ÷ %d = %d" % [total, divisor, answer]]))]


static func _explain_fraction(n, answer, level):
	if n.size() < 3:
		return []
	var top = n[0]
	var bottom = n[1]
	var total = n[2]
	var part = total / bottom
	if level == 1:
		return [
			_p("explicando", "Em %d/%d, o de baixo diz em quantas partes dividir: %d partes iguais." % [top, bottom, bottom],
				_board("fraction", {"parts": bottom, "take": 0, "total": total}, ["%d em %d partes" % [total, bottom]])),
			_p("pensativo", "Quanto vale cada parte (%d ÷ %d)? Depois pegue %s." % [total, bottom, "1 parte" if top == 1 else "%d partes" % top],
				_board("fraction", {"parts": bottom, "take": top, "total": total}, ["%d ÷ %d = ?" % [total, bottom], "pegue %d" % top]))
		]
	var lines = [_p("explicando", "Dividindo %d em %d partes iguais, cada parte vale %d." % [total, bottom, part],
		_board("fraction", {"parts": bottom, "take": 0, "total": total, "values": true}, ["%d ÷ %d = %d" % [total, bottom, part]]))]
	if top > 1:
		lines.append(_p("explicando", "Pegamos %d partes: %d × %d = %d." % [top, top, part, answer],
			_board("fraction", {"parts": bottom, "take": top, "total": total, "values": true}, ["%d ÷ %d = %d" % [total, bottom, part], "!%d × %d = %d" % [top, part, answer]])))
	return lines


static func _explain_percentage(n, answer, level):
	if n.size() < 2:
		return []
	var p = n[0]
	var total = n[1]

	if p == 100:
		return [_p("explicando", "100% é o total inteiro, sem tirar nada." if level == 1 else "100%% de %d é o próprio %d." % [total, total],
			_board("percent", {"percent": 100, "total": total, "parts": 1}, ["100% = tudo"]))]

	if p == 50:
		if level == 1:
			return [_p("explicando", "50%% é a metade. Qual é a metade de %d?" % total, _board("percent", {"percent": 50, "total": total, "parts": 2}, ["50% = metade"]))]
		return [_p("explicando", "50%% é a metade: %d ÷ 2 = %d." % [total, answer], _board("percent", {"percent": 50, "total": total, "parts": 2, "values": true}, ["!%d ÷ 2 = %d" % [total, answer]]))]

	if (p == 25 or p == 75) and total % 4 == 0:
		var quarter = total / 4
		if level == 1:
			return [_p("explicando", "25%% é um quarto: divida %d em 4 partes iguais.%s" % [total, " E 75% são 3 dessas partes." if p == 75 else ""],
				_board("percent", {"percent": p, "total": total, "parts": 4}, ["%d ÷ 4 = ?" % total]))]
		var lines_q = ["%d ÷ 4 = %d" % [total, quarter]]
		if p == 75:
			lines_q.append("!3 × %d = %d" % [quarter, answer])
		else:
			lines_q[0] = "!" + lines_q[0]
		return [_p("explicando", "Um quarto de %d é %d.%s" % [total, quarter, " Três quartos: 3 × %d = %d." % [quarter, answer] if p == 75 else ""],
			_board("percent", {"percent": p, "total": total, "parts": 4, "values": true}, lines_q))]

	if total % 10 == 0:
		var ten = total / 10
		var tens = int(p / 10)
		var five = p % 10 == 5
		var board = _board("percent", {"percent": p, "total": total, "parts": 20 if five else 10, "values": not five}, ["10%% de %d = %d" % [total, ten]])
		if level == 1:
			var msg = "Comece pelo 10%%: dividir %d por 10 dá %d." % [total, ten]
			if tens > 1:
				msg += " %d%% são %d vezes isso." % [tens * 10, tens]
			if five:
				msg += " E 5% é a metade do 10%."
			return [_p("explicando", msg, board)]
		var steps = ["10%% = %d" % ten]
		if tens > 1:
			steps.append("%d%% = %d × %d = %d" % [tens * 10, tens, ten, tens * ten])
		if five:
			steps.append("5%% = %d ÷ 2 = %d" % [ten, ten / 2])
		board["lines"] = steps
		return [_p("explicando", "Montando a partir do 10%%: %s. Juntando tudo, %d." % [", ".join(PackedStringArray(steps)), answer], board)]

	# Outros casos: porcentagem como fração (20% = 1/5...).
	var g = MathTutor._gcd(p, 100)
	var top = p / g
	var bottom = 100 / g
	var part = total / bottom
	if level == 1:
		return [_p("explicando", "%d%% é o mesmo que %d/%d: divida %d em %d partes iguais e pegue %d." % [p, top, bottom, total, bottom, top],
			_board("fraction", {"parts": bottom, "take": top, "total": total}, ["%d%% = %d/%d" % [p, top, bottom]]))]
	return [_p("explicando", "%d%% = %d/%d. %d ÷ %d = %d em cada parte, e %d partes dão %d." % [p, top, bottom, total, bottom, part, top, answer],
		_board("fraction", {"parts": bottom, "take": top, "total": total, "values": true}, ["%d ÷ %d = %d" % [total, bottom, part], "!%d × %d = %d" % [top, part, answer]]))]


# =====================================================================
# ERROS COMUNS
# =====================================================================
# Recebe o valor que o aluno escolheu (ou combinou no tabuleiro) e, se ele
# corresponder a um erro conhecido, explica o que aconteceu. Sem "close",
# só reconhece erros claros (no tabuleiro, peças combinadas por acaso não
# devem receber bronca).

static func misconception(operation, text, answer, value, close = false):
	if value == answer:
		return ""
	var n = MathTutor._numbers(text)
	var note = ""
	match operation:
		"addition":
			if n.size() == 2 and value == abs(n[0] - n[1]):
				note = "Você tirou em vez de juntar. Na adição a gente JUNTA: %d + %d." % [n[0], n[1]]
			elif n.size() >= 3 and (value == n[0] + n[1] or value == n[1] + n[2] or value == n[0] + n[2]):
				note = "Faltou somar um dos números! São três: %d + %d + %d." % [n[0], n[1], n[2]]
		"subtraction":
			if n.size() == 2 and value == n[0] + n[1]:
				note = "Você juntou! Na subtração a gente TIRA: começa com %d e tira %d." % [n[0], n[1]]
			elif n.size() >= 3 and value == n[0] - n[1]:
				note = "Faltou tirar o %d! Depois de %d − %d, ainda tem mais uma subtração." % [n[2], n[0], n[1]]
			elif n.size() >= 3 and value == n[0] - n[2]:
				note = "Faltou tirar o %d! São duas subtrações." % n[1]
			elif n.size() == 2 and value == n[1]:
				note = "%d é o quanto saiu. A pergunta é quanto SOBROU." % n[1]
		"multiplication":
			if n.size() >= 2 and value == n[0] + n[1]:
				note = "Você somou %d + %d. Multiplicar é somar grupos: %d grupos de %d." % [n[0], n[1], n[0], n[1]]
			elif n.size() >= 2 and (value == answer - n[1] or value == answer + n[1]):
				note = "Quase! Parece que faltou ou sobrou um grupo de %d. Conte os grupos de novo." % n[1]
		"division":
			if n.size() >= 2 and value == n[0] - n[1]:
				note = "Você tirou %d. Dividir não é tirar: é repartir %d em %d partes iguais." % [n[1], n[0], n[1]]
			elif n.size() >= 2 and value == n[1]:
				note = "%d é em quantas partes repartimos. A pergunta é quanto fica em CADA parte." % n[1]
			elif n.size() >= 2 and value == n[0] * n[1]:
				note = "Você multiplicou. Dividir é o contrário: %d vezes quanto dá %d?" % [n[1], n[0]]
		"fraction":
			if n.size() >= 3:
				var part = n[2] / max(n[1], 1)
				if n[0] > 1 and value == part:
					note = "Isso é UMA parte só (%d ÷ %d). Em %d/%d precisamos de %d partes." % [n[2], n[1], n[0], n[1], n[0]]
				elif value == n[2] * n[0]:
					note = "Faltou dividir! Primeiro reparta %d em %d partes iguais." % [n[2], n[1]]
				elif value == n[0] or value == n[1]:
					note = "%d é um número da fração, não a resposta. Divida %d em %d partes e pegue %d." % [value, n[2], n[1], n[0]]
		"percentage":
			if n.size() >= 2:
				if value == n[0]:
					note = "%d%% não é %d. Porcentagem é \"de cada 100\": precisamos calcular a parte de %d." % [n[0], n[0], n[1]]
				elif value == n[1] - answer and n[0] != 50:
					note = "Isso é o que SOBRA. A pergunta é quanto são os %d%%." % n[0]
				elif value == n[1]:
					note = "%d é o total, ou seja, 100%%. Queremos só %d%% dele." % [n[1], n[0]]

	if note == "" and close and abs(value - answer) == 1:
		note = "Quase! Ficou %s 1. Confira a conta com calma." % ("faltando" if value < answer else "sobrando")
	return note
