extends "res://Scripts/Core/Interactable.gd"

signal activated(is_on: bool)

@export var is_on: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	super._ready()
	prompt_message = "Tarik Tuas"
	_update_visual()

func _on_interact(actor: CharacterBody2D):
	if "is_human" in actor and not actor.is_human:
		is_on = not is_on
		_update_visual()
		activated.emit(is_on)
		print("Lever: Toggled to ", is_on, " by ", actor.name)
	else:
		print("Lever: Human is too big to reach the small lever!")

func _update_visual():
	if sprite_2d:
		if is_on:
			sprite_2d.self_modulate = Color(0.95, 0.95, 0.15) # Yellow when active
		else:
			sprite_2d.self_modulate = Color(0.95, 0.55, 0.15) # Orange when inactive
