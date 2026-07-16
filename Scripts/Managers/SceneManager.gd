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

const SCENE_REGISTRY = {
	"main_menu": "res://Scenes/UI/MainMenu.tscn",
	"player_house": "res://Scenes/World/PlayerHouse.tscn",
	"greenhouse": "res://Scenes/World/Greenhouse.tscn",
	"village": "res://Scenes/World/Village.tscn",
	"elder_house": "res://Scenes/World/ElderHouse.tscn",
	"florist": "res://Scenes/World/Florist.tscn",
	"carpenter": "res://Scenes/World/Carpenter.tscn",
	"blacksmith": "res://Scenes/World/Blacksmith.tscn",
	"inn": "res://Scenes/World/Inn.tscn",
	"empty_house": "res://Scenes/World/EmptyHouse.tscn",
	"child_house": "res://Scenes/World/ChildHouse.tscn",
	"forest": "res://Scenes/World/Forest.tscn",
	"forest_river": "res://Scenes/World/ForestRiver.tscn",
	"nelayan_house": "res://Scenes/World/NelayanHouse.tscn",
	"river": "res://Scenes/World/River.tscn",
	"ancient_shrine": "res://Scenes/World/AncientShrine.tscn",
	"cliff_shrine": "res://Scenes/World/CliffShrine.tscn"
}

func transition_to_scene_by_id(scene_id: String, spawn_point_name: String = ""):
	if SCENE_REGISTRY.has(scene_id):
		transition_to_scene(SCENE_REGISTRY[scene_id], spawn_point_name)
	else:
		print("SceneManager ERROR: Scene ID not registered -> ", scene_id)

