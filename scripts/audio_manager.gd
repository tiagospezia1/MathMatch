extends Node

# Música, efeitos sonoros e opções do MathMatch (autoload "Audio").
#
# Os sons ficam em res://assets/audio/. Se um som não existir, nada toca e o
# jogo continua normalmente. Os nomes esperados estão em assets/LEIA-ME.md.

const SETTINGS_PATH = "user://mathmatch_settings.cfg"
const SFX_PLAYERS = 8

var music_volume = 70
var sfx_volume = 80
var fullscreen = false

var _music_player
var _current_music = ""
var _sfx_players = []
var _next_player = 0


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_bus("Music")
	_create_bus("SFX")

	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)

	for i in range(SFX_PLAYERS):
		var player = AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)

	load_settings()
	_apply_volumes()
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

	# Som de clique em todos os botões, menos os que pedirem para não tocar.
	get_tree().node_added.connect(_on_node_added)


func _create_bus(bus_name):
	if AudioServer.get_bus_index(bus_name) != -1:
		return
	AudioServer.add_bus()
	var index = AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, "Master")


# ---------------------------------------------------------------------
# Música
# ---------------------------------------------------------------------

# name: "menu" ou "partida" -> procura assets/audio/musica_menu.ogg etc.
func play_music(name):
	if name == _current_music and _music_player.playing:
		return

	var stream = Assets.sound("musica_" + name)
	_current_music = name

	if stream == null:
		_music_player.stop()
		return

	if "loop" in stream:
		stream.loop = true
	_music_player.stream = stream
	_music_player.play()


func stop_music():
	_current_music = ""
	_music_player.stop()


func _on_music_finished():
	# Garante a repetição mesmo em arquivos importados sem loop.
	if _current_music != "" and _music_player.stream != null:
		_music_player.play()


# ---------------------------------------------------------------------
# Efeitos
# ---------------------------------------------------------------------

func play(name, pitch = 1.0):
	var stream = Assets.sound(name)
	if stream == null:
		return

	var player = _sfx_players[_next_player]
	_next_player = (_next_player + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = pitch
	player.play()


func _on_node_added(node):
	if node is BaseButton and not node.has_meta("no_click_sound"):
		node.pressed.connect(_on_button_pressed)


func _on_button_pressed():
	play("clique")


# ---------------------------------------------------------------------
# Opções
# ---------------------------------------------------------------------

func set_music_volume(value):
	music_volume = clamp(int(value), 0, 100)
	_apply_volumes()
	save_settings()


func set_sfx_volume(value):
	sfx_volume = clamp(int(value), 0, 100)
	_apply_volumes()
	save_settings()


func set_fullscreen(enabled):
	fullscreen = bool(enabled)
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	save_settings()


func is_fullscreen():
	var current = DisplayServer.window_get_mode()
	return current == DisplayServer.WINDOW_MODE_FULLSCREEN or current == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


func _apply_volumes():
	_set_bus_volume("Music", music_volume)
	_set_bus_volume("SFX", sfx_volume)


func _set_bus_volume(bus_name, value):
	var index = AudioServer.get_bus_index(bus_name)
	if index == -1:
		return
	AudioServer.set_bus_mute(index, value <= 0)
	if value > 0:
		AudioServer.set_bus_volume_db(index, linear_to_db(value / 100.0))


func save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)


func load_settings():
	var config = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	music_volume = clamp(int(config.get_value("audio", "music_volume", music_volume)), 0, 100)
	sfx_volume = clamp(int(config.get_value("audio", "sfx_volume", sfx_volume)), 0, 100)
	fullscreen = bool(config.get_value("video", "fullscreen", fullscreen))
