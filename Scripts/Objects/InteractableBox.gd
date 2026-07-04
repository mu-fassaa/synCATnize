extends "res://Scripts/Core/Interactable.gd"

@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_interact(actor: CharacterBody2D):
	# visual feedback when interacted: random color flash!
	if sprite_2d:
		sprite_2d.self_modulate = Color(randf_range(0.4, 1.0), randf_range(0.4, 1.0), randf_range(0.4, 1.0), 1.0)
		print("InteractableBox: Color changed by interaction from ", actor.name)
