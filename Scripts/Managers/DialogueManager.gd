extends Node

var canvas_layer: CanvasLayer
var panel: PanelContainer
var speaker_label: Label
var text_label: Label
var arrow_rect: TextureRect

var _lines: Array = []
var _current_line_idx: int = 0
var _active: bool = false
var _arrow_timer: float = 0.0

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
	
	# Texture-based pixel-art style box
	var style_box = StyleBoxTexture.new()
	style_box.texture = load("res://Assets/UI/textbox.png")
	style_box.texture_margin_left = 12.0
	style_box.texture_margin_right = 12.0
	style_box.texture_margin_top = 12.0
	style_box.texture_margin_bottom = 12.0
	
	style_box.content_margin_left = 22.0
	style_box.content_margin_right = 22.0
	style_box.content_margin_top = 16.0
	style_box.content_margin_bottom = 16.0
	panel.add_theme_stylebox_override("panel", style_box)
	
	# Layout containers
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var custom_font = load("res://Assets/Fonts/m6x11plus.ttf")
	
	# Speaker Label
	speaker_label = Label.new()
	if custom_font:
		speaker_label.add_theme_font_override("font", custom_font)
		speaker_label.add_theme_font_size_override("font_size", 20)
	else:
		speaker_label.add_theme_font_size_override("font_size", 14)
	speaker_label.add_theme_color_override("font_color", Color(0.65, 0.28, 0.08)) # Dark warm rust name accent
	vbox.add_child(speaker_label)
	
	# Text Label
	text_label = Label.new()
	if custom_font:
		text_label.add_theme_font_override("font", custom_font)
		text_label.add_theme_font_size_override("font_size", 18)
	else:
		text_label.add_theme_font_size_override("font_size", 13)
	text_label.add_theme_color_override("font_color", Color(0.18, 0.1, 0.05)) # Cozy dark warm brown text
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(text_label)
	
	# Create a dummy Control layer for absolute positioning of overlays (like the arrow) inside the textbox
	var overlay_control = Control.new()
	overlay_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(overlay_control)
	
	# Dialogue Continuation Arrow
	arrow_rect = TextureRect.new()
	var arrow_tex = load("res://Assets/UI/arrow.png")
	if arrow_tex:
		arrow_rect.texture = arrow_tex
		arrow_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	arrow_rect.visible = false
	overlay_control.add_child(arrow_rect)
	
	# Handle screen resizing
	get_viewport().size_changed.connect(_update_panel_position)
	_update_panel_position()

func _process(delta):
	# Gentle vertical bobbing for continuation indicator arrow (relative to textbox content margins)
	if _active and arrow_rect and arrow_rect.visible:
		_arrow_timer += delta * 7.0
		# Positions arrow at bottom-right inside the textbox bounds
		arrow_rect.position = Vector2(
			550,
			80 + sin(_arrow_timer) * 3.0
		)

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
	arrow_rect.visible = true
	
	_show_current_line()

func _show_current_line():
	if _current_line_idx < _lines.size():
		text_label.text = _lines[_current_line_idx]
	else:
		_end_dialogue()

func _end_dialogue():
	_active = false
	panel.visible = false
	arrow_rect.visible = false
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
