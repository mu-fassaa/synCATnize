extends Area2D

@export var speed_penalty: float = 0.75
@onready var sprite_2d: Sprite2D = $Sprite2D

var overlaps_count: int = 0
var wiggle_tween: Tween = null

func _ready():
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		body.speed_modifier = speed_penalty
		overlaps_count += 1
		_wiggle()
		print("TallGrass: Entered by ", body.name)

func _on_body_exited(body: Node2D):
	if body is CharacterBody2D:
		body.speed_modifier = 1.0
		overlaps_count -= 1
		print("TallGrass: Exited by ", body.name)

func _wiggle():
	if not sprite_2d:
		return
		
	if wiggle_tween:
		wiggle_tween.kill()
		
	wiggle_tween = create_tween()
	# Perform a quick wiggle animation back and forth
	wiggle_tween.tween_property(sprite_2d, "rotation_degrees", 15.0, 0.1)
	wiggle_tween.tween_property(sprite_2d, "rotation_degrees", -12.0, 0.15)
	wiggle_tween.tween_property(sprite_2d, "rotation_degrees", 8.0, 0.15)
	wiggle_tween.tween_property(sprite_2d, "rotation_degrees", 0.0, 0.1)
