extends Camera2D

@export var target: Node2D = null
@export var lerp_speed: float = 6.0
@export var use_limits: bool = false
@export var limit_bounds: Rect2 = Rect2(-10000, -10000, 20000, 20000):
	set(value):
		limit_bounds = value
		if is_inside_tree() and use_limits:
			_apply_camera_limits(limit_bounds)

# Zoom and Vignette variables
var vignette_material: ShaderMaterial = null
var current_vignette_opacity: float = 0.0
var current_dim_opacity: float = 0.0
var target_vignette_opacity: float = 0.0
var target_dim_opacity: float = 0.0

var zoom_human: Vector2 = Vector2(1.8, 1.8)
var zoom_cat: Vector2 = Vector2(2.6, 2.6)
var target_zoom: Vector2 = Vector2(1.8, 1.8)

func _ready():
	# Make sure limits are applied on initialization if enabled
	if use_limits:
		_apply_camera_limits(limit_bounds)
	else:
		clear_camera_limits()
		
	# Setup vignette screen overlay dynamically
	_setup_vignette()
	
	# Listen for active character changes
	GameManager.active_character_changed.connect(_on_active_character_changed)
	
	# Initialize camera values if a character is already active
	if GameManager.active_character:
		_on_active_character_changed(GameManager.active_character)

func _physics_process(delta):
	# Follow target node smoothly using linear interpolation
	if is_instance_valid(target):
		global_position = global_position.lerp(target.global_position, lerp_speed * delta)
	
	# Smoothly interpolate zoom
	zoom = zoom.lerp(target_zoom, lerp_speed * delta)
	
	# Smoothly interpolate vignette and dimming parameters
	if vignette_material:
		current_vignette_opacity = lerp(current_vignette_opacity, target_vignette_opacity, lerp_speed * delta)
		current_dim_opacity = lerp(current_dim_opacity, target_dim_opacity, lerp_speed * delta)
		vignette_material.set_shader_parameter("vignette_opacity", current_vignette_opacity)
		vignette_material.set_shader_parameter("dim_opacity", current_dim_opacity)

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

func _setup_vignette():
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 # Draw over standard UI
	add_child(canvas_layer)
	
	var color_rect = ColorRect.new()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(color_rect)
	
	var shader = Shader.new()
	shader.code = """
	shader_type canvas_item;
	uniform float vignette_intensity : hint_range(0.0, 2.0) = 0.5;
	uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.0;
	uniform float dim_opacity : hint_range(0.0, 1.0) = 0.0;
	void fragment() {
		vec2 uv = UV - vec2(0.5);
		float dist = length(uv);
		float vignette = smoothstep(0.2, 0.8, dist) * vignette_opacity;
		float mask = max(vignette, dim_opacity);
		COLOR = vec4(0.0, 0.0, 0.0, mask);
	}
	"""
	
	vignette_material = ShaderMaterial.new()
	vignette_material.shader = shader
	color_rect.material = vignette_material

func _on_active_character_changed(character: CharacterBody2D):
	if character and character.get("is_human") == false:
		# Cat active: close zoom, dark vignette + dim screen
		target_zoom = zoom_cat
		target_vignette_opacity = 0.7
		target_dim_opacity = 0.25
	else:
		# Human active: standard closer zoom, no vignette/dimming
		target_zoom = zoom_human
		target_vignette_opacity = 0.0
		target_dim_opacity = 0.0
