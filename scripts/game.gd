extends Control

const ROWS = 8
const COLS = 8
const LOW_MOVES_WARNING = 3
# Item 6: destaca as peças da resposta até esta dificuldade (1 = só fases fáceis).
const HINT_MAX_DIFFICULTY = 1
const HINT_BORDER_COLOR = Color("#FDE047")

# Ajuda por erros: quantos erros seguidos (no mesmo desafio) liberam cada nível de dica.
# 1 = estratégia • 2 = mostra a resposta • 3 = aponta uma troca no tabuleiro
const HINT_STEP_STRATEGY = 2
const HINT_STEP_ANSWER = 4
const HINT_STEP_MOVE = 6
const MOVE_HINT_COLOR = Color("#22C55E")
const INSTRUCTION_COLOR = Color(0.7961, 0.8353, 0.8824, 1)

const MathTutor = preload("res://scripts/math_tutor.gd")
const OptionsPanel = preload("res://scripts/options_panel.gd")
const EMPTY_TILE_COLOR = Color("#1E293B")

const TILE_COLORS = [
	Color("#EF4444"),
	Color("#3B82F6"),
	Color("#22C55E"),
	Color("#A855F7"),
	Color("#F59E0B"),
	Color("#EC4899"),
	Color("#06B6D4"),
	Color("#EAB308"),
	Color("#6366F1"),
	Color("#84CC16"),
	Color("#F43F5E"),
	Color("#14B8A6")
]

var board = []
var buttons = []
var selected = Vector2i(-1, -1)
var score = 0
var moves = 0
var busy = false
var stage_finished = false

var context = "classic"
var mode = "classic"
var difficulty = 1
var current_tile_types = 6
var target_answer = -1
var solved_challenges = 0
var required_challenges = 0
var move_limit = 0
var stage_data = {}

var result_overlay
var result_title
var result_details
var next_button
var retry_button
var result_back_button
var result_stars_holder
var dev_skip_button
var challenge_tween

# Dicas
var mistakes = 0
var hint_level = 0
var hint_text = ""
var hint_move = []
var current_challenge_text = ""

# Mini-aula
var help_button
var lesson_overlay
var lesson_open = false
var lesson_title
var lesson_idea
var lesson_example
var lesson_lines
var lesson_tip
var lesson_question
var lesson_options_box
var lesson_feedback
var lesson_play_button
var lesson_practice = {}
var lesson_wrong = 0

# Pausa
var paused = false
var pause_overlay
var pause_main_box
var pause_confirm_box
var pause_confirm_label
var pause_confirm_action = ""
var pause_continue_button
var options_panel

# Camada por cima de cada peça (seleção, destaque, troca sugerida)
var tile_overlays = []

# Tutorial (Fase 0)
const TUTORIAL_STEPS = 5
var tut_step = 0
var tut_expected = []
var tut_waiting = false

@onready var header = $Margin/Main/Header
@onready var grid = $Margin/Main/BoardPanel/BoardMargin/Grid
@onready var score_label = $Margin/Main/HUD/ScoreLabel
@onready var moves_label = $Margin/Main/HUD/MovesLabel
@onready var challenges_label = $Margin/Main/HUD/ChallengesLabel
@onready var status_label = $Margin/Main/StatusLabel
@onready var menu_button = $Margin/Main/Header/MenuButton
@onready var restart_button = $Margin/Main/Header/RestartButton
@onready var mode_label = $Margin/Main/ModeLabel
@onready var challenge_panel = $Margin/Main/ChallengePanel
@onready var challenge_label = $Margin/Main/ChallengePanel/ChallengeMargin/ChallengeBox/ChallengeLabel
@onready var challenge_instruction = $Margin/Main/ChallengePanel/ChallengeMargin/ChallengeBox/ChallengeInstruction
@onready var dev_answer_label = $Margin/Main/ChallengePanel/ChallengeMargin/ChallengeBox/DevAnswerLabel


func _ready():
	randomize()
	context = GameState.game_context
	mode = GameState.game_mode
	menu_button.pressed.connect(_open_pause)
	restart_button.pressed.connect(_new_game)
	_apply_visual_assets()
	_create_buttons()
	_build_result_overlay()
	_build_lesson_overlay()
	_build_pause_overlay()
	_setup_mode_interface()
	_create_help_button()
	challenge_instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	# Reiniciar agora fica dentro do menu de pausa (com confirmação).
	restart_button.visible = false
	menu_button.text = "II PAUSA"
	Assets.apply_button(menu_button)
	_new_game()
	Audio.play_music("partida")

	# Primeira vez neste conteúdo: abre a mini-aula prática antes de jogar.
	if context == "campaign" and not GameState.has_seen_lesson(mode):
		_open_lesson(true)


func _setup_mode_interface():
	if context == "campaign":
		stage_data = GameState.get_current_stage()
		if stage_data.is_empty():
			GameState.start_campaign_stage(1)
			stage_data = GameState.get_current_stage()

		difficulty = int(stage_data["difficulty"])
		current_tile_types = int(stage_data["tile_types"])
		required_challenges = int(stage_data["required"])
		move_limit = int(stage_data["moves"])
		mode = stage_data["operation"]
		mode_label.text = "FASE %02d • %s • %s" % [stage_data["id"], GameState.get_mode_title(mode), GameState.get_difficulty_title(difficulty)]
		challenge_panel.visible = true
		challenges_label.visible = true
		dev_answer_label.visible = false
	elif context == "developer":
		difficulty = GameState.dev_difficulty
		stage_data = GameState.get_stage_for_mode_difficulty(mode, difficulty)
		current_tile_types = _tile_types_for_difficulty(difficulty)

		if not stage_data.is_empty():
			required_challenges = int(stage_data["required"])
			move_limit = int(stage_data["moves"])
			current_tile_types = int(stage_data["tile_types"])
			mode_label.text = "DEV • FASE %02d • %s • %s" % [stage_data["id"], GameState.get_mode_title(mode), GameState.get_difficulty_title(difficulty)]
		else:
			mode_label.text = "DEV • %s • %s" % [GameState.get_mode_title(mode), GameState.get_difficulty_title(difficulty)]

		challenge_panel.visible = true
		challenges_label.visible = true
		dev_answer_label.visible = true
		_create_dev_skip_button()
	elif context == "tutorial":
		mode = "addition"
		difficulty = 1
		current_tile_types = 6
		required_challenges = 0
		move_limit = 0
		mode_label.text = "FASE 0 • TUTORIAL • APRENDA A JOGAR"
		challenge_panel.visible = true
		challenges_label.visible = true
		dev_answer_label.visible = false
		challenge_instruction.add_theme_font_size_override("font_size", 15)
	else:
		mode = "classic"
		difficulty = 1
		current_tile_types = 6
		mode_label.text = "MODO CLÁSSICO"
		challenge_panel.visible = false
		challenges_label.visible = false


func _tile_types_for_difficulty(value):
	match int(value):
		1:
			return 6
		2:
			return 9
		3:
			return 12
		_:
			return 6


func _create_dev_skip_button():
	if dev_skip_button != null:
		return

	dev_skip_button = Button.new()
	dev_skip_button.text = "✓ CONCLUIR E AVANÇAR"
	dev_skip_button.custom_minimum_size = Vector2(205, 42)
	dev_skip_button.add_theme_font_size_override("font_size", 13)
	dev_skip_button.add_theme_color_override("font_color", Color("#F8FAFC"))
	dev_skip_button.tooltip_text = "Marca a fase como concluída, credita XP/pontuação de teste e abre a próxima fase."
	dev_skip_button.pressed.connect(_on_dev_skip_stage_pressed)
	Assets.apply_button(dev_skip_button)
	header.add_child(dev_skip_button)


