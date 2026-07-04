extends Area2D

@export var speed_penalty: float = 0.5
@export var transparency_alpha: float = 0.4

func _ready():
	# Detect players/cats (collision layer 2)
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if body is CharacterBody2D:
		# Apply stealth and slow down
		body.speed_modifier = speed_penalty
		var sprite = body.get_node_or_null("Sprite2D")
		if sprite:
			sprite.self_modulate.a = transparency_alpha
		print("Bush: Entered by ", body.name, ". Speed slowed, visibility reduced.")

func _on_body_exited(body: Node2D):
	if body is CharacterBody2D:
		# Restore original speed and opacity
		body.speed_modifier = 1.0
		var sprite = body.get_node_or_null("Sprite2D")
		if sprite:
			sprite.self_modulate.a = 1.0
		print("Bush: Exited by ", body.name, ". Speed and visibility restored.")
