extends Node

var canvas_layer: CanvasLayer
var panel: PanelContainer
var speaker_label: Label
var text_label: Label

var _lines: Array = []
var _current_line_idx: int = 0
var _active: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect to dialogue starting signal on the EventBus
	EventBus.dialogue_started.connect(start_dialogue)
	
	# Setup CanvasLayer dynamically
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Below debug panel, above level UI
	add_child(canvas_layer)
	
	# Setup PanelContainer
	panel = PanelContainer.new()
	panel.visible = false
	panel.custom_minimum_size = Vector2(600, 120)
	canvas_layer.add_child(panel)
	
	# Translucent background style box
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.06, 0.06, 0.08, 0.85) # Slate dark mode
	style_box.set_content_margin_all(14.0)
	style_box.corner_radius_top_left = 6
	style_box.corner_radius_top_right = 6
	style_box.corner_radius_bottom_left = 6
	style_box.corner_radius_bottom_right = 6
	panel.add_theme_stylebox_override("panel", style_box)
	
	# Layout containers
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Speaker Label
	speaker_label = Label.new()
	speaker_label.add_theme_font_size_override("font_size", 14)
	speaker_label.add_theme_color_override("font_color", Color(0.95, 0.6, 0.15)) # Orange name accent
	vbox.add_child(speaker_label)
	
	# Text Label
	text_label = Label.new()
	text_label.add_theme_font_size_override("font_size", 13)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(text_label)
	
	# Handle screen resizing
	get_viewport().size_changed.connect(_update_panel_position)
	_update_panel_position()

func _update_panel_position():
	var viewport_size = get_viewport().get_visible_rect().size
	panel.position = Vector2(
		(viewport_size.x - 600) / 2.0,
		viewport_size.y - 150.0
	)

func start_dialogue(speaker: String, lines: Array):
	if _active:
		return
		
	_active = true
	_lines = lines
	_current_line_idx = 0
	
	speaker_label.text = speaker
	panel.visible = true
	
	_show_current_line()

func _show_current_line():
	if _current_line_idx < _lines.size():
		text_label.text = _lines[_current_line_idx]
	else:
		_end_dialogue()

func _end_dialogue():
	_active = false
	panel.visible = false
	EventBus.dialogue_finished.emit()

func _input(event):
	if not _active:
		return
		
	# Advance text on E, Space, Enter, or mouse click
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			get_viewport().set_input_as_handled()
			_current_line_idx += 1
			_show_current_line()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_current_line_idx += 1
			_show_current_line()
