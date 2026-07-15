extends CharacterBody2D

@export var npc_id: String = ""
@export var default_dialogue: Array[String] = ["Halo! Apa kabar?"]
@export var quest_dialogues: Dictionary = {} # objective_id (String) -> Array[String]
@export var patrol_points: Array[Vector2] = []
@export var patrol_speed: float = 60.0
@export var look_at_player: bool = true

@onready var sprite_2d: Sprite2D = get_node_or_null("Sprite2D")

var _current_patrol_idx: int = 0
var _is_interacting: bool = false

func _ready():
	add_to_group("npc")

func _physics_process(_delta):
	# Halt patrol during dialogue, cutscenes, or transitions
	if _is_interacting or GameManager.current_gameplay_state != GameManager.GameplayState.EXPLORATION:
		velocity = Vector2.ZERO
		return
		
	# Reusable patrol points loop
	if patrol_points.is_empty():
		return
		
	var target_pos = patrol_points[_current_patrol_idx]
	var dist = global_position.distance_to(target_pos)
	
	if dist < 10.0:
		_current_patrol_idx = (_current_patrol_idx + 1) % patrol_points.size()
	else:
		var dir = (target_pos - global_position).normalized()
		velocity = dir * patrol_speed
		_update_sprite_direction(dir)
		move_and_slide()

# Reusable Interaction callback delegated by child Interactable component
func _on_interact(actor: CharacterBody2D):
	if _is_interacting:
		return
		
	_is_interacting = true
	
	# Turn to face player
	if look_at_player and is_instance_valid(actor):
		var dir = (actor.global_position - global_position).normalized()
		_update_sprite_direction(dir)
		
	# Select data-driven dialogue lines based on quest dependencies
	var active_lines = default_dialogue
	for obj_id in quest_dialogues:
		if ObjectiveManager.is_objective_active(obj_id) or ObjectiveManager.is_objective_completed(obj_id):
			active_lines = quest_dialogues[obj_id]
			
	# Trigger dialogue sequence
	EventBus.dialogue_started.emit(npc_id.capitalize(), active_lines)
	GameManager.current_gameplay_state = GameManager.GameplayState.DIALOGUE
	
	var on_dialogue_finished: Callable
	on_dialogue_finished = func():
		EventBus.dialogue_finished.disconnect(on_dialogue_finished)
		_is_interacting = false
		GameManager.current_gameplay_state = GameManager.GameplayState.EXPLORATION
		
		# Emit generic narrative EventBus signal for quest system reactions
		EventBus.event_triggered.emit("talked_to_" + npc_id)
		print("NPC: Finished dialogue with NPC ID '", npc_id, "'")
		
	EventBus.dialogue_finished.connect(on_dialogue_finished)

func _update_sprite_direction(direction: Vector2):
	if sprite_2d:
		if direction.x < 0:
			sprite_2d.flip_h = true
		elif direction.x > 0:
			sprite_2d.flip_h = false
