extends StaticBody2D

@export var is_open: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready():
	add_to_group("saveable")
	_update_door_state()

func get_save_data() -> Dictionary:
	return { "is_open": is_open }

func load_save_data(data: Dictionary):
	set_open(data.get("is_open", false))

func set_open(open_state: bool):
	is_open = open_state
	_update_door_state()

func _update_door_state():
	if is_open:
		# Disable physics collision
		collision_layer = 0
		collision_mask = 0
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", true)
		# Semi-transparent visual representation
		if sprite_2d:
			sprite_2d.self_modulate = Color(0.2, 0.45, 0.85, 0.2)
		print("Door: Opened.")
	else:
		# Enable physics collision
		collision_layer = 1
		collision_mask = 0
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", false)
		# Solid visual representation
		if sprite_2d:
			sprite_2d.self_modulate = Color(0.2, 0.45, 0.85, 1.0)
		print("Door: Closed.")
