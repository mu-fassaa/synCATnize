extends Node

# Stores list of held item IDs (e.g. "fisherman_key", "ancient_relic")
var items: Array[String] = []

func _ready():
	add_to_group("saveable")

func add_item(item_id: String):
	if not items.has(item_id):
		items.append(item_id)
		print("InventoryManager: Added item '", item_id, "'")
		# We can trigger generic EventBus events to let quest/NPC systems react
		EventBus.event_triggered.emit("item_added_" + item_id)

func remove_item(item_id: String) -> bool:
	if items.has(item_id):
		items.erase(item_id)
		print("InventoryManager: Removed item '", item_id, "'")
		EventBus.event_triggered.emit("item_removed_" + item_id)
		return true
	return false

func has_item(item_id: String) -> bool:
	return items.has(item_id)

# ==========================================
# SAVEABLE CONVENTION
# ==========================================
func get_save_data() -> Dictionary:
	return { "items": items }

func load_save_data(data: Dictionary):
	items.clear()
	if data.has("items"):
		for item in data["items"]:
			items.append(String(item))
	print("InventoryManager: Save state loaded successfully. Total items: ", items.size())
