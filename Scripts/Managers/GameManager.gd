extends Node

signal game_paused(paused: bool)
signal active_character_changed(character: CharacterBody2D)

enum CharacterType { HUMAN, CAT }
enum GameplayState { EXPLORATION, DIALOGUE, PUZZLE, CUTSCENE, TRANSITION, PAUSE, LOADING }

var is_paused: bool = false:
	set(value):
		is_paused = value
		get_tree().paused = is_paused
		game_paused.emit(is_paused)
		if is_paused:
			current_gameplay_state = GameplayState.PAUSE
		else:
			current_gameplay_state = GameplayState.EXPLORATION

var current_gameplay_state: GameplayState = GameplayState.EXPLORATION:
	set(value):
		if current_gameplay_state != value:
			current_gameplay_state = value
			EventBus.gameplay_state_changed.emit(current_gameplay_state)

var active_character: CharacterBody2D = null:
	set(value):
		active_character = value
		active_character_changed.emit(active_character)
		EventBus.character_switched.emit(active_character)

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS # Keep running when tree is paused

func toggle_pause():
	is_paused = not is_paused

func save_game():
	# Placeholder for future save implementation
	print("GameManager: Save system trigger stub.")

func load_game():
	# Placeholder for future load implementation
	print("GameManager: Load system trigger stub.")
