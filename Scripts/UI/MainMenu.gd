extends Control

@onready var start_button = $VBoxContainer/Buttons/StartButton
@onready var load_button = $VBoxContainer/Buttons/LoadButton
@onready var exit_button = $VBoxContainer/Buttons/ExitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	load_button.pressed.connect(_on_load_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Disable load button if no save file exists
	if SaveManager.active_save_data.is_empty():
		load_button.disabled = true
		load_button.self_modulate = Color(0.5, 0.5, 0.5, 0.6) # Dim it

func _on_start_pressed():
	print("MainMenu: Starting new game.")
	SceneManager.transition_to_scene_by_id("player_house")

func _on_load_pressed():
	print("MainMenu: Loading saved game.")
	# Load state and transition
	SceneManager.transition_to_scene_by_id("player_house")
	
	# After scene loaded, trigger load_game
	SceneManager.scene_transition_finished.connect(func(_path):
		SaveManager.load_game()
	, CONNECT_ONE_SHOT)

func _on_exit_pressed():
	print("MainMenu: Exiting game.")
	get_tree().quit()
