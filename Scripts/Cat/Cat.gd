extends "res://Scripts/Core/CharacterBase.gd"

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	super._ready()
	is_human = false

func _play_walk_animation(direction: Vector2):
	if sprite_2d:
		if direction.x < 0:
			sprite_2d.flip_h = true
		elif direction.x > 0:
			sprite_2d.flip_h = false

func _play_idle_animation():
	pass

func _on_interact(_actor: CharacterBody2D):
	if not GameManager.is_switch_allowed:
		EventBus.event_triggered.emit("met_cat")
