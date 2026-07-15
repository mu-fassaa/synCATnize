extends Node

signal completed(puzzle_id: String)
signal reset_triggered(puzzle_id: String)

@export var puzzle_id: String = ""
@export var required_nodes: Array[NodePath] = []
@export var dependencies: Array[Dictionary] = [] # Array of dicts representing general dependencies

@export_category("Completion Callback")
@export var trigger_target: NodePath
@export var trigger_method: String = ""
@export var trigger_value: bool = true

var is_completed: bool = false

func _ready():
	add_to_group("saveable")
	add_to_group("puzzles")
	
	# Connect to activator signals dynamically
	for path in required_nodes:
		var node = get_node_or_null(path)
		if node and node.has_signal("activated"):
			node.activated.connect(_on_step_activated)
			
	# Initial validation check on load
	_check_puzzle_state()

func _on_step_activated(_is_on: bool):
	_check_puzzle_state()

func _check_puzzle_state():
	if is_completed:
		return
		
	if not are_dependencies_met():
		return
		
	var all_active = true
	for path in required_nodes:
		var node = get_node_or_null(path)
		if node:
			var is_node_active = false
			if "is_on" in node:
				is_node_active = node.is_on
			elif "is_open" in node:
				is_node_active = node.is_open
			
			if not is_node_active:
				all_active = false
				break
				
	if all_active and not required_nodes.is_empty():
		complete_puzzle()

func complete_puzzle():
	if is_completed:
		return
	is_completed = true
	print("PuzzleController: Puzzle '", puzzle_id, "' completed!")
	
	# Emit EventBus and local signals
	EventBus.puzzle_completed.emit(puzzle_id)
	EventBus.event_triggered.emit("puzzle_completed_" + puzzle_id)
	completed.emit(puzzle_id)
	
	# Execute completion callback
	if not trigger_target.is_empty():
		var target = get_node_or_null(trigger_target)
		if target and not trigger_method.is_empty() and target.has_method(trigger_method):
			target.call(trigger_method, trigger_value)

func reset_puzzle():
	is_completed = false
	print("PuzzleController: Puzzle '", puzzle_id, "' reset.")
	reset_triggered.emit(puzzle_id)
	
	# Revert callback target state
	if not trigger_target.is_empty():
		var target = get_node_or_null(trigger_target)
		if target and not trigger_method.is_empty() and target.has_method(trigger_method):
			target.call(trigger_method, not trigger_value)
			
	# Reset states on activator nodes
	for path in required_nodes:
		var node = get_node_or_null(path)
		if node and node.has_method("reset_state"):
			node.reset_state()

func are_dependencies_met() -> bool:
	for dep in dependencies:
		var dep_type = dep.get("type", "")
		var dep_id = dep.get("id", "")
		
		match dep_type:
			"puzzle":
				if not ObjectiveManager.triggered_events.has("puzzle_completed_" + dep_id):
					return false
			"ability":
				var char_type = int(dep.get("character_type", 0))
				if not AbilityManager.is_ability_unlocked(char_type, dep_id):
					return false
			"quest":
				var required_status = int(dep.get("status", 1)) # COMPLETED = 1
				if ObjectiveManager.get_objective_status(dep_id) != required_status:
					return false
			"event":
				if not ObjectiveManager.triggered_events.has(dep_id):
					return false
	return true

# ==========================================
# SAVEABLE CONVENTION
# ==========================================
func get_save_data() -> Dictionary:
	return { "is_completed": is_completed }

func load_save_data(data: Dictionary):
	is_completed = data.get("is_completed", false)
	if is_completed:
		# Trigger callback on load to align state
		if not trigger_target.is_empty():
			var target = get_node_or_null(trigger_target)
			if target and not trigger_method.is_empty() and target.has_method(trigger_method):
				target.call_deferred("call", trigger_method, trigger_value)
