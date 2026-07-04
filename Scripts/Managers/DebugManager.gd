extends Node

var canvas_layer: CanvasLayer
var panel: PanelContainer
var label: Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Setup CanvasLayer dynamically
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 150 # Draw above standard UI
	add_child(canvas_layer)
	
	# Setup PanelContainer
	panel = PanelContainer.new()
	panel.visible = false
	panel.custom_minimum_size = Vector2(250, 160)
	panel.position = Vector2(20, 20)
	
	# Translucent background style box
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.7)
	style_box.set_content_margin_all(12.0)
	panel.add_theme_stylebox_override("panel", style_box)
	
	canvas_layer.add_child(panel)
	
	# Setup Label
	label = Label.new()
	label.add_theme_font_size_override("font_size", 13)
	panel.add_child(label)

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			panel.visible = not panel.visible
			print("DebugManager: Toggled visibility to ", panel.visible)

func _process(_delta):
	if not panel.visible:
		return
		
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var current_scene = get_tree().current_scene
	var scene_name = current_scene.name if current_scene else "None"
	
	var active_char = GameManager.active_character
	var char_name = "None"
	var char_state = "None"
	var char_pos = "N/A"
	var interact_target = "None"
	
	if is_instance_valid(active_char):
		char_name = active_char.name
		if "current_state" in active_char:
			char_state = _get_state_name(active_char.current_state)
		char_pos = "(%.1f, %.1f)" % [active_char.global_position.x, active_char.global_position.y]
		if "nearest_interactable" in active_char and is_instance_valid(active_char.nearest_interactable):
			interact_target = active_char.nearest_interactable.name
			
	label.text = """[DEBUG MENU] (F1 to Hide)
FPS: %d
Current Scene: %s
Active Character: %s
State: %s
Position: %s
Interact Target: %s""" % [fps, scene_name, char_name, char_state, char_pos, interact_target]

func _get_state_name(state: int) -> String:
	match state:
		0: return "IDLE"
		1: return "WALK"
		2: return "RUN"
		3: return "INTERACT"
		4: return "DISABLED"
		_: return "UNKNOWN"