func _create_buttons():
	buttons.clear()

	for child in grid.get_children():
		child.queue_free()

	for r in range(ROWS):
		for c in range(COLS):
			var button = Button.new()
			button.custom_minimum_size = Vector2(64, 64)
			button.focus_mode = Control.FOCUS_NONE
			button.add_theme_font_size_override("font_size", 21)
			button.set_meta("no_click_sound", true)
			button.pressed.connect(_on_tile_pressed.bind(r, c))
			grid.add_child(button)
			buttons.append(button)

			var overlay = Panel.new()
			overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			overlay.visible = false
			button.add_child(overlay)
			tile_overlays.append(overlay)


func _new_game():
	if busy and not stage_finished:
		return

	stage_finished = false
	busy = false
	score = 0
	moves = 0
	solved_challenges = 0
	selected = Vector2i(-1, -1)
	result_overlay.visible = false
	_reset_hints()

	if context == "tutorial":
		_tutorial_start()
		return

	if context != "classic":
		_generate_challenge()

	_generate_board()
	_refresh_board()
	_update_hud()

	if context == "campaign":
		status_label.text = "Complete %d desafios antes de atingir o limite de %d jogadas." % [required_challenges, move_limit]
	elif context == "developer":
		status_label.text = "Resolva o desafio ou use CONCLUIR E AVANÇAR para testar a progressão rapidamente."
	else:
		status_label.text = "Faça uma combinação de 3 ou mais peças iguais."


func _generate_board():
	for attempt in range(120):
		board.clear()

		for r in range(ROWS):
			var row = []

			for c in range(COLS):
				var value = randi() % current_tile_types
				var valid = false

				while not valid:
					valid = true

					if c >= 2:
						if row[c - 1] == value and row[c - 2] == value:
							valid = false

					if r >= 2:
						if board[r - 1][c] == value and board[r - 2][c] == value:
							valid = false

					if not valid:
						value = randi() % current_tile_types

				row.append(value)

			board.append(row)

		if context != "classic" and target_answer >= 1 and _count_tile(target_answer - 1) < 5:
			continue

		if _has_possible_move():
			break

	# Se as tentativas aleatórias falharem, a função abaixo corrige o tabuleiro.
	_make_board_playable(context != "classic")


func _generate_challenge():
	var data = {}

	match mode:
		"addition":
			data = _make_addition_challenge()
		"subtraction":
			data = _make_subtraction_challenge()
		"multiplication":
			data = _make_multiplication_challenge()
		"division":
			data = _make_division_challenge()
		"fraction":
			data = _make_fraction_challenge()
		"percentage":
			data = _make_percentage_challenge()
		_:
			data = {"text": "1 + 1 = ?", "answer": 2}

	target_answer = int(data["answer"])
	current_challenge_text = data["text"]
	challenge_label.text = data["text"]
	_refresh_instruction()

	dev_answer_label.text = "DEV • resposta esperada: %d" % target_answer


func _make_addition_challenge():
	var max_answer = current_tile_types

	if difficulty == 1:
		max_answer = min(max_answer, 6)
		var answer = _rand_between(2, max_answer)
		var a = _rand_between(1, answer - 1)
		var b = answer - a
		return {"text": "%d + %d = ?" % [a, b], "answer": answer}

	if difficulty == 2:
		max_answer = min(max_answer, 9)
		var answer = _rand_between(4, max_answer)
		var a = _rand_between(1, answer - 1)
		var b = answer - a
		return {"text": "%d + %d = ?" % [a, b], "answer": answer}

	max_answer = min(max_answer, 12)
	var answer = _rand_between(6, max_answer)
	var a = _rand_between(1, answer - 2)
	var b = _rand_between(1, answer - a - 1)
	var c = answer - a - b
	return {"text": "%d + %d + %d = ?" % [a, b, c], "answer": answer}


func _make_subtraction_challenge():
	var max_answer = current_tile_types

	if difficulty == 1:
		var answer = _rand_between(1, min(max_answer, 6))
		var b = _rand_between(1, 6)
		var a = answer + b
		return {"text": "%d − %d = ?" % [a, b], "answer": answer}

	if difficulty == 2:
		var answer = _rand_between(2, min(max_answer, 9))
		var b = _rand_between(4, 12)
		var a = answer + b
		return {"text": "%d − %d = ?" % [a, b], "answer": answer}

	var answer = _rand_between(3, min(max_answer, 12))
	var b = _rand_between(4, 10)
	var c = _rand_between(2, 8)
	var a = answer + b + c
	return {"text": "%d − %d − %d = ?" % [a, b, c], "answer": answer}


func _make_multiplication_challenge():
	var options = []

	if difficulty == 1:
		options = [
			{"text": "1 × 2 = ?", "answer": 2},
			{"text": "1 × 3 = ?", "answer": 3},
			{"text": "2 × 2 = ?", "answer": 4},
			{"text": "1 × 5 = ?", "answer": 5},
			{"text": "2 × 3 = ?", "answer": 6}
		]
	elif difficulty == 2:
		options = [
			{"text": "2 × 2 = ?", "answer": 4},
			{"text": "2 × 3 = ?", "answer": 6},
			{"text": "2 × 4 = ?", "answer": 8},
			{"text": "3 × 3 = ?", "answer": 9},
			{"text": "4 × 2 = ?", "answer": 8}
		]
	else:
		options = [
			{"text": "2 × 4 = ?", "answer": 8},
			{"text": "3 × 3 = ?", "answer": 9},
			{"text": "2 × 5 = ?", "answer": 10},
			{"text": "2 × 6 = ?", "answer": 12},
			{"text": "3 × 4 = ?", "answer": 12},
			{"text": "4 × 3 = ?", "answer": 12}
		]

	return _pick_valid_option(options)


func _make_division_challenge():
	var max_answer = current_tile_types
	var answer = 1
	var divisor = 2

	if difficulty == 1:
		answer = _rand_between(1, min(max_answer, 6))
		divisor = _rand_between(2, 4)
	elif difficulty == 2:
		answer = _rand_between(2, min(max_answer, 9))
		divisor = _rand_between(3, 7)
	else:
		answer = _rand_between(3, min(max_answer, 12))
		divisor = _rand_between(5, 12)

	var dividend = answer * divisor
	return {"text": "%d ÷ %d = ?" % [dividend, divisor], "answer": answer}


func _make_fraction_challenge():
	var options = []

	if difficulty == 1:
		options = [
			{"text": "1/2 de 2 = ?", "answer": 1},
			{"text": "1/2 de 4 = ?", "answer": 2},
			{"text": "1/2 de 6 = ?", "answer": 3},
			{"text": "1/2 de 8 = ?", "answer": 4},
			{"text": "1/3 de 15 = ?", "answer": 5},
			{"text": "1/2 de 12 = ?", "answer": 6}
		]
	elif difficulty == 2:
		options = [
			{"text": "2/3 de 6 = ?", "answer": 4},
			{"text": "3/4 de 8 = ?", "answer": 6},
			{"text": "2/3 de 9 = ?", "answer": 6},
			{"text": "3/4 de 12 = ?", "answer": 9},
			{"text": "2/5 de 20 = ?", "answer": 8},
			{"text": "1/3 de 21 = ?", "answer": 7}
		]
	else:
		options = [
			{"text": "3/5 de 15 = ?", "answer": 9},
			{"text": "5/6 de 12 = ?", "answer": 10},
			{"text": "3/4 de 16 = ?", "answer": 12},
			{"text": "4/5 de 15 = ?", "answer": 12},
			{"text": "7/8 de 8 = ?", "answer": 7},
			{"text": "5/8 de 16 = ?", "answer": 10}
		]

	return _pick_valid_option(options)


