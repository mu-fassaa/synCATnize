extends StaticBody2D

@export var is_active: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready():
	_update_bridge_state()

func set_active(active_state: bool):
	is_active = active_state
	_update_bridge_state()

func _update_bridge_state():
	if is_active:
		# Disable collision -> Passable
		collision_layer = 0
		collision_mask = 0
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", true)
		# Solid bridge visual
		if sprite_2d:
			sprite_2d.self_modulate.a = 1.0
		print("Bridge: Active (Passable)")
	else:
		# Enable collision -> Blocked chasm
		collision_layer = 1
		collision_mask = 0
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", false)
		# Faded retracted bridge visual
		if sprite_2d:
			sprite_2d.self_modulate.a = 0.25
		print("Bridge: Inactive (Blocked)")
