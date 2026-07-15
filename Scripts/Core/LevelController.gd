extends Node2D

@onready var game_camera = get_node_or_null("GameCamera")
@onready var player = get_node_or_null("Player")
@onready var cat = get_node_or_null("Cat")
@onready var ui_prompt_label = get_node_or_null("CanvasLayer/Control/PromptLabel")

func _ready():
	# Standardize level container hierarchy programmatically if not present in the scene
	_ensure_container_exists("PuzzleContainer")
	_ensure_container_exists("NPCContainer")
	_ensure_container_exists("CollectibleContainer")
	_ensure_container_exists("EventTriggers")
	_ensure_container_exists("AudioZones")
	_ensure_container_exists("LightingZones")
	
	# Position characters at transition spawn point if specified
	if not SceneManager.next_spawn_point_name.is_empty():
		var spawn_node = get_node_or_null("SpawnPoints/" + SceneManager.next_spawn_point_name)
		if spawn_node:
			var spawn_pos = spawn_node.global_position
			if player:
				player.global_position = spawn_pos
			if cat:
				cat.global_position = spawn_pos + Vector2(30, 0) # Offset slightly
				
	# Configure camera focus on active character by default
	if game_camera:
		var target = GameManager.active_character if GameManager.active_character else player
		if target:
			game_camera.set_target(target)
			# Snap camera instantly to target to avoid panning on level load
			game_camera.global_position = target.global_position
			
		# Apply camera bounds based on Floor size dynamically
		var floor_node = get_node_or_null("Walls/Floor")
		if floor_node and floor_node is Sprite2D:
			var tex_size = floor_node.texture.get_size() if floor_node.texture else Vector2(128, 128)
			var scaled_size = tex_size * floor_node.scale
			var bounds = Rect2(
				floor_node.global_position - scaled_size / 2.0,
				scaled_size
			)
			game_camera.set_camera_limits(bounds)
			
	# Connect interaction prompt updates
	if player:
		player.interaction_target_changed.connect(_on_interaction_target_changed)
	if cat:
		cat.interaction_target_changed.connect(_on_interaction_target_changed)

func _ensure_container_exists(container_name: String):
	if not has_node(container_name):
		var node = Node2D.new()
		node.name = container_name
		add_child(node)

func _unhandled_input(event):
	# Switch active character on pressing C
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C:
			_switch_character()

func _switch_character():
	if not GameManager.is_switch_allowed:
		print("LevelController: Character switching is locked.")
		return
		
	if ui_prompt_label:
		ui_prompt_label.visible = false
		
	# Detach box/log if currently being pushed during character switch
	var box = get_node_or_null("PushableBox")
	if box and box.has_method("_stop_pushing"):
		box._stop_pushing()
	var log_obj = get_node_or_null("MovableLog")
	if log_obj and log_obj.has_method("_stop_pushing"):
		log_obj._stop_pushing()
		
	if GameManager.active_character == player:
		GameManager.active_character = cat
		if game_camera and cat:
			game_camera.set_target(cat)
		print("Control: CAT")
	else:
		GameManager.active_character = player
		if game_camera and player:
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