func _make_percentage_challenge():
	var options = []

	if difficulty == 1:
		options = [
			{"text": "50% de 2 = ?", "answer": 1},
			{"text": "50% de 4 = ?", "answer": 2},
			{"text": "100% de 3 = ?", "answer": 3},
			{"text": "50% de 8 = ?", "answer": 4},
			{"text": "50% de 10 = ?", "answer": 5},
			{"text": "50% de 12 = ?", "answer": 6}
		]
	elif difficulty == 2:
		options = [
			{"text": "25% de 16 = ?", "answer": 4},
			{"text": "20% de 25 = ?", "answer": 5},
			{"text": "75% de 8 = ?", "answer": 6},
			{"text": "25% de 28 = ?", "answer": 7},
			{"text": "40% de 20 = ?", "answer": 8},
			{"text": "30% de 30 = ?", "answer": 9}
		]
	else:
		options = [
			{"text": "15% de 60 = ?", "answer": 9},
			{"text": "20% de 50 = ?", "answer": 10},
			{"text": "25% de 44 = ?", "answer": 11},
			{"text": "30% de 40 = ?", "answer": 12},
			{"text": "35% de 20 = ?", "answer": 7},
			{"text": "45% de 20 = ?", "answer": 9}
		]

	return _pick_valid_option(options)


func _pick_valid_option(options):
	var valid_options = []

	for option in options:
		if int(option["answer"]) <= current_tile_types:
			valid_options.append(option)

	if valid_options.size() == 0:
		return {"text": "1 + 1 = ?", "answer": 2}

	return valid_options[randi() % valid_options.size()]


func _rand_between(min_value, max_value):
	var low = int(min_value)
	var high = int(max_value)
	if high <= low:
		return low
	return low + (randi() % (high - low + 1))


func _on_tile_pressed(r, c):
	if busy or stage_finished or lesson_open or paused:
		return

	var current = Vector2i(c, r)

	# No tutorial, só as peças destacadas podem ser tocadas.
	if context == "tutorial" and not tut_expected.has(current):
		if not tut_waiting:
			status_label.text = "Toque em uma das peças com borda verde."
			Audio.play("troca_invalida")
		return
	Audio.play("selecionar")

	if selected.x == -1:
		selected = current
		status_label.text = "Escolha uma peça vizinha para trocar."
		_refresh_board()
		return

	if current == selected:
		selected = Vector2i(-1, -1)
		status_label.text = "Seleção cancelada."
		_refresh_board()
		return

	if not _are_adjacent(selected, current):
		selected = current
		status_label.text = "Agora escolha uma peça vizinha."
		_refresh_board()
		return

	await _try_swap(selected, current)


func _are_adjacent(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y) == 1


func _try_swap(a, b):
	busy = true
	_swap(a, b)
	_refresh_board()
	await get_tree().create_timer(0.10).timeout

	var matches = _find_matches()

	if matches.size() == 0:
		_swap(a, b)
		selected = Vector2i(-1, -1)
		_refresh_board()
		status_label.text = "Essa troca não forma uma combinação."
		Audio.play("troca_invalida")
		busy = false
		_register_mistake()
		if context == "tutorial":
			_tutorial_after_move(false, true)
		return

	Audio.play("trocar")
	moves += 1
	selected = Vector2i(-1, -1)
	await _resolve_matches()

	if not stage_finished:
		busy = false


func _swap(a, b):
	var temp = board[a.y][a.x]
	board[a.y][a.x] = board[b.y][b.x]
	board[b.y][b.x] = temp


func _find_matches():
	var marked = {}

	for r in range(ROWS):
		for c in range(COLS - 2):
			var value = board[r][c]
			if value == -1:
				continue

			if board[r][c + 1] == value and board[r][c + 2] == value:
				marked[Vector2i(c, r)] = true
				marked[Vector2i(c + 1, r)] = true
				marked[Vector2i(c + 2, r)] = true

	for c in range(COLS):
		for r in range(ROWS - 2):
			var value = board[r][c]
			if value == -1:
				continue

			if board[r + 1][c] == value and board[r + 2][c] == value:
				marked[Vector2i(c, r)] = true
				marked[Vector2i(c, r + 1)] = true
				marked[Vector2i(c, r + 2)] = true

	return marked.keys()


func _matches_target(matches):
	if context == "classic" or target_answer < 1:
		return false

	var target_value = target_answer - 1

	for pos in matches:
		if board[pos.y][pos.x] == target_value:
			return true

	return false


func _resolve_matches():
	var combo = 1
	var solved_this_move = false

	while true:
		var matches = _find_matches()

		if matches.size() == 0:
			break

		if not solved_this_move and _matches_target(matches):
			solved_this_move = true
			solved_challenges += 1
			var challenge_bonus = 100 * difficulty
			score += challenge_bonus
			_play_challenge_pulse()
			Audio.play("acerto")
			Assets.burst(self, challenge_label.get_global_rect().get_center(), 16)

		var points = matches.size() * 10 * combo
		score += points

		if combo == 1:
			Audio.play("combinar")
		else:
			# Cascata: o som fica um pouco mais agudo a cada combo.
			Audio.play("combo", min(1.0 + 0.08 * (combo - 1), 1.5))

		if solved_this_move:
			status_label.text = "Resposta correta! Bônus matemático +%d • combo x%d" % [100 * difficulty, combo]
		else:
			status_label.text = "Combinação x%d! +%d pontos" % [combo, points]

		_update_hud()

		for pos in matches:
			board[pos.y][pos.x] = -1

		_refresh_board()
		await get_tree().create_timer(0.13).timeout

		_collapse_board()
		_refill_board()
		_refresh_board()
		await get_tree().create_timer(0.13).timeout

		combo += 1

	# Depois de uma jogada comum, só garante que ainda existe alguma jogada.
	# A jogada da resposta é garantida no início de cada desafio e pela dica.
	var rebuilt = _make_board_playable(false)
	if rebuilt:
		_refresh_board()
		status_label.text = "Algumas peças foram reorganizadas para o jogo continuar."

	_update_hud()

	if context == "campaign":
		if solved_challenges >= required_challenges:
			_show_campaign_victory()
			return

		if moves >= move_limit:
			_show_campaign_failure()
			return

		if solved_this_move:
			_reset_hints()
			_generate_challenge()
			_make_board_playable(true)
			_refresh_board()
			status_label.text = "Desafio concluído! Próximo desafio gerado."
		else:
			status_label.text = "A combinação valeu pontos, mas não era a resposta do desafio."
			_register_mistake()
	elif context == "developer":
		if solved_this_move:
			_reset_hints()
			_generate_challenge()
			_make_board_playable(true)
			_refresh_board()
			status_label.text = "Desafio concluído! Um novo desafio foi gerado."
		else:
			status_label.text = "A combinação valeu pontos, mas não era a resposta do desafio."
			_register_mistake()
	elif context == "tutorial":
		_tutorial_after_move(solved_this_move, false)
	else:
		status_label.text = "Boa! Faça a próxima combinação."


func _play_challenge_pulse():
	if challenge_tween != null and challenge_tween.is_valid():
		challenge_tween.kill()

	# Escala a partir do centro do texto.
	challenge_label.pivot_offset = challenge_label.size / 2.0
	challenge_label.scale = Vector2.ONE
	challenge_label.modulate = Color.WHITE

	challenge_tween = create_tween()
	challenge_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	challenge_tween.tween_property(challenge_label, "scale", Vector2(1.25, 1.25), 0.12)
	challenge_tween.parallel().tween_property(challenge_label, "modulate", Color("#86EFAC"), 0.12)
	challenge_tween.tween_property(challenge_label, "scale", Vector2.ONE, 0.20)
	challenge_tween.parallel().tween_property(challenge_label, "modulate", Color.WHITE, 0.30)


func _collapse_board():
	for c in range(COLS):
		var write_row = ROWS - 1

		for r in range(ROWS - 1, -1, -1):
			if board[r][c] != -1:
				board[write_row][c] = board[r][c]
				if write_row != r:
					board[r][c] = -1
				write_row -= 1

		while write_row >= 0:
			board[write_row][c] = -1
			write_row -= 1


