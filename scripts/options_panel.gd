extends Control

# Janela de opções: som, tela e acessibilidade (tamanho do texto e alto
# contraste). Usada pelo menu principal e pelo menu de pausa.

signal closed

const UiStyle = preload("res://scripts/ui_style.gd")

var music_slider
var music_value
var sfx_slider
var sfx_value
var fullscreen_check
var contrast_check
var size_buttons = []
var back_button


func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()
	visible = false


func open():
	music_slider.set_value_no_signal(Audio.music_volume)
	sfx_slider.set_value_no_signal(Audio.sfx_volume)
	fullscreen_check.set_pressed_no_signal(Audio.is_fullscreen())
	contrast_check.set_pressed_no_signal(Audio.high_contrast)
	_update_labels()
	_update_size_buttons()
	visible = true
	back_button.grab_focus()


func close():
	if not visible:
		return
	visible = false
	closed.emit()


func _build():
	var shade = ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.06, 0.85)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 0)
	panel.add_theme_stylebox_override("panel", UiStyle.paper(30))
	center.add_child(panel)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	box.add_child(UiStyle.label("OPÇÕES", 30, UiStyle.INK))

	box.add_child(_section("SOM"))
	var music_row = _slider_row("Música")
	box.add_child(music_row["row"])
	music_slider = music_row["slider"]
	music_value = music_row["value"]
	music_slider.value_changed.connect(_on_music_changed)

	var sfx_row = _slider_row("Efeitos sonoros")
	box.add_child(sfx_row["row"])
	sfx_slider = sfx_row["slider"]
	sfx_value = sfx_row["value"]
	sfx_slider.value_changed.connect(_on_sfx_changed)
	sfx_slider.drag_ended.connect(_on_sfx_drag_ended)
	Assets.apply_slider(music_slider)
	Assets.apply_slider(sfx_slider)

	box.add_child(_section("TELA"))
	fullscreen_check = _check("Tela cheia")
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	box.add_child(fullscreen_check)

	box.add_child(_section("ACESSIBILIDADE"))
	box.add_child(UiStyle.label("Tamanho do texto", 18, UiStyle.INK, false))
	var sizes = HBoxContainer.new()
	sizes.add_theme_constant_override("separation", 8)
	box.add_child(sizes)
	for i in range(Audio.TEXT_SIZES.size()):
		var size_button = UiStyle.make_button(Audio.TEXT_SIZES[i], "secondary", Vector2(0, 44), 16)
		size_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		size_button.pressed.connect(_on_text_size.bind(i))
		sizes.add_child(size_button)
		size_buttons.append(size_button)

	contrast_check = _check("Alto contraste")
	contrast_check.toggled.connect(_on_contrast_toggled)
	box.add_child(contrast_check)
	box.add_child(UiStyle.label("Deixa o claro mais claro e o escuro mais escuro, para ler melhor.", 14, UiStyle.INK_SOFT, false))

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(1, 6)
	box.add_child(spacer)

	back_button = UiStyle.make_button("VOLTAR", "primary", Vector2(220, 48), 18)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.pressed.connect(close)
	box.add_child(back_button)


func _section(text_value):
	return UiStyle.label(text_value, 14, UiStyle.INK_SOFT, false)


func _check(text_value):
	var check = CheckButton.new()
	check.text = text_value
	check.add_theme_font_size_override("font_size", 18)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_hover_pressed_color"]:
		check.add_theme_color_override(state, UiStyle.INK)
	Assets.apply_check(check)
	return check


func _slider_row(text_value):
	var row = VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	var top = HBoxContainer.new()
	row.add_child(top)

	var label = UiStyle.label(text_value, 18, UiStyle.INK, false)
	label.autowrap_mode = TextServer.AUTOWRAP_OFF
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(label)

	var value = UiStyle.label("", 16, UiStyle.INK_SOFT, false)
	value.autowrap_mode = TextServer.AUTOWRAP_OFF
	top.add_child(value)

	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.custom_minimum_size = Vector2(440, 24)
	row.add_child(slider)

	return {"row": row, "slider": slider, "value": value}


func _update_labels():
	music_value.text = _volume_text(music_slider.value)
	sfx_value.text = _volume_text(sfx_slider.value)


func _update_size_buttons():
	for i in range(size_buttons.size()):
		UiStyle.button(size_buttons[i], "primary" if i == Audio.text_size else "secondary", 16)
	# A escala do texto vale também para estes botões.
	Audio._scale_tree(self)


func _volume_text(value):
	if int(value) <= 0:
		return "Mudo"
	return "%d%%" % int(value)


func _on_music_changed(value):
	Audio.set_music_volume(value)
	_update_labels()


func _on_sfx_changed(value):
	Audio.set_sfx_volume(value)
	_update_labels()


func _on_sfx_drag_ended(_changed):
	Audio.play("combinar")


func _on_fullscreen_toggled(enabled):
	Audio.set_fullscreen(enabled)


func _on_text_size(index):
	Audio.set_text_size(index)
	_update_size_buttons()


func _on_contrast_toggled(enabled):
	Audio.set_high_contrast(enabled)


func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
