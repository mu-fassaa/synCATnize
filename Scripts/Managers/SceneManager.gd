extends Node

signal scene_transition_started(target_scene: String)
signal scene_transition_finished(target_scene: String)

var canvas_layer: CanvasLayer
var color_rect: ColorRect

var next_spawn_point_name: String = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Setup screen transition overlay dynamically
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128 # Draw on top of everything
	add_child(canvas_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0) # Start fully transparent
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(color_rect)

func transition_to_scene(target_scene_path: String, spawn_point_name: String = ""):
	next_spawn_point_name = spawn_point_name
	scene_transition_started.emit(target_scene_path)
	
	# Lock player input and block mouse clicks during fade
	InputManager.set_input_locked(true)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Fade to Black
	var tween = create_tween()
	tween.tween_property(color_rect, "color", Color(0, 0, 0, 1), 0.4)
	await tween.finished
	
	# Perform the scene switch
	var err = get_tree().change_scene_to_file(target_scene_path)
	if err != OK:
		print("SceneManager ERROR: Failed to transition to: ", target_scene_path)
		
	# Wait for next frame so the new scene tree initializes
	await get_tree().process_frame
	
	# Fade from Black (Reveal)
	var tween_reveal = create_tween()
	tween_reveal.tween_property(color_rect, "color", Color(0, 0, 0, 0), 0.4)
	await tween_reveal.finished
	
	# Restore input control
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	InputManager.set_input_locked(false)
	
	scene_transition_finished.emit(target_scene_path)
