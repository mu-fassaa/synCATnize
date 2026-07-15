extends CharacterBody2D

signal interaction_target_changed(interactable: Area2D)
signal state_changed(new_state: CharacterStateEnum)

enum CharacterStateEnum { IDLE, WALK, RUN, INTERACT, DISABLED }

@export_category("Movement Settings")
@export var speed: float = 150.0
@export var run_speed: float = 220.0 # Not too fast, normal is 150.0
@export var acceleration: float = 1200.0
@export var friction: float = 1400.0

var is_human: bool = false
var speed_modifier: float = 1.0

var current_state: CharacterStateEnum = CharacterStateEnum.IDLE:
	set(value):
		if current_state != value:
			current_state = value
			state_changed.emit(current_state)
			EventBus.character_state_changed.emit(self, current_state)

var state_handlers: Dictionary = {}
var current_state_handler: CharacterState = null

var is_active: bool:
	get:
		return GameManager.active_character == self

var current_interactables: Array[Area2D] = []
var nearest_interactable: Area2D = null:
	set(value):
		if nearest_interactable != value:
			nearest_interactable = value
			interaction_target_changed.emit(nearest_interactable)
			EventBus.interaction_target_changed.emit(self, nearest_interactable)

func _ready():
	# Initialize state handlers programmatically
	state_handlers[CharacterStateEnum.IDLE] = CharacterStates.IdleState.new()
	state_handlers[CharacterStateEnum.WALK] = CharacterStates.WalkState.new()
	state_handlers[CharacterStateEnum.RUN] = CharacterStates.RunState.new()
	state_handlers[CharacterStateEnum.INTERACT] = CharacterStates.InteractState.new()
	state_handlers[CharacterStateEnum.DISABLED] = CharacterStates.DisabledState.new()
	
	for state in state_handlers.values():
		state.character = self
		
	current_state_handler = state_handlers[CharacterStateEnum.IDLE]
	current_state_handler.enter()

	var detector = get_node_or_null("InteractionDetector")
	if detector and detector is Area2D:
		detector.area_entered.connect(_on_interaction_area_entered)
		detector.area_exited.connect(_on_interaction_area_exited)

func _physics_process(delta):
	var target_velocity = Vector2.ZERO
	if current_state_handler:
		target_velocity = current_state_handler.physics_update(delta)
		
	# Move character towards target velocity (with speed_modifier for slow environments)
	if target_velocity != Vector2.ZERO:
		velocity = velocity.move_toward(target_velocity * speed_modifier, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
	
	if is_active:
		_update_nearest_interactable()

func _input(event):
	if current_state_handler:
		current_state_handler.handle_input(event)
		
	# Block interaction inputs if character is disabled or already interacting
	if current_state == CharacterStateEnum.DISABLED or current_state == CharacterStateEnum.INTERACT:
		return
		
	if is_active and InputManager.is_interact_just_pressed():
		_trigger_interaction()

func change_state_by_enum(new_state_enum: int):
	if state_handlers.has(new_state_enum):
		if current_state_handler:
			current_state_handler.exit()
		current_state = new_state_enum
		current_state_handler = state_handlers[new_state_enum]
		current_state_handler.enter()

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
		change_state_by_enum(CharacterStateEnum.INTERACT)
		nearest_interactable.interact(self)
		
		# Return to IDLE state after a brief delay
		get_tree().create_timer(0.2).timeout.connect(func():
			if current_state == CharacterStateEnum.INTERACT:
				change_state_by_enum(CharacterStateEnum.IDLE)
		)

func _on_interaction_area_entered(area: Area2D):
	if area.has_method("interact") and not current_interactables.has(area):
		current_interactables.append(area)

func _on_interaction_area_exited(area: Area2D):
	if area.has_method("interact"):
		current_interactables.erase(area)
		if nearest_interactable == area:
			_update_nearest_interactable()