func _refill_board():
	for r in range(ROWS):
		for c in range(COLS):
			if board[r][c] == -1:
				board[r][c] = randi() % current_tile_types

	# No tutorial, as peças novas não formam cascatas nem a resposta por acaso.
	if context == "tutorial":
		for r in range(ROWS):
			for c in range(COLS):
				if _would_create_match_at(r, c, board[r][c]) or board[r][c] == target_answer - 1:
					board[r][c] = _safe_value_at(r, c)


func _safe_value_at(r, c):
	var options = []
	for v in range(current_tile_types):
		if v == target_answer - 1:
			continue
		board[r][c] = v
		if not _would_create_match_at(r, c, v):
			options.append(v)
	if options.is_empty():
		return (target_answer) % current_tile_types
	return options[randi() % options.size()]


func _count_tile(value):
	var count = 0
	for r in range(ROWS):
		for c in range(COLS):
			if board[r][c] == value:
				count += 1
	return count


func _ensure_target_presence(minimum_count):
	if target_answer < 1:
		return

	var target_value = target_answer - 1
	var count = _count_tile(target_value)
	if count >= minimum_count:
		return

	var candidates = []
	for r in range(ROWS):
		for c in range(COLS):
			if board[r][c] != target_value:
				candidates.append(Vector2i(c, r))

	candidates.shuffle()

	for pos in candidates:
		if count >= minimum_count:
			break
		if not _would_create_match_at(pos.y, pos.x, target_value):
			board[pos.y][pos.x] = target_value
			count += 1


func _would_create_match_at(r, c, value):
	var horizontal = 1
	var vertical = 1

	var x = c - 1
	while x >= 0 and board[r][x] == value:
		horizontal += 1
		x -= 1

	x = c + 1
	while x < COLS and board[r][x] == value:
		horizontal += 1
		x += 1

	var y = r - 1
	while y >= 0 and board[y][c] == value:
		vertical += 1
		y -= 1

	y = r + 1
	while y < ROWS and board[y][c] == value:
		vertical += 1
		y += 1

	return horizontal >= 3 or vertical >= 3


func _has_possible_move():
	for r in range(ROWS):
		for c in range(COLS):
			var a = Vector2i(c, r)

			if c + 1 < COLS:
				var b_horizontal = Vector2i(c + 1, r)
				_swap(a, b_horizontal)
				var horizontal_match = _find_matches().size() > 0
				_swap(a, b_horizontal)
				if horizontal_match:
					return true

			if r + 1 < ROWS:
				var b_vertical = Vector2i(c, r + 1)
				_swap(a, b_vertical)
				var vertical_match = _find_matches().size() > 0
				_swap(a, b_vertical)
				if vertical_match:
					return true

	return false


func _refresh_board():
	if buttons.size() != ROWS * COLS:
		return

	var show_hint = _should_show_hint()

	for r in range(ROWS):
		for c in range(COLS):
			var index = r * COLS + c
			var button = buttons[index]
			var value = board[r][c]

			if value == -1:
				button.text = ""
				_set_tile_style(button, -1, false)
				_set_tile_overlay(index, "")
			else:
				button.text = str(value + 1)
				var is_selected = selected == Vector2i(c, r)
				var is_hint = show_hint and value == target_answer - 1
				var is_move = hint_move.has(Vector2i(c, r))
				_set_tile_style(button, value, is_selected, is_hint, is_move)

				var state = ""
				if is_selected:
					state = "selecionada"
				elif is_move:
					state = "troca_sugerida"
				elif is_hint:
					state = "destaque_resposta"
				_set_tile_overlay(index, state)


func _should_show_hint():
	if context == "classic" or target_answer < 1:
		return false
	# Depois de muitos erros (nível 2+), destaca a resposta em qualquer dificuldade.
	return difficulty <= HINT_MAX_DIFFICULTY or hint_level >= 2


# Fundo da peça: imagem assets/imagens/pecas/peca_XX.png se existir,
# senão o retângulo colorido. As bordas de estado ficam na camada de cima.
func _set_tile_style(button, value, _is_selected = false, _is_hint = false, _is_move = false):
	var tex = null
	var color = EMPTY_TILE_COLOR
	if value == -1:
		tex = Assets.texture("pecas/casa_vazia")
	else:
		tex = Assets.texture("pecas/peca_%02d" % (value + 1))
		color = TILE_COLORS[value]

	var style
	var hover_style
	var pressed_style

	if tex != null:
		style = Assets.texture_style(tex)
		hover_style = Assets.texture_style(tex, 0, Color(1.08, 1.08, 1.08))
		pressed_style = Assets.texture_style(tex, 0, Color(0.88, 0.88, 0.88))
		# A peça da Kenney tem uma "sombra" embaixo: sobe o número para o centro da face.
		for st in [style, hover_style, pressed_style]:
			st.content_margin_bottom = 6
		# Contorno escuro para o número continuar legível sobre a imagem.
		button.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
		button.add_theme_constant_override("outline_size", 6)
		button.add_theme_font_size_override("font_size", 26)
	else:
		style = _flat_tile_style(color)
		hover_style = _flat_tile_style(color.lightened(0.08))
		pressed_style = _flat_tile_style(color.darkened(0.08))

	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)


func _flat_tile_style(color):
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	return style


# Camada de estado: imagem assets/imagens/pecas/estado_*.png se existir,
# senão uma borda desenhada por código (branca, verde ou amarela).
func _set_tile_overlay(index, state):
	if index >= tile_overlays.size():
		return
	var overlay = tile_overlays[index]

	if state == "":
		overlay.visible = false
		return

	var tex = Assets.texture("pecas/estado_" + state)
	if tex != null:
		overlay.add_theme_stylebox_override("panel", Assets.texture_style(tex))
	else:
		var border = StyleBoxFlat.new()
		border.draw_center = false
		border.corner_radius_top_left = 12
		border.corner_radius_top_right = 12
		border.corner_radius_bottom_left = 12
		border.corner_radius_bottom_right = 12
		var width = 3
		match state:
			"selecionada":
				border.border_color = Color.WHITE
				width = 4
			"troca_sugerida":
				border.border_color = MOVE_HINT_COLOR
				width = 5
			_:
				border.border_color = HINT_BORDER_COLOR
				width = 3
		border.border_width_left = width
		border.border_width_top = width
		border.border_width_right = width
		border.border_width_bottom = width
		overlay.add_theme_stylebox_override("panel", border)

	overlay.visible = true


# Fundos e painéis da partida (só trocam se o arquivo existir).
func _apply_visual_assets():
	var bg_tex = Assets.texture("fundos/fundo_partida")
	if bg_tex != null:
		var bg = TextureRect.new()
		bg.texture = bg_tex
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(bg)
		move_child(bg, 1)

	Assets.apply_panel($Margin/Main/BoardPanel, "fundo_tabuleiro", false)
	Assets.apply_panel(challenge_panel, "painel_desafio")
	$Margin/Main/Note.visible = false


func _update_hud():
	score_label.text = "PONTOS: %d" % score

	if context == "campaign":
		moves_label.text = "JOGADAS: %d/%d" % [moves, move_limit]
		var remaining = move_limit - moves
		if remaining <= LOW_MOVES_WARNING:
			moves_label.add_theme_color_override("font_color", Color("#EF4444"))
			moves_label.text += "  ⚠ %d restantes" % remaining
		else:
			moves_label.add_theme_color_override("font_color", Color("#F8FAFC"))
		challenges_label.text = "OBJETIVO: %d/%d" % [solved_challenges, required_challenges]
		_refresh_instruction()
	elif context == "developer":
		moves_label.text = "JOGADAS: %d" % moves
		challenges_label.text = "DESAFIOS: %d" % solved_challenges
	elif context == "tutorial":
		moves_label.text = "JOGADAS: %d" % moves
		challenges_label.text = "PASSO: %d/%d" % [min(tut_step, TUTORIAL_STEPS), TUTORIAL_STEPS]
	else:
		moves_label.text = "JOGADAS: %d" % moves


