extends "res://Scripts/Core/Interactable.gd"

@export var push_speed_modifier: float = 0.5
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_being_pushed: bool = false
var pusher: CharacterBody2D = null
var push_offset: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	prompt_message = "Dorong Peti"

func _physics_process(delta):
	if is_being_pushed and is_instance_valid(pusher):
		var target_pos = pusher.global_position + push_offset
		global_position = global_position.lerp(target_pos, 15.0 * delta)

func _on_interact(actor: CharacterBody2D):
	if "is_human" in actor and actor.is_human:
		if not is_being_pushed:
			# Start pushing
			is_being_pushed = true
			pusher = actor
			pusher.speed_modifier = push_speed_modifier
			push_offset = global_position - pusher.global_position
			prompt_message = "Lepaskan Peti"
			
			if collision_shape_2d:
				collision_shape_2d.set_deferred("disabled", true)
			print("PushableBox: Pushing started.")
		else:
			_stop_pushing()
	else:
		print("PushableBox: Cat cannot push this box!")

func _stop_pushing():
	if is_being_pushed:
		is_being_pushed = false
		if is_instance_valid(pusher):
			pusher.speed_modifier = 1.0
		pusher = null
		prompt_message = "Dorong Peti"
		
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", false)
		print("PushableBox: Pushing stopped.")
