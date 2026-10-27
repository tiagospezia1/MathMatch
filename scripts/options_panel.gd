extends Control

# Janela de opções (volume da música, volume dos efeitos e tela cheia).
# Usada pelo menu principal e pelo menu de pausa.

signal closed

const PANEL_COLOR = Color("#172033")
const ACCENT = Color("#F5C542")
const TEXT = Color("#F8FAFC")
const MUTED = Color("#AAB8CC")

var music_slider
var music_value
var sfx_slider
var sfx_value
var fullscreen_check
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
	_update_labels()
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
	panel.custom_minimum_size = Vector2(480, 0)
	panel.add_theme_stylebox_override("panel", _panel_style())
	Assets.apply_panel(panel, "painel_janela")
	center.add_child(panel)

	var margin = MarginContainer.new()
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 34)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 28)
	panel.add_child(margin)

	var box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	margin.add_child(box)

	var title = Label.new()
	title.text = "OPÇÕES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", ACCENT)
	box.add_child(title)

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

	fullscreen_check = CheckButton.new()
	fullscreen_check.text = "Tela cheia"
	fullscreen_check.add_theme_font_size_override("font_size", 18)
	fullscreen_check.add_theme_color_override("font_color", TEXT)
	fullscreen_check.add_theme_color_override("font_hover_color", TEXT)
	fullscreen_check.add_theme_color_override("font_pressed_color", TEXT)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	Assets.apply_check(fullscreen_check)
	box.add_child(fullscreen_check)

	back_button = Button.new()
	back_button.text = "VOLTAR"
	back_button.custom_minimum_size = Vector2(220, 46)
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.add_theme_font_size_override("font_size", 17)
	Assets.apply_button(back_button)
	back_button.pressed.connect(close)
	box.add_child(back_button)


func _slider_row(text_value):
	var row = VBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var top = HBoxContainer.new()
	row.add_child(top)

	var label = Label.new()
	label.text = text_value
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", TEXT)
	top.add_child(label)

	var value = Label.new()
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", MUTED)
	top.add_child(value)

	var slider = HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.custom_minimum_size = Vector2(380, 24)
	row.add_child(slider)

	return {"row": row, "slider": slider, "value": value}


func _update_labels():
	music_value.text = _volume_text(music_slider.value)
	sfx_value.text = _volume_text(sfx_slider.value)


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


func _unhandled_input(event):
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _panel_style():
	var style = StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.border_color = ACCENT
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	return style