func _build_result_overlay():
	result_overlay = Control.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	result_overlay.visible = false
	add_child(result_overlay)

	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.82)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	result_overlay.add_child(shade)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(470, 330)
	Assets.apply_panel(panel, "painel_janela")
	center.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 34)
	margin.add_theme_constant_override("margin_right", 34)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)

	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 16)
	margin.add_child(box)

	result_title = Label.new()
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_title.add_theme_font_size_override("font_size", 30)
	result_title.add_theme_color_override("font_color", Color("#F5C542"))
	box.add_child(result_title)

	result_stars_holder = CenterContainer.new()
	result_stars_holder.visible = false
	box.add_child(result_stars_holder)

	result_details = Label.new()
	result_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_details.add_theme_font_size_override("font_size", 16)
	result_details.add_theme_color_override("font_color", Color("#E2E8F0"))
	box.add_child(result_details)

	next_button = Button.new()
	next_button.text = "PRÓXIMA FASE →"
	next_button.custom_minimum_size = Vector2(300, 48)
	next_button.pressed.connect(_on_next_stage_pressed)
	Assets.apply_button(next_button)
	box.add_child(next_button)

	retry_button = Button.new()
	retry_button.text = "TENTAR NOVAMENTE"
	retry_button.custom_minimum_size = Vector2(300, 48)
	retry_button.pressed.connect(_on_retry_pressed)
	Assets.apply_button(retry_button)
	box.add_child(retry_button)

	result_back_button = Button.new()
	result_back_button.text = "VOLTAR ÀS FASES"
	result_back_button.custom_minimum_size = Vector2(300, 48)
	result_back_button.pressed.connect(_on_result_back_pressed)
	Assets.apply_button(result_back_button)
	box.add_child(result_back_button)


func _show_campaign_victory():
	stage_finished = true
	busy = true
	Audio.play("vitoria")
	# Lê o recorde ANTES de concluir, porque complete_current_stage já atualiza best_scores.
	var previous_best = GameState.get_best_score(int(stage_data["id"]))
	var stars = GameState.calculate_stars(moves, move_limit)
	var result = GameState.complete_current_stage(score, stars)
	var level_before = int(result["level_before"])
	var level_after = int(result["level_after"])
	var xp_gained = int(result["xp_gained"])

	result_title.text = "FASE CONCLUÍDA!\n%s" % GameState.stars_text(stars)
	for child in result_stars_holder.get_children():
		child.queue_free()
	var star_row = Assets.make_star_row(stars, 3, 56)
	if star_row != null:
		# Com as imagens de estrela, o título fica só com o texto.
		result_title.text = "FASE CONCLUÍDA!"
		result_stars_holder.add_child(star_row)
		result_stars_holder.visible = true
	var details = "Você completou %s com %d pontos." % [stage_data["title"], score]
	details += "\nJogadas restantes: %d" % (move_limit - moves)
	if stars > int(result["previous_stars"]) and int(result["previous_stars"]) > 0:
		details += "  •  mais estrelas que antes!"

	if score > previous_best:
		if previous_best > 0:
			details += "\nNOVO RECORDE! (anterior: %d)" % previous_best
		else:
			details += "\nPrimeiro recorde registrado!"
	else:
		details += "\nRecorde: %d" % previous_best

	if xp_gained > 0:
		details += "\n+%d XP" % xp_gained
	else:
		details += "\nEsta fase já havia sido concluída; o XP principal já foi recebido."

	if level_after > level_before:
		details += "\n\nNÍVEL AUMENTOU!  %d → %d" % [level_before, level_after]

	if int(stage_data["id"]) == GameState.get_stage_count():
		details += "\n\nVocê concluiu todas as fases do MathMatch!"

	result_details.text = details
	retry_button.visible = false
	next_button.visible = int(stage_data["id"]) < GameState.get_stage_count()
	result_back_button.visible = true
	result_overlay.visible = true
	var center = get_viewport_rect().size / 2.0
	Assets.burst(self, center + Vector2(-120, -80), 22)
	Assets.burst(self, center + Vector2(120, -80), 22)
	Assets.burst(self, center + Vector2(0, -140), 26, Color(0.75, 1, 0.8))


func _show_campaign_failure():
	stage_finished = true
	busy = true
	Audio.play("derrota")
	result_stars_holder.visible = false
	result_title.text = "JOGADAS ESGOTADAS"
	result_details.text = "Você resolveu %d de %d desafios.\nTente novamente para concluir a fase." % [solved_challenges, required_challenges]
	next_button.visible = false
	retry_button.visible = true
	result_back_button.visible = true
	result_overlay.visible = true


func _get_dev_completion_score(stage):
	if stage.is_empty():
		return score

	var stage_id = int(stage["id"])
	var stage_difficulty = int(stage["difficulty"])
	var required = int(stage["required"])
	return 500 + (stage_id * 100) + (required * 150 * stage_difficulty)


func _on_dev_skip_stage_pressed():
	if context != "developer" or busy or stage_finished:
		return

	var dev_stage = stage_data
	if dev_stage.is_empty():
		dev_stage = GameState.get_stage_for_mode_difficulty(mode, difficulty)

	if dev_stage.is_empty():
		status_label.text = "DEV: não foi possível identificar a fase correspondente."
		return

	busy = true
	solved_challenges = int(dev_stage["required"])
	var completion_score = _get_dev_completion_score(dev_stage)
	if score < completion_score:
		score = completion_score
	_update_hud()

	var result = GameState.complete_stage(int(dev_stage["id"]), score, true)
	var next_stage_id = int(dev_stage["id"]) + 1

	if next_stage_id <= GameState.get_stage_count():
		GameState.start_developer_stage(next_stage_id)
		get_tree().reload_current_scene()
		return

	stage_finished = true
	result_title.text = "DEV • TODAS AS FASES CONCLUÍDAS"
	var details = "A fase %02d foi marcada como concluída com %d pontos." % [dev_stage["id"], score]
	var xp_gained = int(result["xp_gained"])
	if xp_gained > 0:
		details += "\n+%d XP creditados ao progresso." % xp_gained
	else:
		details += "\nO XP desta fase já havia sido creditado anteriormente."
	details += "\n\nTodas as 18 fases já podem ser verificadas no mapa de progressão."
	result_details.text = details
	next_button.visible = false
	retry_button.visible = false
	result_back_button.text = "VOLTAR AO DEV"
	result_back_button.visible = true
	result_stars_holder.visible = false
	result_overlay.visible = true


func _on_next_stage_pressed():
	if context == "tutorial":
		GameState.start_campaign_stage(GameState.get_continue_stage())
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		return

	var next_stage = int(stage_data["id"]) + 1
	if GameState.start_campaign_stage(next_stage):
		get_tree().reload_current_scene()
	else:
		get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")


func _on_retry_pressed():
	get_tree().reload_current_scene()


func _on_result_back_pressed():
	if context == "tutorial":
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
		return
	if context == "developer":
		get_tree().change_scene_to_file("res://scenes/DeveloperMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")


func _unhandled_input(event):
	# "ui_cancel" já vem mapeado para ESC no Godot.
	if not event.is_action_pressed("ui_cancel"):
		return

	get_viewport().set_input_as_handled()

	if options_panel != null and options_panel.visible:
		options_panel.close()
	elif lesson_open:
		_close_lesson()
	elif result_overlay.visible:
		_on_result_back_pressed()
	elif paused:
		if pause_confirm_box.visible:
			_cancel_pause_confirm()
		else:
			_close_pause()
	elif selected.x != -1 and not busy:
		# Primeiro ESC só cancela a seleção, se houver uma.
		selected = Vector2i(-1, -1)
		status_label.text = "Seleção cancelada."
		_refresh_board()
	else:
		_open_pause()


