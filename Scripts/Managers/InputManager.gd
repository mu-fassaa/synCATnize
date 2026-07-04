extends Node

signal input_lock_changed(is_locked: bool)

var _input_locked: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func set_input_locked(locked: bool):
	_input_locked = locked
	input_lock_changed.emit(_input_locked)

func is_input_locked() -> bool:
	return _input_locked

# Wrapper to read raw directional input (WASD / Arrows)
func get_movement_vector() -> Vector2:
	if _input_locked or get_tree().paused:
		return Vector2.ZERO
		
	var input_vector = Vector2.ZERO
	# Use standard fallback keyboard checks or InputMap actions
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1
		
	return input_vector.normalized()

# Wrapper to check if interaction action is triggered (E key)
func is_interact_just_pressed() -> bool:
	if _input_locked or get_tree().paused:
		return false
	return Input.is_action_just_pressed("interact") or Input.is_key_pressed(KEY_E)

# Wrapper to check if jump action is triggered (Space key)
func is_jump_just_pressed() -> bool:
	if _input_locked or get_tree().paused:
		return false
	return Input.is_action_just_pressed("jump") or Input.is_key_pressed(KEY_SPACE)

func rebind_key(action_name: String, new_event: InputEvent):
	# Placeholder for future keyboard remapping implementation
	print("InputManager: Rebinding stub for action: ", action_name)
