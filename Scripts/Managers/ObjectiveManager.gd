extends Node

enum ObjectiveStatus { ACTIVE, COMPLETED, FAILED }

# Dictionary of objectives: objective_id (String) -> Dictionary of properties
var objectives: Dictionary = {}
var triggered_events: Dictionary = {}

func _ready():
	add_to_group("saveable")
	
	# Connect to EventBus signals to auto-resolve objectives dynamically
	EventBus.puzzle_completed.connect(_on_puzzle_completed)
	EventBus.rift_closed.connect(_on_rift_closed)
	EventBus.event_triggered.connect(_on_event_triggered)

func add_objective(objective_id: String, description: String, type: String):
	if not objectives.has(objective_id):
		objectives[objective_id] = {
			"description": description,
			"type": type, # "talk_npc", "visit_area", "solve_puzzle", "close_rift", "interact_object"
			"status": ObjectiveStatus.ACTIVE
		}
		print("ObjectiveManager: Added objective '", objective_id, "' -> ", description)
		EventBus.objective_updated.emit(objective_id, ObjectiveStatus.ACTIVE)

func complete_objective(objective_id: String):
	if objectives.has(objective_id) and objectives[objective_id]["status"] == ObjectiveStatus.ACTIVE:
		objectives[objective_id]["status"] = ObjectiveStatus.COMPLETED
		print("ObjectiveManager: Completed objective '", objective_id, "'")
		EventBus.objective_updated.emit(objective_id, ObjectiveStatus.COMPLETED)

func fail_objective(objective_id: String):
	if objectives.has(objective_id) and objectives[objective_id]["status"] == ObjectiveStatus.ACTIVE:
		objectives[objective_id]["status"] = ObjectiveStatus.FAILED
		print("ObjectiveManager: Failed objective '", objective_id, "'")
		EventBus.objective_updated.emit(objective_id, ObjectiveStatus.FAILED)

func is_objective_completed(objective_id: String) -> bool:
	if objectives.has(objective_id):
		return objectives[objective_id]["status"] == ObjectiveStatus.COMPLETED
	return false

func is_objective_active(objective_id: String) -> bool:
	if objectives.has(objective_id):
		return objectives[objective_id]["status"] == ObjectiveStatus.ACTIVE
	return false

func get_objective_status(objective_id: String) -> int:
	if objectives.has(objective_id):
		return objectives[objective_id]["status"]
	return ObjectiveStatus.FAILED

# ==========================================
# EVENT BUS AUTOMATIC RESOLVERS
# ==========================================
func _on_puzzle_completed(puzzle_id: String):
	# Auto-complete objectives of type "solve_puzzle" with matching target IDs
	for obj_id in objectives:
		var obj = objectives[obj_id]
		if obj["status"] == ObjectiveStatus.ACTIVE and obj["type"] == "solve_puzzle":
			if obj_id == puzzle_id or obj["description"].contains(puzzle_id):
				complete_objective(obj_id)

func _on_rift_closed(rift_id: String):
	# Auto-complete objectives of type "close_rift" with matching IDs
	for obj_id in objectives:
		var obj = objectives[obj_id]
		if obj["status"] == ObjectiveStatus.ACTIVE and obj["type"] == "close_rift":
			if obj_id == rift_id or obj["description"].contains(rift_id):
				complete_objective(obj_id)

func _on_event_triggered(event_id: String):
	triggered_events[event_id] = true
	# Auto-complete objective by generic trigger strings (e.g. "talked_to_elder", "visited_forest")
	for obj_id in objectives:
		var obj = objectives[obj_id]
		if obj["status"] == ObjectiveStatus.ACTIVE:
			if event_id == "talked_to_" + obj_id or event_id == "visited_" + obj_id or event_id == "interacted_" + obj_id:
				complete_objective(obj_id)

# ==========================================
# SAVEABLE CONVENTION
# ==========================================
func get_save_data() -> Dictionary:
	var data: Dictionary = {}
	data["objectives"] = {}
	for obj_id in objectives:
		data["objectives"][obj_id] = {
			"description": objectives[obj_id]["description"],
			"type": objectives[obj_id]["type"],
			"status": objectives[obj_id]["status"]
		}
	data["triggered_events"] = triggered_events
	return data

func load_save_data(data: Dictionary):
	objectives.clear()
	triggered_events.clear()
	if data.has("objectives"):
		for obj_id in data["objectives"]:
			objectives[obj_id] = {
				"description": data["objectives"][obj_id]["description"],
				"type": data["objectives"][obj_id]["type"],
				"status": int(data["objectives"][obj_id]["status"])
			}
	if data.has("triggered_events"):
		triggered_events = data["triggered_events"]
	print("ObjectiveManager: Save state loaded. Objectives: ", objectives.size(), ", Events: ", triggered_events.size())