func _on_menu_pressed():
	if busy and not stage_finished:
		return

	if context == "campaign":
		get_tree().change_scene_to_file("res://scenes/ProgressionMenu.tscn")
	elif context == "developer":
		get_tree().change_scene_to_file("res://scenes/DeveloperMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


# =====================================================================
# DICAS POR ERROS
# =====================================================================

func _reset_hints():
	mistakes = 0
	hint_level = 0
	hint_text = ""
	hint_move = []
	_refresh_instruction()


func _register_mistake():
	if context == "classic" or context == "tutorial" or stage_finished or target_answer < 1:
		return

	mistakes += 1

	var new_level = 0
	if mistakes >= HINT_STEP_MOVE:
		new_level = 3
	elif mistakes >= HINT_STEP_ANSWER:
		new_level = 2
	elif mistakes >= HINT_STEP_STRATEGY:
		new_level = 1

	if new_level == 0:
		return

	var level_changed = new_level != hint_level
	hint_level = new_level
	if level_changed:
		Audio.play("dica")
	hint_text = MathTutor.get_hint(mode, current_challenge_text, target_answer, min(hint_level, 2))

	if hint_level >= 3:
		# O tabuleiro muda a cada jogada, então a troca sugerida é recalculada sempre.
		hint_move = _find_target_move()
		if hint_move.size() == 0:
			_make_board_playable(true)
			hint_move = _find_target_move()
		if hint_move.size() > 0:
			status_label.text = "Troque as duas peças com borda verde!"
		else:
			status_label.text = "Ainda não dá para formar o %d. Faça outra combinação para mexer o tabuleiro." % target_answer
	elif level_changed:
		if hint_level == 1:
			status_label.text = "Precisa de ajuda? Veja a dica embaixo da conta."
		else:
			status_label.text = "Veja a dica: as peças com a resposta ficaram destacadas."

	_refresh_instruction()
	_refresh_board()


func _refresh_instruction():
	if context == "classic" or context == "tutorial":
		return

	if hint_text != "":
		challenge_instruction.text = "DICA: " + hint_text
		challenge_instruction.add_theme_color_override("font_color", HINT_BORDER_COLOR)
		return

	challenge_instruction.add_theme_color_override("font_color", INSTRUCTION_COLOR)
	if context == "campaign":
		challenge_instruction.text = "Combine 3 peças com a resposta • objetivo %d/%d" % [solved_challenges, required_challenges]
	else:
		challenge_instruction.text = "Resolva a conta e faça uma combinação com a resposta."


# Procura uma troca que forme combinação com a peça da resposta.
func _find_target_move():
	for r in range(ROWS):
		for c in range(COLS):
			var a = Vector2i(c, r)
			for d in [Vector2i(1, 0), Vector2i(0, 1)]:
				var b = a + d
				if b.x >= COLS or b.y >= ROWS:
					continue
				if board[a.y][a.x] == board[b.y][b.x]:
					continue

				_swap(a, b)
				var found = _find_matches()
				var works = found.size() > 0 and _matches_target(found)
				_swap(a, b)

				if works:
					return [a, b]

	return []


# =====================================================================
# MINI-AULA PRÁTICA (conteúdo novo + botão AJUDA)
# =====================================================================

func _create_help_button():
	if context == "classic" or context == "tutorial":
		return

	help_button = Button.new()
	help_button.text = "? AJUDA"
	help_button.custom_minimum_size = Vector2(120, 42)
	help_button.pressed.connect(_on_help_pressed)
	Assets.apply_button(help_button)
	header.add_child(help_button)


func _on_help_pressed():
	if busy or stage_finished or lesson_open or paused:
		return
	_open_lesson(false)


func _build_lesson_overlay():
	lesson_overlay = Control.new()
	lesson_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lesson_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	lesson_overlay.visible = false
	add_child(lesson_overlay)

	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lesson_overlay.add_child(shade)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lesson_overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(640, 0)
	panel.add_theme_stylebox_override("panel", _lesson_box(Color("#172033"), Color("#F5C542"), 2))
	Assets.apply_panel(panel, "painel_janela")
	center.add_child(panel)

	var margin = MarginContainer.new()
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 30)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 24)
	panel.add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	margin.add_child(box)

	lesson_title = _lesson_label(26, Color("#F5C542"))
	box.add_child(lesson_title)

	lesson_idea = _lesson_label(17, Color("#F8FAFC"))
	box.add_child(lesson_idea)

	var example_panel = PanelContainer.new()
	example_panel.add_theme_stylebox_override("panel", _lesson_box(Color("#0F172A"), Color("#334155"), 1))
	box.add_child(example_panel)

	var example_margin = MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		example_margin.add_theme_constant_override(side, 14)
	example_panel.add_child(example_margin)

	var example_box = VBoxContainer.new()
	example_box.add_theme_constant_override("separation", 6)
	example_margin.add_child(example_box)

	lesson_example = _lesson_label(20, Color("#FDE047"))
	example_box.add_child(lesson_example)

	lesson_lines = _lesson_label(19, Color("#F8FAFC"))
	example_box.add_child(lesson_lines)

	lesson_tip = _lesson_label(14, Color("#AAB8CC"))
	example_box.add_child(lesson_tip)

	var try_label = _lesson_label(18, Color("#86EFAC"))
	try_label.text = "SUA VEZ!"
	box.add_child(try_label)

	lesson_question = _lesson_label(24, Color("#F8FAFC"))
	box.add_child(lesson_question)

	lesson_options_box = HBoxContainer.new()
	lesson_options_box.alignment = BoxContainer.ALIGNMENT_CENTER
	lesson_options_box.add_theme_constant_override("separation", 14)
	box.add_child(lesson_options_box)

	lesson_feedback = _lesson_label(15, Color("#AAB8CC"))
	box.add_child(lesson_feedback)

	var actions = HBoxContainer.new()
	actions.alignment = BoxContainer.ALIGNMENT_CENTER
	actions.add_theme_constant_override("separation", 14)
	box.add_child(actions)

	var skip_button = Button.new()
	skip_button.text = "PULAR"
	skip_button.custom_minimum_size = Vector2(150, 44)
	skip_button.pressed.connect(_close_lesson)
	Assets.apply_button(skip_button)
	actions.add_child(skip_button)

	lesson_play_button = Button.new()
	lesson_play_button.text = "JOGAR →"
	lesson_play_button.custom_minimum_size = Vector2(220, 48)
	lesson_play_button.pressed.connect(_close_lesson)
	Assets.apply_button(lesson_play_button)
	actions.add_child(lesson_play_button)


func _lesson_label(font_size, color):
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _lesson_box(bg, border, border_width):
	var style = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	return style


func _open_lesson(first_time):
	var lesson = MathTutor.get_lesson(mode)
	if lesson.is_empty():
		return

	if first_time:
		lesson_title.text = "NOVO CONTEÚDO: %s" % lesson["name"]
	else:
		lesson_title.text = "COMO FAZER: %s" % lesson["name"]

	lesson_idea.text = lesson["idea"]
	lesson_example.text = "Exemplo:  " + lesson["example"]
	lesson_lines.text = "\n".join(PackedStringArray(lesson["lines"]))
	lesson_tip.text = lesson["tip"]

	var practice_list = lesson["practice"]
	lesson_practice = practice_list[randi() % practice_list.size()]
	lesson_wrong = 0
	lesson_question.text = lesson_practice["text"]

	for child in lesson_options_box.get_children():
		child.queue_free()

	var options = lesson_practice["options"].duplicate()
	options.shuffle()
	for value in options:
		var option_button = Button.new()
		option_button.text = str(value)
		option_button.custom_minimum_size = Vector2(90, 54)
		option_button.add_theme_font_size_override("font_size", 22)
		option_button.pressed.connect(_on_lesson_option.bind(option_button, int(value)))
		option_button.set_meta("no_click_sound", true)
		Assets.apply_button(option_button)
		lesson_options_box.add_child(option_button)

	lesson_feedback.text = "Toque na resposta certa."
	lesson_feedback.add_theme_color_override("font_color", Color("#AAB8CC"))
	lesson_play_button.disabled = true

	selected = Vector2i(-1, -1)
	_refresh_board()
	lesson_open = true
	lesson_overlay.visible = true


