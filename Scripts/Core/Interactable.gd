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

func _on_interact(_actor: CharacterBody2D):
	pass
