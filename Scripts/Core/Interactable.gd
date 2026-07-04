extends Area2D

signal interacted(actor: CharacterBody2D)

@export var prompt_message: String = "Interaksi"

func _ready():
	collision_layer = 4
	collision_mask = 0

func interact(actor: CharacterBody2D):
	print("Interactable: ", name, " interacted with by ", actor.name)
	_on_interact(actor)
	interacted.emit(actor)
	
	# Support Composition: delegate to parent node if it implements _on_interact
	var parent = get_parent()
	if parent and parent.has_method("_on_interact"):
		parent._on_interact(actor)

func _on_interact(_actor: CharacterBody2D):
	pass
