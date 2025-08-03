class_name EnhancedCameraSystem
extends Node

## Enhanced Camera System - Event-driven camera management with strategies
## Maintains the exact same camera behavior as the original system

signal camera_mode_changed(mode_name: String)

@export_group("Camera References")
@export var spring_arm_path: NodePath = "../CameraPivot/SpringArm3D"
@export var camera_path: NodePath = "../CameraPivot/SpringArm3D/Camera3D"
@export var player_path: NodePath = ".."

@export_group("Camera Settings")
@export var default_mode: String = "third_person"
@export var pitch_limit_up: float = 30.0:
	set(value):
		pitch_limit_up = clamp(value, 0.0, 89.0)
@export var pitch_limit_down: float = 60.0:
	set(value):
		pitch_limit_down = clamp(value, 0.0, 89.0)
@export var sensitivity: float = 2.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 10.0
@export var smoothing: float = 10.0

@export_group("Third Person Settings")
@export var third_person_distance: float = 5.0
@export var third_person_height: float = 1.5
@export var third_person_side_offset: float = 0.0
@export var position_smoothing: float = 10.0
@export var strafe_mode_enabled: bool = false
@export var strafe_tilt_amount: float = 5.0
@export var strafe_smoothing: float = 10.0

@export_group("First Person Settings")
@export var first_person_height: float = 1.7
@export var first_person_fov: float = 90.0

@export_group("Transition Settings")
@export var transition_duration: float = 0.3:
	set(value):
		transition_duration = max(value, 0.1)
@export var transition_curve: Curve

var _spring_arm: SpringArm3D
var _camera: Camera3D
var _player: CharacterBody3D
var _input_system: Node

var _current_strategy: CameraStrategyBase
var _strategies: Dictionary = {}

# Camera rotation variables (same as original)
var _accumulated_pitch: float = 0.0

# Transition variables
var _is_transitioning: bool = false
var _transition_time: float = 0.0
var _transition_start_fov: float
var _transition_target_fov: float
var _transition_start_spring_length: float
var _transition_target_spring_length: float

func initialize(player: CharacterBody3D, input_system: Node = null) -> void:
	_player = player
	_input_system = input_system
	
	# Get references - try multiple paths since the scene structure might vary
	_spring_arm = get_node_or_null(spring_arm_path) as SpringArm3D
	if not _spring_arm:
		# Try alternative paths
		_spring_arm = get_node_or_null("../CameraPivot/SpringArm3D") as SpringArm3D
		if not _spring_arm:
			_spring_arm = get_node_or_null("../../CameraPivot/SpringArm3D") as SpringArm3D
	
	_camera = get_node_or_null(camera_path) as Camera3D
	if not _camera:
		# Try alternative paths
		_camera = get_node_or_null("../CameraPivot/SpringArm3D/Camera3D") as Camera3D
		if not _camera:
			_camera = get_node_or_null("../../CameraPivot/SpringArm3D/Camera3D") as Camera3D
	
	if not _spring_arm:
		push_error("SpringArm3D not found. Tried paths: " + str(spring_arm_path) + ", ../CameraPivot/SpringArm3D, ../../CameraPivot/SpringArm3D")
		return
	if not _camera:
		push_error("Camera3D not found. Tried paths: " + str(camera_path) + ", ../CameraPivot/SpringArm3D/Camera3D, ../../CameraPivot/SpringArm3D/Camera3D")
		return
	
	_setup_strategies()
	_connect_events()
	
	# Set default camera mode
	set_camera_mode(default_mode, false)

func _setup_strategies() -> void:
	# Create camera strategies (we'll load them manually for now)
	var first_person = preload("res://addons/player_controller/strategies/camera/first_person_strategy.gd").new()
	var third_person = preload("res://addons/player_controller/strategies/camera/third_person_strategy.gd").new()
	
	_strategies["first_person"] = first_person
	_strategies["third_person"] = third_person
	
	# Initialize all strategies
	for strategy in _strategies.values():
		strategy.initialize(_spring_arm, _camera, _player)
		# Apply configurable parameters
		strategy.sensitivity = sensitivity
		strategy.zoom_speed = zoom_speed
		strategy.min_zoom = min_zoom
		strategy.max_zoom = max_zoom
		strategy.smoothing = smoothing
		
		# Apply strategy-specific parameters
		if strategy.get_strategy_name() == "third_person":
			if strategy.has_method("set_distance"):
				strategy.set_distance(third_person_distance)
			if strategy.has_method("set_height"):
				strategy.set_height(third_person_height)
			if strategy.has_method("set_side_offset"):
				strategy.set_side_offset(third_person_side_offset)
			if strategy.has_method("set_strafe_mode"):
				strategy.set_strafe_mode(strafe_mode_enabled)
			if strategy.has_method("set_strafe_tilt_amount"):
				strategy.set_strafe_tilt_amount(strafe_tilt_amount)
			if strategy.has_method("set_strafe_smoothing"):
				strategy.set_strafe_smoothing(strafe_smoothing)
			if strategy.has_method("set_position_smoothing"):
				strategy.set_position_smoothing(position_smoothing)
		elif strategy.get_strategy_name() == "first_person":
			if strategy.has_method("set_height"):
				strategy.set_height(first_person_height)
			if strategy.has_method("set_fov"):
				strategy.set_fov(first_person_fov)

func _connect_events() -> void:
	# Connect to event bus if available
	if EnhancedEventBus.instance:
		if EnhancedEventBus.instance.has_signal("camera_mode_changed"):
			pass # We'll connect to input events when available

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if not _current_strategy or not _spring_arm or not _camera:
		return
	
	# Handle transition
	if _is_transitioning:
		_update_transition(delta)
	else:
		# Apply current camera strategy (same as original)
		_current_strategy.process(delta)
	
	# Update player model visibility
	_update_player_visibility(_current_strategy.requires_player_model_visibility())

