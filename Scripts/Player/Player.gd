extends "res://Scripts/Core/CharacterBase.gd"

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	super._ready()
	is_human = true
	# Set this character as default active character at start
	if GameManager.active_character == null:
		GameManager.active_character = self

func _play_walk_animation(direction: Vector2):
	# Control animation states or flip sprite horizontally based on velocity direction
	if sprite_2d:
		if direction.x < 0:
			sprite_2d.flip_h = true
		elif direction.x > 0:
			sprite_2d.flip_h = false

func _play_idle_animation():
	# Idle animation triggers here in the future
	pass
