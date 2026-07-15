extends Node

var active_save_data: Dictionary = {}

# CamelCase wrappers to match requirement specifications
func Save():
	save_game()

func Load():
	load_game()

func Reset():
	reset_game()

# Clean, standard GDScript snake_case implementations
func save_game():
	active_save_data.clear()
	var saveables = get_tree().get_nodes_in_group("saveable")
	
	for node in saveables:
		if is_instance_valid(node):
			var save_key = _get_save_key(node)
			if node.has_method("get_save_data"):
				var node_data = node.get_save_data()
				active_save_data[save_key] = node_data
				print("SaveManager: Saved state for ", save_key, " -> ", node_data)
				
	print("SaveManager: Game state saved successfully. Total items: ", active_save_data.size())

func load_game():
	if active_save_data.is_empty():
		print("SaveManager: No save data found to load.")
		return
		
	var saveables = get_tree().get_nodes_in_group("saveable")
	for node in saveables:
		if is_instance_valid(node):
			var save_key = _get_save_key(node)
			if active_save_data.has(save_key) and node.has_method("load_save_data"):
				node.load_save_data(active_save_data[save_key])
				print("SaveManager: Loaded state for ", save_key)
				
	print("SaveManager: Game state loaded successfully.")

func reset_game():
	active_save_data.clear()
	print("SaveManager: Reset game save data.")

func _get_save_key(node: Node) -> String:
	# Create a unique key relative to the current scene root to support multi-scene states
	var root = get_tree().current_scene
	if root and root.is_ancestor_of(node):
		return root.name + "/" + String(root.get_path_to(node))
	return node.name + "_" + str(node.get_instance_id())
