extends Area2D

@export_file("*.tscn") var target_scene: String = ""

var _triggered: bool = false

func _ready():
	# Detect players/cats (collision layer 2)
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if _triggered or target_scene.is_empty():
		return
		
	if body is CharacterBody2D and body == GameManager.active_character:
		_triggered = true
		print("TransitionTrigger: Transitioning active character to: ", target_scene)
		SceneManager.transition_to_scene(target_scene)
