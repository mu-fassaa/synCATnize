extends Node

signal scene_transition_started(target_scene: String)
signal scene_transition_finished(target_scene: String)

var canvas_layer: CanvasLayer
var color_rect: ColorRect
var animation_player: AnimationPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Programmatically setup overlay CanvasLayer for transitions to keep things clean
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 128
	add_child(canvas_layer)
	
	color_rect = ColorRect.new()
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.anchors_preset = Control.PRESET_FULL_RECT
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_layer.add_child(color_rect)
	
	animation_player = AnimationPlayer.new()
	add_child(animation_player)
	
	var library = AnimationLibrary.new()
	
	var anim_to_black = Animation.new()
	var track_idx = anim_to_black.add_track(Animation.TYPE_VALUE)
	anim_to_black.track_set_path(track_idx, "CanvasLayer/ColorRect:color")
	anim_to_black.track_insert_key(track_idx, 0.0, Color(0, 0, 0, 0))
	anim_to_black.track_insert_key(track_idx, 0.3, Color(0, 0, 0, 1))
	library.add_animation("fade_to_black", anim_to_black)
	
	var anim_from_black = Animation.new()
	track_idx = anim_from_black.add_track(Animation.TYPE_VALUE)
	anim_from_black.track_set_path(track_idx, "CanvasLayer/ColorRect:color")
	anim_from_black.track_insert_key(track_idx, 0.0, Color(0, 0, 0, 1))
	anim_from_black.track_insert_key(track_idx, 0.3, Color(0, 0, 0, 0))
	library.add_animation("fade_from_black", anim_from_black)
	
	animation_player.add_animation_library("", library)

func transition_to_scene(target_scene_path: String):
	scene_transition_started.emit(target_scene_path)
	
	# Block input and mouse interaction
	InputManager.set_input_locked(true)
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	
	animation_player.play("fade_to_black")
	await animation_player.animation_finished
	
	# Load target scene
	var err = get_tree().change_scene_to_file(target_scene_path)
	if err != OK:
		print("SceneManager ERROR: Failed to load scene: ", target_scene_path)
		
	# Yield one frame for scene tree setup
	await get_tree().process_frame
	
	animation_player.play("fade_from_black")
	await animation_player.animation_finished
	
	# Restore input and mouse interaction
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	InputManager.set_input_locked(false)
	
	scene_transition_finished.emit(target_scene_path)
