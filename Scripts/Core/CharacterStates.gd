class_name CharacterStates
extends RefCounted

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
		return Vector2.ZERO

# ==========================================
# WALK STATE
# ==========================================
class WalkState extends CharacterState:
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
