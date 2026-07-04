extends Node2D

@onready var game_camera = $GameCamera
@onready var player = $Player
@onready var cat = $Cat
@onready var ui_prompt_label = $CanvasLayer/Control/PromptLabel
@onready var goal_ui = $CanvasLayer/Control/GoalUI
@onready var ledge_detector = $LedgeDetector
@onready var ledge_invisible_wall = $LedgeInvisibleWall
@onready var ledge_sprite = $LedgeInvisibleWall/Sprite2D

func _ready():
	# Configure camera focus on Human by default
	if game_camera and player:
		game_camera.set_target(player)
		
	# Connect interaction prompt updates
	if player:
		player.interaction_target_changed.connect(_on_interaction_target_changed)
	if cat:
		cat.interaction_target_changed.connect(_on_interaction_target_changed)
		
	# Connect puzzle elements
	if has_node("GoalArea"):
		$GoalArea.body_entered.connect(_on_goal_area_entered)
	if has_node("Lever") and has_node("Door"):
		$Lever.activated.connect($Door.set_open)

	# Monitor the box at the ledge detector zone
	if ledge_detector:
		ledge_detector.area_entered.connect(_on_ledge_area_entered)
		ledge_detector.area_exited.connect(_on_ledge_area_exited)
	
	if goal_ui:
		goal_ui.visible = false

func _unhandled_input(event):
	# Switch active character on pressing C
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			_switch_character()

func _switch_character():
	if ui_prompt_label:
		ui_prompt_label.visible = false
		
	# Detach box if currently being pushed during character switch
	var box = get_node_or_null("PushableBox")
	if box and box.has_method("_stop_pushing"):
		box._stop_pushing()
		
	if GameManager.active_character == player:
		GameManager.active_character = cat
		game_camera.set_target(cat)
		print("Control: CAT")
	else:
		GameManager.active_character = player
		game_camera.set_target(player)
		print("Control: PLAYER")

func _on_interaction_target_changed(interactable):
	if ui_prompt_label:
		if interactable:
			ui_prompt_label.text = "Tekan E untuk " + interactable.prompt_message
			ui_prompt_label.visible = true
			var viewport_size = get_viewport().get_visible_rect().size
			ui_prompt_label.position = Vector2((viewport_size.x - ui_prompt_label.size.x) / 2.0, viewport_size.y - 100.0)
		else:
			ui_prompt_label.visible = false

func _on_ledge_area_entered(area):
	if area.name == "PushableBox":
		# Crate is pushed in front of the ledge -> Make ledge passable for Cat
		if ledge_invisible_wall:
			ledge_invisible_wall.collision_layer = 0
			ledge_invisible_wall.collision_mask = 0
			var shape = ledge_invisible_wall.get_node_or_null("CollisionShape2D")
			if shape:
				shape.set_deferred("disabled", true)
		if ledge_sprite:
			ledge_sprite.self_modulate = Color(0.3, 0.8, 0.3, 0.2)
		print("Ledge: Box in place. Ledge is now passable for Cat!")

func _on_ledge_area_exited(area):
	if area.name == "PushableBox":
		# Crate is pulled away -> Block ledge again
		if ledge_invisible_wall:
			ledge_invisible_wall.collision_layer = 1
			ledge_invisible_wall.collision_mask = 0
			var shape = ledge_invisible_wall.get_node_or_null("CollisionShape2D")
			if shape:
				shape.set_deferred("disabled", false)
		if ledge_sprite:
			ledge_sprite.self_modulate = Color(0.5, 0.25, 0.1, 1.0)
		print("Ledge: Box removed. Ledge is blocked!")

func _on_goal_area_entered(body):
	if body == player:
		if goal_ui:
			goal_ui.visible = true
		InputManager.set_input_locked(true)
		print("Sandbox: Goal Reached! Prototype Complete.")
