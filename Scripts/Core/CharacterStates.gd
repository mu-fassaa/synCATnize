class_name CharacterStates
extends RefCounted

static func _is_in_active_puzzle_area(tree: SceneTree) -> bool:
	if not is_instance_valid(tree):
		return false
	var puzzles = tree.get_nodes_in_group("puzzles")
	for p in puzzles:
		if "is_completed" in p and not p.is_completed:
			return true
	return false

# ==========================================
# IDLE STATE
# ==========================================
class IdleState extends CharacterState:
	func enter():
		character._play_idle_animation()
		
	func physics_update(_delta: float) -> Vector2:
		if character.is_active:
			var input_dir = InputManager.get_movement_vector()
			if input_dir != Vector2.ZERO:
				if Input.is_key_pressed(KEY_SHIFT):
					character.change_state_by_enum(2) # RUN
				else:
					character.change_state_by_enum(1) # WALK
				return input_dir # Triggers direction update
		else:
			# Inactive Cat follows active Human if not in a puzzle area
			if not character.is_human and GameManager.active_character and GameManager.active_character.get("is_human") == true:
				if not GameManager.is_follow_disabled and not CharacterStates._is_in_active_puzzle_area(character.get_tree()):
					var target_pos = GameManager.active_character.global_position
					var dist = character.global_position.distance_to(target_pos)
					if dist > 85.0:
						character.change_state_by_enum(1) # WALK
		return Vector2.ZERO

# ==========================================
# WALK STATE
# ==========================================
class WalkState extends CharacterState:
	func enter():
		pass
		
	func physics_update(_delta: float) -> Vector2:
		if not character.is_active:
			# Inactive Cat follows active Human if not in a puzzle area
			if not character.is_human and GameManager.active_character and GameManager.active_character.get("is_human") == true:
				if not GameManager.is_follow_disabled and not CharacterStates._is_in_active_puzzle_area(character.get_tree()):
					var target_pos = GameManager.active_character.global_position
					var dist = character.global_position.distance_to(target_pos)
					if dist <= 55.0:
						character.change_state_by_enum(0) # IDLE
						return Vector2.ZERO
					
					var dir = (target_pos - character.global_position).normalized()
					character._play_walk_animation(dir)
					return dir * character.speed
					
			character.change_state_by_enum(0) # IDLE
			return Vector2.ZERO
			
		var input_dir = InputManager.get_movement_vector()
		if input_dir == Vector2.ZERO:
			character.change_state_by_enum(0) # IDLE
			return Vector2.ZERO
			
		if Input.is_key_pressed(KEY_SHIFT):
			character.change_state_by_enum(2) # RUN
			
		character._play_walk_animation(input_dir)
		return input_dir * character.speed

# ==========================================
# RUN STATE
# ==========================================
class RunState extends CharacterState:
	func enter():
		pass
		
	func physics_update(_delta: float) -> Vector2:
		if not character.is_active:
			character.change_state_by_enum(0) # IDLE
			return Vector2.ZERO
			
		var input_dir = InputManager.get_movement_vector()
		if input_dir == Vector2.ZERO:
			character.change_state_by_enum(0) # IDLE
			return Vector2.ZERO
			
		if not Input.is_key_pressed(KEY_SHIFT):
			character.change_state_by_enum(1) # WALK
			
		character._play_walk_animation(input_dir)
		return input_dir * character.run_speed

# ==========================================
# INTERACT STATE
# ==========================================
class InteractState extends CharacterState:
	func enter():
		character._play_idle_animation()
		
	func physics_update(_delta: float) -> Vector2:
		return Vector2.ZERO

# ==========================================
# DISABLED STATE
# ==========================================
class DisabledState extends CharacterState:
	func enter():
		character._play_idle_animation()
		
	func physics_update(_delta: float) -> Vector2:
		return Vector2.ZERO
