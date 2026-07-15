extends Node

var canvas_layer: CanvasLayer
var panel: PanelContainer
var label: Label

# Cached variables populated via EventBus signals
var cached_character: CharacterBody2D = null
var active_char_name: String = "None"
var active_char_state: String = "None"
var active_char_interact_target: String = "None"

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
	
	# Connect to EventBus signals
	EventBus.character_switched.connect(_on_character_switched)
	EventBus.character_state_changed.connect(_on_character_state_changed)
	EventBus.interaction_target_changed.connect(_on_interaction_target_changed)
	
	# Cache initial character state if already set
	_on_character_switched(GameManager.active_character)

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
	
	var char_pos = "N/A"
	if is_instance_valid(cached_character):
		char_pos = "(%.1f, %.1f)" % [cached_character.global_position.x, cached_character.global_position.y]
		
	label.text = """[DEBUG MENU] (F1 to Hide)
FPS: %d
Current Scene: %s
Active Character: %s
State: %s
Position: %s
Interact Target: %s""" % [fps, scene_name, active_char_name, active_char_state, char_pos, active_char_interact_target]

func _on_character_switched(char_node: CharacterBody2D):
	cached_character = char_node
	if is_instance_valid(char_node):
		active_char_name = char_node.name
		if "current_state" in char_node:
			active_char_state = _get_state_name(char_node.current_state)
		else:
			active_char_state = "None"
		if "nearest_interactable" in char_node and is_instance_valid(char_node.nearest_interactable):
			active_char_interact_target = char_node.nearest_interactable.name
		else:
			active_char_interact_target = "None"
	else:
		active_char_name = "None"
		active_char_state = "None"
		active_char_interact_target = "None"

func _on_character_state_changed(char_node: CharacterBody2D, new_state: int):
	if char_node == cached_character:
		active_char_state = _get_state_name(new_state)

func _on_interaction_target_changed(char_node: CharacterBody2D, target: Area2D):
	if char_node == cached_character:
		active_char_interact_target = target.name if is_instance_valid(target) else "None"

func _get_state_name(state: int) -> String:
	match state:
		0: return "IDLE"
		1: return "WALK"
		2: return "RUN"
		3: return "INTERACT"
		4: return "DISABLED"
		_: return "UNKNOWN"
