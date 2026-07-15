extends Area2D

signal activated(is_on: bool)

@export var is_on: bool = false
@onready var sprite_2d: Sprite2D = $Sprite2D

var overlapping_entities: Array[Node2D] = []

func _ready():
	add_to_group("saveable")
	# Detect environment solids like boxes (Layer 1) and players/cats (Layer 2)
	collision_layer = 0
	collision_mask = 3
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_visual()

func get_save_data() -> Dictionary:
	return { "is_on": is_on }

func load_save_data(data: Dictionary):
	is_on = data.get("is_on", false)
	_update_visual()
	activated.emit(is_on)

func _on_body_entered(body: Node2D):
	if not overlapping_entities.has(body):
		overlapping_entities.append(body)
		_check_activation()

func _on_body_exited(body: Node2D):
	if overlapping_entities.has(body):
		overlapping_entities.erase(body)
		_check_activation()

func _check_activation():
	var should_be_on = overlapping_entities.size() > 0
	if should_be_on != is_on:
		is_on = should_be_on
		_update_visual()
		activated.emit(is_on)
		print("PressurePlate: state changed to ", is_on)

func _update_visual():
	if sprite_2d:
		if is_on:
			sprite_2d.self_modulate = Color(0.4, 0.4, 0.4, 1.0)
			sprite_2d.scale = Vector2(0.25, 0.25)
		else:
			sprite_2d.self_modulate = Color(0.7, 0.7, 0.7, 1.0)
			sprite_2d.scale = Vector2(0.3, 0.3)