func set_camera_mode(mode_name: String, use_transition: bool = true) -> void:
	if not _strategies.has(mode_name):
		push_error("Camera mode not found: " + mode_name)
		return
	
	var previous_strategy = _current_strategy
	var new_strategy = _strategies[mode_name]
	
	# Call deactivation on previous mode
	if previous_strategy:
		previous_strategy.on_exit()
	
	# Start transition if requested
	if use_transition and previous_strategy:
		_start_transition(previous_strategy, new_strategy)
	else:
		_current_strategy = new_strategy
		_current_strategy.on_enter()
	
	camera_mode_changed.emit(mode_name)

func _start_transition(from_strategy: CameraStrategyBase, to_strategy: CameraStrategyBase) -> void:
	if not _camera or not _spring_arm:
		_current_strategy = to_strategy
		_current_strategy.on_enter()
		return
	
	_is_transitioning = true
	_transition_time = 0.0
	
	# Store transition start values (same as original)
	_transition_start_fov = _camera.fov
	_transition_target_fov = 75.0 # Default FOV
	_transition_start_spring_length = _spring_arm.spring_length
	
	# Calculate target spring length
	if to_strategy.get_strategy_name() == "first_person":
		_transition_target_spring_length = 0.1
	else:
		_transition_target_spring_length = 5.0 # Default distance
	
	_current_strategy = to_strategy
	_current_strategy.on_enter()

func _update_transition(delta: float) -> void:
	_transition_time += delta
	var t = clamp(_transition_time / transition_duration, 0.0, 1.0)
	
	# Use curve if available, otherwise smoothstep (same as original)
	if transition_curve:
		t = transition_curve.sample(t)
	else:
		t = smoothstep(0.0, 1.0, t)
	
	# Interpolate FOV
	_camera.fov = lerp(_transition_start_fov, _transition_target_fov, t)
	
	# Interpolate spring length
	_spring_arm.spring_length = lerp(_transition_start_spring_length, _transition_target_spring_length, t)
	
	# Let the current strategy handle its own positioning during transition
	_current_strategy.process(delta)
	
	# End transition
	if t >= 1.0:
		_is_transitioning = false

func _update_player_visibility(visible: bool) -> void:
	# Find all MeshInstance3D nodes in the player controller hierarchy (same as original)
	if not _player:
		return
	
	_set_visibility_recursive(_player, visible)

func _set_visibility_recursive(node: Node, visible: bool) -> void:
	# Set visibility for MeshInstance3D nodes (same as original)
	if node is MeshInstance3D:
		node.visible = visible
	
	# Recursively check all children
	for child in node.get_children():
		_set_visibility_recursive(child, visible)

func handle_camera_input(mouse_delta: Vector2) -> void:
	# Delegate input handling to current strategy
	if _current_strategy:
		_current_strategy.handle_input(mouse_delta, get_physics_process_delta_time())
	
	# Add null check before calling get_parent()
	if not _spring_arm:
		return
		
	var camera_pivot = _spring_arm.get_parent()
	if not camera_pivot:
		return
	
	# Check if current mode is in strafe mode
	var is_strafe_mode = false
	if _current_strategy and _current_strategy.has_method("is_strafe_mode_enabled"):
		is_strafe_mode = _current_strategy.is_strafe_mode_enabled()
	
	# Apply horizontal rotation (yaw) to the player (same as original)
	if _player:
		_player.rotation.y -= mouse_delta.x
	
	# Apply vertical rotation (pitch) to the camera pivot with limits (same as original)
	_accumulated_pitch += mouse_delta.y
	var pitch_limit_up_rad = deg_to_rad(-pitch_limit_up)
	var pitch_limit_down_rad = deg_to_rad(pitch_limit_down)
	_accumulated_pitch = clamp(_accumulated_pitch, pitch_limit_up_rad, pitch_limit_down_rad)
	camera_pivot.rotation.x = _accumulated_pitch

func handle_zoom_input(zoom_direction: float) -> void:
	# Delegate zoom handling to current strategy
	if _current_strategy:
		_current_strategy.handle_zoom(zoom_direction)

func toggle_camera_mode() -> void:
	# Toggle between first and third person (same as original)
	var current_mode_name = get_current_mode_name()
	var new_mode = "first_person" if current_mode_name == "third_person" else "third_person"
	set_camera_mode(new_mode, true)

func toggle_strafe_mode() -> void:
	# Toggle strafe mode for third person camera (same as original)
	if _current_strategy and _current_strategy.has_method("set_strafe_mode"):
		var current_strafe_state = false
		if _current_strategy.has_method("is_strafe_mode_enabled"):
			current_strafe_state = _current_strategy.is_strafe_mode_enabled()
		_current_strategy.set_strafe_mode(not current_strafe_state)

func handle_strafe_input(input_direction: Vector2) -> void:
	# Pass movement input to current strategy for strafe handling (same as original)
	if _current_strategy and _current_strategy.has_method("handle_strafe_input"):
		_current_strategy.handle_strafe_input(input_direction)

func get_current_mode_name() -> String:
	for mode_name in _strategies:
		if _strategies[mode_name] == _current_strategy:
			return mode_name
	return default_mode

func get_current_strategy() -> CameraStrategyBase:
	return _current_strategy

# Legacy compatibility methods
func get_camera() -> Camera3D:
	return _camera

func get_forward_direction() -> Vector3:
	if _camera:
		return -_camera.global_basis.z.normalized()
	return Vector3.FORWARD

func get_right_direction() -> Vector3:
	if _camera:
		return _camera.global_basis.x.normalized()
	return Vector3.RIGHT
