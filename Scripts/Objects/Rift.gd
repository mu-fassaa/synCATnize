extends Node2D

enum RiftState { DORMANT, DETECTED, ACTIVE, PUZZLE, CLOSING, CLOSED }

@export var rift_id: String = ""
@export var unlock_ability_id: String = ""
@export var unlock_character_type: int = 1 # GameManager.CharacterType.CAT
@export var associated_puzzle_id: String = ""

@export var current_state: RiftState = RiftState.ACTIVE

@onready var sprite_2d: Sprite2D = get_node_or_null("Sprite2D")

func _ready():
	add_to_group("saveable")
	_update_visuals()

# Reusable Interaction callback delegated by child Interactable component
func _on_interact(actor: CharacterBody2D):
	if current_state == RiftState.CLOSED:
		_show_dialogue("Rift", ["Rift ini sudah ditutup. Energi di area ini telah pulih sepenuhnya."])
		return
		
	# Only Cat can interact with/close the Rift
	if actor and actor.get("is_human") == true:
		_show_dialogue("Rift", [
			"Gejolak energi Rift ini terlalu besar untuk manusia.",
			"Hanya Kucing yang memiliki kepekaan spiritual untuk menyucikan Rift ini!"
		])
		return
		
	# Check if associated puzzle is solved first
	if not associated_puzzle_id.is_empty():
		var puzzle_solved = ObjectiveManager.triggered_events.has("puzzle_completed_" + associated_puzzle_id)
		if not puzzle_solved:
			_show_dialogue("Rift", [
				"Energi Rift sangat tidak stabil!", 
				"Selesaikan mekanisme puzzle di area ini terlebih dahulu untuk menstabilkannya."
			])
			return
			
	# Start closure sequence
	_close_rift()

func _close_rift():
	current_state = RiftState.CLOSING
	_update_visuals()
	
	# Transition game state and freeze character
	GameManager.current_gameplay_state = GameManager.GameplayState.CUTSCENE
	var active_char = GameManager.active_character
	if is_instance_valid(active_char) and active_char.has_method("change_state_by_enum"):
		active_char.change_state_by_enum(4) # CharacterStateEnum.DISABLED
		
	var cam = get_tree().current_scene.get_node_or_null("GameCamera")
	if cam:
		cam.set_target(self)
		
	_show_dialogue("System", ["Menutup Rift... Energi negatif mulai menghilang dari area!"])
	
	# Wait for closure delay
	get_tree().create_timer(2.0).timeout.connect(func():
		current_state = RiftState.CLOSED
		_update_visuals()
		
		# Restore control
		if is_instance_valid(active_char) and active_char.has_method("change_state_by_enum"):
			active_char.change_state_by_enum(0) # CharacterStateEnum.IDLE
		if cam and is_instance_valid(active_char):
			cam.set_target(active_char)
			
		GameManager.current_gameplay_state = GameManager.GameplayState.EXPLORATION
		
		# Ability progression unlock
		if not unlock_ability_id.is_empty():
			AbilityManager.unlock_ability(unlock_character_type, unlock_ability_id)
			
		# Emit global progression events
		EventBus.rift_closed.emit(rift_id)
		EventBus.rift_state_changed.emit(rift_id, RiftState.CLOSED)
		EventBus.event_triggered.emit("rift_closed_" + rift_id)
		
		# Modulate environment color to healthy green
		_restore_environment()
		
		_show_dialogue("System", [
			"Rift Berhasil Ditutup!",
			"Energi negatif berhasil disucikan dari wilayah ini.",
			"Kemampuan baru telah terbuka!"
		])
	)

func _show_dialogue(speaker: String, text_lines: Array):
	EventBus.dialogue_started.emit(speaker, text_lines)
	GameManager.current_gameplay_state = GameManager.GameplayState.DIALOGUE
	
	var on_dialogue_finished: Callable
	on_dialogue_finished = func():
		EventBus.dialogue_finished.disconnect(on_dialogue_finished)
		if current_state != RiftState.CLOSING:
			GameManager.current_gameplay_state = GameManager.GameplayState.EXPLORATION
		
	EventBus.dialogue_finished.connect(on_dialogue_finished)

func _update_visuals():
	if sprite_2d:
		match current_state:
			RiftState.CLOSED:
				sprite_2d.self_modulate = Color(0.1, 0.8, 0.9, 0.4) # Cyan & translucent
				sprite_2d.scale = Vector2(0.3, 0.3)
			RiftState.CLOSING:
				sprite_2d.self_modulate = Color(0.9, 0.9, 0.1, 0.9) # Glowing yellow
				sprite_2d.scale = Vector2(0.5, 0.5)
			_:
				sprite_2d.self_modulate = Color(0.7, 0.1, 0.8, 0.8) # Purple
				sprite_2d.scale = Vector2(0.6, 0.6)

func _restore_environment():
	var floor_node = get_tree().current_scene.get_node_or_null("Walls/Floor")
	if floor_node and floor_node is Sprite2D:
		var tween = create_tween()
		tween.tween_property(floor_node, "self_modulate", Color(0.35, 0.55, 0.35, 1.0), 2.5)

# ==========================================
# SAVEABLE CONVENTION
# ==========================================
func get_save_data() -> Dictionary:
	return { "current_state": current_state }

func load_save_data(data: Dictionary):
	current_state = int(data.get("current_state", RiftState.ACTIVE))
	_update_visuals()
	if current_state == RiftState.CLOSED:
		var floor_node = get_tree().current_scene.get_node_or_null("Walls/Floor")
		if floor_node and floor_node is Sprite2D:
			floor_node.self_modulate = Color(0.35, 0.55, 0.35, 1.0)
