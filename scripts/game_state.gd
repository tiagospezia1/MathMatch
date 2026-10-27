extends Node

const SAVE_PATH = "user://mathmatch_progress.json"

const STAGES = [
	{"id": 1, "title": "Primeiras Somas", "operation": "addition", "difficulty": 1, "required": 3, "moves": 24, "tile_types": 6, "xp": 120},
	{"id": 2, "title": "Soma em Ritmo", "operation": "addition", "difficulty": 2, "required": 4, "moves": 24, "tile_types": 8, "xp": 140},
	{"id": 3, "title": "Soma Desafiadora", "operation": "addition", "difficulty": 3, "required": 5, "moves": 23, "tile_types": 10, "xp": 170},
	{"id": 4, "title": "Começando a Subtrair", "operation": "subtraction", "difficulty": 1, "required": 4, "moves": 24, "tile_types": 6, "xp": 190},
	{"id": 5, "title": "Diferenças Maiores", "operation": "subtraction", "difficulty": 2, "required": 5, "moves": 23, "tile_types": 8, "xp": 220},
	{"id": 6, "title": "Subtração Avançada", "operation": "subtraction", "difficulty": 3, "required": 6, "moves": 22, "tile_types": 10, "xp": 250},
	{"id": 7, "title": "Tabuada Inicial", "operation": "multiplication", "difficulty": 1, "required": 4, "moves": 22, "tile_types": 6, "xp": 270},
	{"id": 8, "title": "Multiplicando Mais", "operation": "multiplication", "difficulty": 2, "required": 5, "moves": 21, "tile_types": 9, "xp": 300},
	{"id": 9, "title": "Desafio da Tabuada", "operation": "multiplication", "difficulty": 3, "required": 6, "moves": 20, "tile_types": 12, "xp": 330},
	{"id": 10, "title": "Divisão Exata", "operation": "division", "difficulty": 1, "required": 4, "moves": 21, "tile_types": 6, "xp": 350},
	{"id": 11, "title": "Quocientes", "operation": "division", "difficulty": 2, "required": 5, "moves": 20, "tile_types": 9, "xp": 380},
	{"id": 12, "title": "Divisão Avançada", "operation": "division", "difficulty": 3, "required": 6, "moves": 19, "tile_types": 12, "xp": 410},
	{"id": 13, "title": "Metades e Terços", "operation": "fraction", "difficulty": 1, "required": 4, "moves": 20, "tile_types": 6, "xp": 430},
	{"id": 14, "title": "Partes do Todo", "operation": "fraction", "difficulty": 2, "required": 5, "moves": 19, "tile_types": 9, "xp": 460},
	{"id": 15, "title": "Frações Avançadas", "operation": "fraction", "difficulty": 3, "required": 6, "moves": 18, "tile_types": 12, "xp": 500},
	{"id": 16, "title": "Porcentagens Básicas", "operation": "percentage", "difficulty": 1, "required": 4, "moves": 19, "tile_types": 6, "xp": 520},
	{"id": 17, "title": "Calculando Percentuais", "operation": "percentage", "difficulty": 2, "required": 5, "moves": 18, "tile_types": 9, "xp": 560},
	{"id": 18, "title": "Mestre das Porcentagens", "operation": "percentage", "difficulty": 3, "required": 6, "moves": 17, "tile_types": 12, "xp": 650}
]

var game_context = "classic"
var game_mode = "classic"
var current_stage = 1
var dev_difficulty = 1

var total_xp = 0
var unlocked_stage = 1
var completed_stages = []
var best_scores = {}
var best_stars = {}
var seen_lessons = {}
var tutorial_done = false


func _ready():
	load_progress()


func start_tutorial():
	game_context = "tutorial"
	game_mode = "addition"


func complete_tutorial():
	if tutorial_done:
		return
	tutorial_done = true
	save_progress()


func start_classic():
	game_context = "classic"
	game_mode = "classic"


func start_developer(mode, difficulty = 1):
	game_context = "developer"
	game_mode = mode
	dev_difficulty = clamp(int(difficulty), 1, 3)

	var mapped_stage = get_stage_for_mode_difficulty(game_mode, dev_difficulty)
	if not mapped_stage.is_empty():
		current_stage = int(mapped_stage["id"])


func start_developer_stage(stage_id):
	var stage = get_stage(stage_id)
	if stage.is_empty():
		return false

	game_context = "developer"
	current_stage = int(stage["id"])
	game_mode = stage["operation"]
	dev_difficulty = int(stage["difficulty"])
	return true


func start_campaign_stage(stage_id):
	var stage = get_stage(stage_id)
	if stage.is_empty():
		return false
	if int(stage_id) > unlocked_stage:
		return false

	game_context = "campaign"
	current_stage = int(stage_id)
	game_mode = stage["operation"]
	return true


func get_stage(stage_id):
	for stage in STAGES:
		if int(stage["id"]) == int(stage_id):
			return stage
	return {}


func get_current_stage():
	return get_stage(current_stage)


func get_stage_for_mode_difficulty(mode, difficulty):
	for stage in STAGES:
		if stage["operation"] == mode and int(stage["difficulty"]) == int(difficulty):
			return stage
	return {}


func get_stage_count():
	return STAGES.size()


func get_mode_title(mode_override = ""):
	var selected_mode = game_mode
	if mode_override != "":
		selected_mode = mode_override

	match selected_mode:
		"addition":
			return "ADIÇÃO"
		"subtraction":
			return "SUBTRAÇÃO"
		"multiplication":
			return "MULTIPLICAÇÃO"
		"division":
			return "DIVISÃO"
		"fraction":
			return "FRAÇÃO"
		"percentage":
			return "PORCENTAGEM"
		_:
			return "CLÁSSICO"


