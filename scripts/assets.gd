extends Node

# Carregador de assets do MathMatch (autoload "Assets").
#
# Procura os arquivos dentro de res://assets/. Se um arquivo existir, ele é
# usado; se não existir, o jogo continua com o visual desenhado por código.
# Assim é possível colocar os assets aos poucos, sem quebrar nada.
#
# A lista completa de nomes está em assets/LEIA-ME.md.

const ROOT = "res://assets/"
const IMAGE_EXTENSIONS = ["png", "webp", "jpg", "jpeg", "svg"]
const SOUND_EXTENSIONS = ["ogg", "wav", "mp3"]
const FONT_EXTENSIONS = ["ttf", "otf", "woff2", "woff"]

# Margem do 9-slice (em pixels da imagem) para botões e painéis.
const BUTTON_SLICE = 12
const PANEL_SLICE = 16

var _cache = {}
var _font = null


func _ready():
	var base_font = _load_first("fontes/fonte", FONT_EXTENSIONS)
	if base_font == null:
		return

	# Símbolos que a fonte não tiver (★ ☆ ✓ ...) usam a fonte padrão do Godot.
	base_font.fallbacks = [ThemeDB.fallback_font]

	# Algarismos alinhados (lnum): números do mesmo tamanho, melhores nas peças.
	var variation = FontVariation.new()
	variation.base_font = base_font
	var ts = TextServerManager.get_primary_interface()
	variation.opentype_features = {ts.name_to_tag("lnum"): 1}
	variation.fallbacks = [ThemeDB.fallback_font]
	_font = variation

	var theme = Theme.new()
	theme.default_font = _font
	get_tree().root.theme = theme


# ---------------------------------------------------------------------
# Busca de arquivos
# ---------------------------------------------------------------------

func _find(path_without_ext, extensions):
	for ext in extensions:
		var path = ROOT + path_without_ext + "." + ext
		if ResourceLoader.exists(path):
			return path
	return ""


func _load_first(path_without_ext, extensions):
	var key = path_without_ext
	if _cache.has(key):
		return _cache[key]

	var path = _find(path_without_ext, extensions)
	var resource = null
	if path != "":
		resource = load(path)

	_cache[key] = resource
	return resource


func texture(name):
	return _load_first("imagens/" + name, IMAGE_EXTENSIONS)


func has_texture(name):
	return texture(name) != null


func sound(name):
	return _load_first("audio/" + name, SOUND_EXTENSIONS)


func has_font():
	return _font != null


func font():
	return _font


# ---------------------------------------------------------------------
# Estilos
# ---------------------------------------------------------------------

func texture_style(tex, slice = 0, modulate = Color.WHITE):
	var style = StyleBoxTexture.new()
	style.texture = tex
	style.texture_margin_left = slice
	style.texture_margin_right = slice
	style.texture_margin_top = slice
	style.texture_margin_bottom = slice
	style.modulate_color = modulate
	return style


# Troca o estilo de um botão pelas imagens botao_*.png, se existirem.
func apply_button(button):
	var normal = texture("interface/botao_normal")
	if normal == null:
		return false

	var hover = texture("interface/botao_hover")
	var pressed = texture("interface/botao_pressionado")
	var disabled = texture("interface/botao_desativado")

	var normal_style = _button_texture_style(normal, Color.WHITE)
	var hover_style = _button_texture_style(hover, Color.WHITE) if hover != null else _button_texture_style(normal, Color(1.08, 1.08, 1.08))
	var pressed_style = _button_texture_style(pressed, Color.WHITE) if pressed != null else _button_texture_style(normal, Color(0.85, 0.85, 0.85))
	var disabled_style = _button_texture_style(disabled, Color.WHITE) if disabled != null else _button_texture_style(normal, Color(1, 1, 1, 0.45))

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("disabled", disabled_style)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return true


func _button_texture_style(tex, modulate):
	var style = texture_style(tex, BUTTON_SLICE, modulate)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


# Troca o fundo de um painel pela imagem indicada (ou por painel.png).
func apply_panel(panel, name = "painel", allow_generic = true):
	var tex = texture("interface/" + name)
	if tex == null and name != "painel" and allow_generic:
		tex = texture("interface/painel")
	if tex == null:
		return false

	var style = texture_style(tex, PANEL_SLICE)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", style)
	return true


# Cria o fundo de uma tela: imagem se existir, senão cor sólida.
func make_background(parent, name, fallback_color):
	var tex = texture("fundos/" + name)
	var node
	if tex != null:
		node = TextureRect.new()
		node.texture = tex
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	else:
		node = ColorRect.new()
		node.color = fallback_color

	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node


# Logo do menu: imagem se existir, senão o texto atual.
func make_logo(label_text, font_size, color, max_size = Vector2(380, 150)):
	var tex = texture("interface/logo")
	if tex != null:
		var rect = TextureRect.new()
		rect.texture = tex
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size = max_size
		return rect

	var label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


# Barra de volume com as imagens slider_*.png, se existirem.
func apply_slider(slider):
	var back = texture("interface/slider_fundo")
	var fill = texture("interface/slider_barra")
	var grab = texture("interface/slider_botao")
	if back != null:
		var style = texture_style(back, 6)
		style.content_margin_top = 6
		style.content_margin_bottom = 6
		slider.add_theme_stylebox_override("slider", style)
	if fill != null:
		var fill_style = texture_style(fill, 6)
		slider.add_theme_stylebox_override("grabber_area", fill_style)
		slider.add_theme_stylebox_override("grabber_area_highlight", fill_style)
	if grab != null:
		slider.add_theme_icon_override("grabber", grab)
		slider.add_theme_icon_override("grabber_highlight", grab)


# Botão liga/desliga com as imagens check_*.png, se existirem.
func apply_check(check):
	var on = texture("interface/check_ligado")
	var off = texture("interface/check_desligado")
	if on == null or off == null:
		return
	for name in ["checked", "checked_disabled", "checked_mirrored"]:
		check.add_theme_icon_override(name, on)
	for name in ["unchecked", "unchecked_disabled", "unchecked_mirrored"]:
		check.add_theme_icon_override(name, off)


# Linha de estrelas (imagens estrela_*.png). Retorna null se não existirem.
func make_star_row(filled, total = 3, size = 44):
	var full = texture("interface/estrela_cheia")
	var empty = texture("interface/estrela_vazia")
	if full == null or empty == null:
		return null

	var row = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 8)
	for i in range(total):
		var star = TextureRect.new()
		star.texture = full if i < filled else empty
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		star.custom_minimum_size = Vector2(size, size)
		row.add_child(star)
	return row


# Explosão de brilhos (Particle Pack) numa posição da tela.
func burst(parent, global_pos, amount = 14, color = Color(1, 0.95, 0.6)):
	var tex = texture("efeitos/brilho")
	if tex == null:
		return

	var particles = CPUParticles2D.new()
	particles.texture = tex
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = amount
	particles.lifetime = 0.7
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 260)
	particles.initial_velocity_min = 140.0
	particles.initial_velocity_max = 260.0
	particles.scale_amount_min = 0.25
	particles.scale_amount_max = 0.55
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	particles.color = color
	var fade = Gradient.new()
	fade.set_color(0, Color(1, 1, 1, 1))
	fade.set_color(1, Color(1, 1, 1, 0))
	particles.color_ramp = fade
	particles.z_index = 50
	parent.add_child(particles)
	particles.global_position = global_pos
	particles.emitting = true
	particles.finished.connect(particles.queue_free)
