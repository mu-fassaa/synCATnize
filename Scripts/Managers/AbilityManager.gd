extends Node

enum AbilityState { LOCKED, UNLOCKED, DISABLED }

# Stores abilities dynamically: character_type (int) -> { ability_id (String) -> state (AbilityState) }
var abilities: Dictionary = {
	GameManager.CharacterType.HUMAN: {},
	GameManager.CharacterType.CAT: {}
}

func _ready():
	add_to_group("saveable")

func unlock_ability(character_type: int, ability_id: String):
	_set_ability_state(character_type, ability_id, AbilityState.UNLOCKED)
	print("AbilityManager: Unlocked ability '", ability_id, "' for character type ", character_type)

func lock_ability(character_type: int, ability_id: String):
	_set_ability_state(character_type, ability_id, AbilityState.LOCKED)
	print("AbilityManager: Locked ability '", ability_id, "' for character type ", character_type)

func disable_ability(character_type: int, ability_id: String):
	_set_ability_state(character_type, ability_id, AbilityState.DISABLED)
	print("AbilityManager: Disabled ability '", ability_id, "' for character type ", character_type)

func is_ability_unlocked(character_type: int, ability_id: String) -> bool:
	if abilities.has(character_type) and abilities[character_type].has(ability_id):
		return abilities[character_type][ability_id] == AbilityState.UNLOCKED
	return false

func get_ability_state(character_type: int, ability_id: String) -> int:
	if abilities.has(character_type) and abilities[character_type].has(ability_id):
		return abilities[character_type][ability_id]
	return AbilityState.LOCKED

func _set_ability_state(character_type: int, ability_id: String, state: int):
	if not abilities.has(character_type):
		abilities[character_type] = {}
	abilities[character_type][ability_id] = state
	EventBus.ability_state_changed.emit(character_type, ability_id, state)

# ==========================================
# SAVEABLE CONVENTION
# ==========================================
func get_save_data() -> Dictionary:
	# Convert enum keys in dictionaries to string keys so JSON serialization is robust
	var data: Dictionary = {}
	for char_type in abilities:
		var type_str = str(char_type)
		data[type_str] = {}
		for ab_id in abilities[char_type]:
			data[type_str][ab_id] = abilities[char_type][ab_id]
	return data

func load_save_data(data: Dictionary):
	abilities.clear()
	for type_str in data:
		var char_type = type_str.to_int()
		abilities[char_type] = {}
		for ab_id in data[type_str]:
			abilities[char_type][ab_id] = int(data[type_str][ab_id])
	print("AbilityManager: Save state loaded successfully.")