func get_difficulty_title(difficulty):
	match int(difficulty):
		1:
			return "FÁCIL"
		2:
			return "MÉDIO"
		3:
			return "DIFÍCIL"
		_:
			return "NORMAL"


func is_stage_completed(stage_id):
	return completed_stages.has(int(stage_id))


func _empty_completion_result():
	return {
		"xp_gained": 0,
		"level_before": get_player_level(),
		"level_after": get_player_level(),
		"first_completion": false,
		"previous_stars": 0
	}


func complete_current_stage(score, stars = 0):
	if game_context != "campaign":
		return _empty_completion_result()

	return complete_stage(current_stage, score, false, stars)


func complete_stage(stage_id, score, force_unlock = false, stars = 0):
	var result = _empty_completion_result()
	var stage = get_stage(stage_id)
	if stage.is_empty():
		return result

	var resolved_stage_id = int(stage["id"])
	var score_key = str(resolved_stage_id)
	var previous_best = int(best_scores.get(score_key, 0))
	if int(score) > previous_best:
		best_scores[score_key] = int(score)

	var previous_stars = int(best_stars.get(score_key, 0))
	result["previous_stars"] = previous_stars
	if int(stars) > previous_stars:
		best_stars[score_key] = clamp(int(stars), 0, 3)

	if not is_stage_completed(resolved_stage_id):
		result["first_completion"] = true
		completed_stages.append(resolved_stage_id)
		var reward = int(stage["xp"])
		total_xp += reward
		result["xp_gained"] = reward

	if force_unlock:
		if resolved_stage_id < get_stage_count():
			unlocked_stage = max(unlocked_stage, resolved_stage_id + 1)
		else:
			unlocked_stage = get_stage_count()
	elif resolved_stage_id == unlocked_stage and unlocked_stage < get_stage_count():
		unlocked_stage += 1

	result["level_after"] = get_player_level()
	save_progress()
	return result


func get_player_level():
	var level = 1
	var remaining = total_xp

	while remaining >= level * 250:
		remaining -= level * 250
		level += 1

	return level


func get_level_progress():
	var level = 1
	var remaining = total_xp

	while remaining >= level * 250:
		remaining -= level * 250
		level += 1

	return {
		"level": level,
		"current_xp": remaining,
		"needed_xp": level * 250
	}


func get_best_score(stage_id):
	return int(best_scores.get(str(stage_id), 0))


func has_seen_lesson(operation):
	return bool(seen_lessons.get(str(operation), false))


func mark_lesson_seen(operation):
	if has_seen_lesson(operation):
		return
	seen_lessons[str(operation)] = true
	save_progress()


func get_best_stars(stage_id):
	return int(best_stars.get(str(stage_id), 0))


# Estrelas por jogadas restantes:
# 3 = sobrou 40% ou mais das jogadas • 2 = sobrou 20% ou mais • 1 = concluiu.
func calculate_stars(moves_used, move_limit):
	if int(move_limit) <= 0:
		return 1
	var remaining_ratio = float(int(move_limit) - int(moves_used)) / float(move_limit)
	if remaining_ratio >= 0.4:
		return 3
	if remaining_ratio >= 0.2:
		return 2
	return 1


func stars_text(stars):
	var n = clamp(int(stars), 0, 3)
	return "★".repeat(n) + "☆".repeat(3 - n)


func get_continue_stage():
	return clamp(unlocked_stage, 1, get_stage_count())


func save_progress():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return

	var data = {
		"total_xp": total_xp,
		"unlocked_stage": unlocked_stage,
		"completed_stages": completed_stages,
		"best_scores": best_scores,
		"best_stars": best_stars,
		"seen_lessons": seen_lessons,
		"tutorial_done": tutorial_done
	}
	file.store_string(JSON.stringify(data))
	file.close()


func load_progress():
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var text = file.get_as_text()
	file.close()
	var data = JSON.parse_string(text)

	if typeof(data) != TYPE_DICTIONARY:
		return

	total_xp = int(data.get("total_xp", 0))
	unlocked_stage = clamp(int(data.get("unlocked_stage", 1)), 1, get_stage_count())

	completed_stages.clear()
	var loaded_completed = data.get("completed_stages", [])
	if typeof(loaded_completed) == TYPE_ARRAY:
		for stage_id in loaded_completed:
			completed_stages.append(int(stage_id))

	var loaded_scores = data.get("best_scores", {})
	if typeof(loaded_scores) == TYPE_DICTIONARY:
		best_scores = loaded_scores
	else:
		best_scores = {}

	# Saves antigos não têm esta chave; nesse caso começa vazio.
	# Quem já jogou alguma fase antes do tutorial existir não precisa ser obrigado a fazê-lo.
	tutorial_done = bool(data.get("tutorial_done", false)) or completed_stages.size() > 0

	var loaded_lessons = data.get("seen_lessons", {})
	if typeof(loaded_lessons) == TYPE_DICTIONARY:
		seen_lessons = loaded_lessons
	else:
		seen_lessons = {}

	var loaded_stars = data.get("best_stars", {})
	if typeof(loaded_stars) == TYPE_DICTIONARY:
		best_stars = loaded_stars
	else:
		best_stars = {}


func reset_progress():
	total_xp = 0
	unlocked_stage = 1
	completed_stages.clear()
	best_scores.clear()
	best_stars.clear()
	seen_lessons.clear()
	tutorial_done = false
	save_progress()
