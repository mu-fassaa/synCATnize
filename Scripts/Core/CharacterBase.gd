extends CharacterBody2D

signal interaction_target_changed(interactable: Area2D)
signal state_changed(new_state: CharacterState)

enum CharacterState { IDLE, WALK, RUN, INTERACT, DISABLED }

@export_category("Movement Settings")
@export var speed: float = 150.0
@export var run_speed: float = 220.0 # Not too fast, normal is 150.0
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0

var is_human: bool = false
var speed_modifier: float = 1.0

var current_state: CharacterState = CharacterState.IDLE:
	set(value):
		if current_state != value:
			current_state = value
			state_changed.emit(current_state)

var is_active: bool:
	get:
		return GameManager.active_character == self

var current_interactables: Array[Area2D] = []
var nearest_interactable: Area2D = null:
	set(value):
		if nearest_interactable != value:
			nearest_interactable = value
			interaction_target_changed.emit(nearest_interactable)

func _ready():
	var detector = get_node_or_null("InteractionDetector")
	if detector and detector is Area2D:
		detector.area_entered.connect(_on_interaction_area_entered)
		detector.area_exited.connect(_on_interaction_area_exited)

func _physics_process(delta):
	var input_dir = Vector2.ZERO
	var target_speed = 0.0
	
	# Only allow input if the state is IDLE, WALK, or RUN
	if current_state != CharacterState.DISABLED and current_state != CharacterState.INTERACT:
		if is_active:
			input_dir = InputManager.get_movement_vector()
			
		if input_dir != Vector2.ZERO:
			# If shift is pressed, transition to RUN state
			if Input.is_key_pressed(KEY_SHIFT):
				current_state = CharacterState.RUN
				target_speed = run_speed
			else:
				current_state = CharacterState.WALK
				target_speed = speed
			_play_walk_animation(input_dir)
		else:
			current_state = CharacterState.IDLE
			target_speed = 0.0
			_play_idle_animation()
	else:
		# If DISABLED or INTERACT, decelerate to zero
		target_speed = 0.0
		_play_idle_animation()
		
	# Move character towards target speed
	if input_dir != Vector2.ZERO and current_state != CharacterState.DISABLED and current_state != CharacterState.INTERACT:
		velocity = velocity.move_toward(input_dir * target_speed * speed_modifier, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
	
	if is_active:
		_update_nearest_interactable()

func _input(event):
	# Block interaction inputs if character is disabled or already interacting
	if current_state == CharacterState.DISABLED or current_state == CharacterState.INTERACT:
		return
		
	if is_active and InputManager.is_interact_just_pressed():
		_trigger_interaction()

func _play_walk_animation(_direction: Vector2):
	pass

func _play_idle_animation():
	pass

func _update_nearest_interactable():
	if current_interactables.is_empty():
		nearest_interactable = null
		return
		
	var closest: Area2D = null
	var min_dist: float = INF
	
	for area in current_interactables:
		if is_instance_valid(area):
			var dist = global_position.distance_to(area.global_position)
			if dist < min_dist:
				min_dist = dist
				closest = area
				
	nearest_interactable = closest

func _trigger_interaction():
	_update_nearest_interactable()
	if nearest_interactable and nearest_interactable.has_method("interact"):
		current_state = CharacterState.INTERACT
		nearest_interactable.interact(self)
		
		# Return to IDLE state after a brief delay
		get_tree().create_timer(0.2).timeout.connect(func():
			if current_state == CharacterState.INTERACT:
				current_state = CharacterState.IDLE
		)

func _on_interaction_area_entered(area: Area2D):
	if area.has_method("interact") and not current_interactables.has(area):
		current_interactables.append(area)

func _on_interaction_area_exited(area: Area2D):
	if area.has_method("interact"):
		current_interactables.erase(area)
		if nearest_interactable == area:
			_update_nearest_interactable()
