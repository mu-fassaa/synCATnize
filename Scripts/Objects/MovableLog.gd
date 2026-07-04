extends "res://Scripts/Core/Interactable.gd"

@export var push_speed_modifier: float = 0.5
@export var allowed_axis: String = "horizontal" # "horizontal" or "vertical"
@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D

var is_being_pushed: bool = false
var pusher: CharacterBody2D = null
var push_offset: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	prompt_message = "Geser Kayu"

func _physics_process(delta):
	if is_being_pushed and is_instance_valid(pusher):
		var target_pos = pusher.global_position + push_offset
		if allowed_axis == "horizontal":
			# Only update X, locking Y axis movement
			global_position.x = lerp(global_position.x, target_pos.x, 15.0 * delta)
		else:
			# Only update Y, locking X axis movement
			global_position.y = lerp(global_position.y, target_pos.y, 15.0 * delta)

func _on_interact(actor: CharacterBody2D):
	if "is_human" in actor and actor.is_human:
		if not is_being_pushed:
			is_being_pushed = true
			pusher = actor
			pusher.speed_modifier = push_speed_modifier
			push_offset = global_position - pusher.global_position
			prompt_message = "Lepaskan Kayu"
			
			if collision_shape_2d:
				collision_shape_2d.set_deferred("disabled", true)
			print("MovableLog: Pushing started.")
		else:
			_stop_pushing()
	else:
		print("MovableLog: Cat cannot move this log!")

func _stop_pushing():
	if is_being_pushed:
		is_being_pushed = false
		if is_instance_valid(pusher):
			pusher.speed_modifier = 1.0
		pusher = null
		prompt_message = "Geser Kayu"
		
		if collision_shape_2d:
			collision_shape_2d.set_deferred("disabled", false)
		print("MovableLog: Pushing stopped.")