func _on_lesson_option(option_button, value):
	var answer = int(lesson_practice["answer"])

	if value == answer:
		Audio.play("acerto")
		option_button.modulate = Color("#86EFAC")
		for child in lesson_options_box.get_children():
			child.disabled = true
		lesson_feedback.text = "Isso! A resposta é %d.\nNo tabuleiro é igual: resolva a conta e junte 3 peças com a resposta." % answer
		lesson_feedback.add_theme_color_override("font_color", Color("#86EFAC"))
		lesson_play_button.disabled = false
		lesson_play_button.grab_focus()
		return

	lesson_wrong += 1
	Audio.play("troca_invalida")
	option_button.disabled = true
	option_button.modulate = Color("#FCA5A5")

	# 1º erro: estratégia. 2º erro: mostra o passo a passo.
	var level = 1 if lesson_wrong == 1 else 2
	var tip = MathTutor.get_hint(mode, lesson_practice["text"], answer, level, false)
	lesson_feedback.text = ("Quase! " if level == 1 else "Veja como fazer: ") + tip
	lesson_feedback.add_theme_color_override("font_color", Color("#FDE047"))


func _close_lesson():
	if not lesson_open:
		return

	lesson_open = false
	lesson_overlay.visible = false

	if context == "campaign":
		GameState.mark_lesson_seen(mode)

	status_label.text = "Agora no tabuleiro: resolva a conta e combine 3 peças com a resposta."


# =====================================================================
# MENU DE PAUSA
# =====================================================================

func _build_pause_overlay():
	pause_overlay = Control.new()
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_overlay.visible = false
	add_child(pause_overlay)

	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.add_child(shade)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	panel.add_theme_stylebox_override("panel", _lesson_box(Color("#172033"), Color("#F5C542"), 2))
	Assets.apply_panel(panel, "painel_janela")
	center.add_child(panel)

	var margin = MarginContainer.new()
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 34)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 28)
	panel.add_child(margin)

	var holder = VBoxContainer.new()
	margin.add_child(holder)

	# Tela principal da pausa
	pause_main_box = VBoxContainer.new()
	pause_main_box.add_theme_constant_override("separation", 14)
	holder.add_child(pause_main_box)

	var title = _lesson_label(30, Color("#F5C542"))
	title.text = "PAUSA"
	pause_main_box.add_child(title)

	pause_continue_button = _pause_button("CONTINUAR", _close_pause)
	pause_main_box.add_child(pause_continue_button)
	pause_main_box.add_child(_pause_button("REINICIAR FASE", _ask_pause_confirm.bind("restart")))
	pause_main_box.add_child(_pause_button("COMO JOGAR", _on_pause_help))
	pause_main_box.add_child(_pause_button("OPÇÕES", _on_pause_options))
	pause_main_box.add_child(_pause_button(_exit_label(), _ask_pause_confirm.bind("exit")))

	# Confirmação (reiniciar ou sair)
	pause_confirm_box = VBoxContainer.new()
	pause_confirm_box.add_theme_constant_override("separation", 16)
	pause_confirm_box.visible = false
	holder.add_child(pause_confirm_box)

	pause_confirm_label = _lesson_label(18, Color("#F8FAFC"))
	pause_confirm_box.add_child(pause_confirm_label)

	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 14)
	pause_confirm_box.add_child(row)

	var yes = _pause_button("SIM", _confirm_pause_action)
	yes.custom_minimum_size = Vector2(150, 48)
	row.add_child(yes)
	var no = _pause_button("NÃO", _cancel_pause_confirm)
	no.custom_minimum_size = Vector2(150, 48)
	row.add_child(no)

	options_panel = OptionsPanel.new()
	options_panel.closed.connect(_on_options_closed)
	add_child(options_panel)


func _pause_button(text_value, callback):
	var button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(300, 48)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(callback)
	Assets.apply_button(button)
	return button


func _exit_label():
	match context:
		"campaign":
			return "SAIR PARA O MAPA"
		"developer":
			return "SAIR PARA O MENU DEV"
		_:
			return "SAIR PARA O MENU"


func _open_pause():
	if busy or stage_finished or lesson_open or paused:
		return
	paused = true
	selected = Vector2i(-1, -1)
	_refresh_board()
	pause_main_box.visible = true
	pause_confirm_box.visible = false
	pause_overlay.visible = true
	pause_continue_button.grab_focus()


func _close_pause():
	paused = false
	pause_overlay.visible = false


func _ask_pause_confirm(action):
	pause_confirm_action = action
	if action == "restart":
		pause_confirm_label.text = "Reiniciar a fase?\nVocê vai perder os pontos e as jogadas desta partida."
	else:
		pause_confirm_label.text = "Sair da fase?\nO progresso desta partida será perdido."
	pause_main_box.visible = false
	pause_confirm_box.visible = true


func _cancel_pause_confirm():
	pause_confirm_box.visible = false
	pause_main_box.visible = true
	pause_continue_button.grab_focus()


func _confirm_pause_action():
	var action = pause_confirm_action
	_close_pause()
	if action == "restart":
		_new_game()
	else:
		_on_menu_pressed()


func _on_pause_help():
	if context == "classic":
		status_label.text = "Troque peças vizinhas para formar linhas de 3 ou mais iguais."
		_close_pause()
		return
	_close_pause()
	_open_lesson(false)


func _on_pause_options():
	pause_overlay.visible = false
	options_panel.open()


func _on_options_closed():
	if paused:
		pause_overlay.visible = true
		pause_continue_button.grab_focus()


# =====================================================================
# TABULEIRO SEMPRE JOGÁVEL
# =====================================================================

# Garante que o tabuleiro não tenha combinações prontas, tenha pelo menos
# uma jogada possível e, se require_target, uma jogada que forme a resposta.
# Retorna true se precisou reorganizar peças.
func _make_board_playable(require_target):
	var target_value = target_answer - 1
	var needs_target = require_target and context != "classic" and target_answer >= 1

	_clear_board_matches([])
	if needs_target:
		_ensure_target_presence(5)

	if _board_is_playable(needs_target):
		return false

	# Cria uma jogada garantida mexendo só em 4 casas do tabuleiro.
	var value = target_value if needs_target else randi() % current_tile_types
	for attempt in range(30):
		if _force_move(value) and _board_is_playable(needs_target):
			return true

	return true


func _board_is_playable(needs_target):
	if _find_matches().size() > 0:
		return false
	if not _has_possible_move():
		return false
	if needs_target and _find_target_move().size() == 0:
		return false
	return true


# Monta o padrão  V V W  /  . . V  : trocar W com o V de baixo forma V V V.
func _force_move(value):
	var horizontal = randi() % 2 == 0
	var protected = []
	var swap_cell

	if horizontal:
		var r = randi() % (ROWS - 1)
		var c = randi() % (COLS - 2)
		protected = [Vector2i(c, r), Vector2i(c + 1, r), Vector2i(c + 2, r), Vector2i(c + 2, r + 1)]
		swap_cell = Vector2i(c + 2, r)
	else:
		var r = randi() % (ROWS - 2)
		var c = randi() % (COLS - 1)
		protected = [Vector2i(c, r), Vector2i(c, r + 1), Vector2i(c, r + 2), Vector2i(c + 1, r + 2)]
		swap_cell = Vector2i(c, r + 2)

	for i in range(protected.size()):
		var pos = protected[i]
		board[pos.y][pos.x] = value
	board[swap_cell.y][swap_cell.x] = _different_value(value)

	return _clear_board_matches(protected)


func _different_value(value):
	var other = randi() % current_tile_types
	while other == value and current_tile_types > 1:
		other = randi() % current_tile_types
	return other


