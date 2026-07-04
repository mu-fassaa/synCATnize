extends Camera2D


@export var target: Node2D = null
@export var lerp_speed: float = 6.0
@export var use_limits: bool = false
@export var limit_bounds: Rect2 = Rect2(-10000, -10000, 20000, 20000):
	set(value):
		limit_bounds = value
		if is_inside_tree() and use_limits:
			_apply_camera_limits(limit_bounds)

func _ready():
	# Make sure limits are applied on initialization if enabled
	if use_limits:
		_apply_camera_limits(limit_bounds)
	else:
		clear_camera_limits()

func _physics_process(delta):
	# Follow target node smoothly using linear interpolation
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, lerp_speed * delta)

func set_target(new_target: Node2D):
	target = new_target

func set_camera_limits(bounds: Rect2):
	use_limits = true
	limit_bounds = bounds

func clear_camera_limits():
	use_limits = false
	limit_left = -10000000
	limit_top = -10000000
	limit_right = 10000000
	limit_bottom = 10000000

func _apply_camera_limits(bounds: Rect2):
	limit_left = int(bounds.position.x)
	limit_top = int(bounds.position.y)
	limit_right = int(bounds.position.x + bounds.size.x)
	limit_bottom = int(bounds.position.y + bounds.size.y)
