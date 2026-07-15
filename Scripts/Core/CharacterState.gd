class_name CharacterState
extends RefCounted

var character: CharacterBody2D

func enter():
	pass

func exit():
	pass

func handle_input(event: InputEvent):
	pass

func update(delta: float):
	pass

func physics_update(delta: float) -> Vector2:
	# Returns movement velocity vector (or zero)
	return Vector2.ZERO