# Troca peças que formam combinação pronta, sem mexer nas casas protegidas.
func _clear_board_matches(protected):
	for round in range(60):
		var matches = _find_matches()
		if matches.size() == 0:
			return true

		var changed = false
		for pos in matches:
			if protected.has(pos):
				continue
			var original = board[pos.y][pos.x]
			for attempt in range(current_tile_types * 2):
				var candidate = randi() % current_tile_types
				if candidate == original:
					continue
				board[pos.y][pos.x] = candidate
				if not _would_create_match_at(pos.y, pos.x, candidate):
					changed = true
					break
				board[pos.y][pos.x] = original
			if changed:
				break

		if not changed:
			return false

	return _find_matches().size() == 0


# =====================================================================
# TUTORIAL – FASE 0
# =====================================================================
# Cinco passos guiados. Em cada passo só as peças com borda verde podem ser
# tocadas, e o jogo explica o que aconteceu depois de cada troca.

func _tutorial_start():
	tut_step = 0
	tut_expected = []
	tut_waiting = false
	target_answer = -1
	current_challenge_text = ""
	_generate_board()
	_refresh_board()
	_tutorial_next_step()


func _tutorial_next_step():
	tut_step += 1
	tut_waiting = false
	selected = Vector2i(-1, -1)

	match tut_step:
		1:
			_tutorial_set_text("Trocar peças", "Toque em uma das peças com borda verde e depois na outra. Elas trocam de lugar e formam 3 iguais em linha.")
			target_answer = -1
			tut_expected = _tutorial_place_pattern(1, 3, 2)
			status_label.text = "Toque em uma das peças com borda verde."
		2:
			_tutorial_set_text("Troca que não vale", "Agora troque estas duas peças. Elas não formam 3 iguais. Veja o que acontece.")
			target_answer = -1
			tut_expected = _tutorial_find_invalid_pair()
			status_label.text = "Toque nas duas peças com borda verde."
		3:
			target_answer = 3
			current_challenge_text = "2 + 1 = ?"
			_tutorial_set_text("2 + 1 = ?", "Agora tem uma conta! Resolva e combine 3 peças com o número da resposta.")
			tut_expected = _tutorial_place_pattern(target_answer - 1, 4, 3)
			status_label.text = "Quanto é 2 + 1? Combine as peças destacadas."
		4:
			target_answer = 4
			current_challenge_text = "2 + 2 = ?"
			_tutorial_set_text("2 + 2 = ?", "E se combinar o número errado? Combine as peças destacadas e veja.")
			tut_expected = _tutorial_place_pattern(0, 2, 4)
			status_label.text = "Combine as peças com borda verde."
		5:
			_tutorial_set_text("2 + 2 = ?", "Agora combine as peças com a resposta certa da conta.")
			tut_expected = _tutorial_place_pattern(target_answer - 1, 5, 1)
			status_label.text = "Qual é a resposta de 2 + 2? Combine as peças destacadas."
		_:
			_tutorial_finish()
			return

	hint_move = tut_expected.duplicate()
	_refresh_board()
	_update_hud()


func _tutorial_set_text(title, text):
	challenge_label.text = title
	challenge_instruction.text = text
	challenge_instruction.add_theme_color_override("font_color", Color("#F8FAFC"))


func _tutorial_after_move(solved, invalid):
	hint_move = []
	tut_expected = []
	var message = ""
	var ok = true

	match tut_step:
		1:
			message = "Isso! 3 peças iguais em linha somem, as de cima caem e novas peças aparecem."
			ok = not invalid
		2:
			message = "A troca voltou ao lugar e não gastou jogada. Só vale trocar se formar 3 ou mais iguais."
			ok = invalid
		3:
			message = "Resposta correta! 2 + 1 = 3. Acertar a conta dá pontos extras e cumpre o objetivo."
			ok = solved
		4:
			message = "Você combinou 1, mas 2 + 2 = 4. Vale pontos, mas não resolve a conta. Se errar várias vezes, o jogo dá dicas."
			ok = not invalid and not solved
		5:
			message = "Isso! 2 + 2 = 4. Agora você já sabe jogar."
			ok = solved

	if not ok:
		# Algo inesperado (ex.: a queda formou outra combinação): repete o passo.
		tut_step -= 1
		message = "Vamos tentar de novo."

	status_label.text = message
	challenge_instruction.text = message
	challenge_instruction.add_theme_color_override("font_color", Color("#86EFAC") if ok else HINT_BORDER_COLOR)
	_refresh_board()

	tut_waiting = true
	busy = true
	await get_tree().create_timer(3.2 if tut_step == 4 else 2.4).timeout
	if not is_inside_tree() or context != "tutorial":
		return
	busy = false
	_tutorial_next_step()


# Monta a jogada V V W / . . V perto da linha r e devolve as duas peças da troca.
func _tutorial_place_pattern(value, r, c):
	for attempt in range(40):
		var other = _different_value(value)
		if other == target_answer - 1:
			continue
		var protected = [Vector2i(c, r), Vector2i(c + 1, r), Vector2i(c + 2, r), Vector2i(c + 2, r + 1)]
		board[r][c] = value
		board[r][c + 1] = value
		board[r][c + 2] = other
		board[r + 1][c + 2] = value
		if not _clear_board_matches(protected):
			continue

		# Nos passos com conta, só as peças do padrão podem ter a resposta.
		if target_answer >= 1:
			for rr in range(ROWS):
				for cc in range(COLS):
					if board[rr][cc] == target_answer - 1 and not protected.has(Vector2i(cc, rr)):
						board[rr][cc] = _safe_value_at(rr, cc)

		# A troca precisa formar só o trio esperado, sem tocar na resposta por engano.
		var a = Vector2i(c + 2, r)
		var b = Vector2i(c + 2, r + 1)
		_swap(a, b)
		var found = _find_matches()
		var forms_trio = found.has(Vector2i(c, r)) and found.has(Vector2i(c + 1, r)) and found.has(a)
		var only_trio = true
		for pos in found:
			if board[pos.y][pos.x] != value:
				only_trio = false
		_swap(a, b)
		if forms_trio and only_trio:
			return [a, b]
	return [Vector2i(c + 2, r), Vector2i(c + 2, r + 1)]


func _tutorial_find_invalid_pair():
	var spots = [Vector2i(3, 3), Vector2i(4, 4), Vector2i(2, 5), Vector2i(5, 2), Vector2i(3, 6), Vector2i(1, 2)]
	for a in spots:
		for d in [Vector2i(1, 0), Vector2i(0, 1)]:
			var b = a + d
			if b.x >= COLS or b.y >= ROWS:
				continue
			if board[a.y][a.x] == board[b.y][b.x]:
				continue
			_swap(a, b)
			var forms = _find_matches().size() > 0
			_swap(a, b)
			if not forms:
				return [a, b]
	return [Vector2i(0, 0), Vector2i(1, 0)]


func _tutorial_finish():
	tut_waiting = true
	busy = true
	stage_finished = true
	hint_move = []
	_refresh_board()
	GameState.complete_tutorial()
	Audio.play("vitoria")

	result_title.text = "TUTORIAL CONCLUÍDO!"
	result_details.text = "Em cada fase:\n• Resolva a conta e combine 3 peças com a resposta.\n• Complete os desafios antes de acabar as jogadas.\n• Quanto mais jogadas sobrarem, mais estrelas você ganha.\n• Errou algumas vezes? O jogo dá dicas para ajudar."
	result_stars_holder.visible = false
	next_button.text = "COMEÇAR A JORNADA →"
	next_button.visible = true
	retry_button.visible = false
	result_back_button.text = "VOLTAR AO MENU"
	result_back_button.visible = true
	result_overlay.visible = true

	var center = get_viewport_rect().size / 2.0
	Assets.burst(self, center + Vector2(-120, -100), 22)
	Assets.burst(self, center + Vector2(120, -100), 22)
