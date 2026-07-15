extends Area2D

@export_file("*.tscn") var target_scene: String = ""
@export var target_scene_id: String = ""
@export var target_spawn_point: String = ""

var _triggered: bool = false

func _ready():
	# Detect players/cats (collision layer 2)
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if _triggered:
		return
		
	if body is CharacterBody2D and body == GameManager.active_character:
		if not target_scene_id.is_empty():
			_triggered = true
			print("TransitionTrigger: Transitioning active character using ID: ", target_scene_id, " at spawn point: ", target_spawn_point)
			SceneManager.transition_to_scene_by_id(target_scene_id, target_spawn_point)
		elif not target_scene.is_empty():
			_triggered = true
			print("TransitionTrigger: Transitioning active character to: ", target_scene, " at spawn point: ", target_spawn_point)
			SceneManager.transition_to_scene(target_scene, target_spawn_point)
