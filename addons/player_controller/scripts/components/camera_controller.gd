@tool
class_name CameraController
extends Node

## Camera Controller Component - Single Responsibility: Handle camera behavior and mode switching
## Uses SpringArm3D for positioning and collision detection

signal camera_mode_changed(mode_name: String)

@export var spring_arm_path: NodePath = "../../CameraPivot/SpringArm3D"
@export var camera_path: NodePath = "../../CameraPivot/SpringArm3D/Camera3D"
@export var player_controller_path: NodePath = "../.."
@export var input_handler_path: NodePath = "../InputHandler"
@export var default_mode: String = "third_person"

@export_group("Camera Modes")
@export var first_person_mode: FirstPersonMode
@export var third_person_mode: ThirdPersonMode

@export_group("Camera Settings")
@export var pitch_limit_up: float = 30.0:
	set(value):
		pitch_limit_up = clamp(value, 0.0, 89.0)
@export var pitch_limit_down: float = 60.0:
	set(value):
		pitch_limit_down = clamp(value, 0.0, 89.0)

@export_group("Transition Settings")
@export var transition_duration: float = 0.3:
	set(value):
		transition_duration = max(value, 0.1)
@export var transition_curve: Curve

var _spring_arm: SpringArm3D
var _camera: Camera3D
var _player_controller: CharacterBody3D
var _input_handler: InputHandler
var _current_mode: CameraStrategy
var _modes: Dictionary = {}

# Camera rotation variables
var _accumulated_pitch: float = 0.0 # Store accumulated pitch rotation

# Transition variables
var _is_transitioning: bool = false
var _transition_time: float = 0.0
var _transition_start_fov: float
var _transition_target_fov: float
var _transition_start_position: Vector3
var _transition_start_spring_length: float
var _transition_target_spring_length: float

func _ready() -> void:
	# Get references with fallback options
	_spring_arm = _find_node_by_path_or_type(spring_arm_path, "SpringArm3D") as SpringArm3D
	_camera = _find_node_by_path_or_type(camera_path, "Camera3D") as Camera3D
	_player_controller = _find_node_by_path_or_type(player_controller_path, "CharacterBody3D") as CharacterBody3D
	_input_handler = _find_node_by_path_or_type(input_handler_path, "InputHandler") as InputHandler
	
	# Validate references
	if not _spring_arm:
		push_error("SpringArm3D not found. Please check the spring_arm_path or ensure a SpringArm3D exists in the scene.")
		return
	if not _camera:
		push_error("Camera3D not found. Please check the camera_path or ensure a Camera3D exists in the scene.")
		return
	if not _input_handler:
		push_error("InputHandler not found. Please check the input_handler_path or ensure an InputHandler exists in the scene.")
		return
	
	# Initialize modes
	if not first_person_mode:
		first_person_mode = FirstPersonMode.new()
	if not third_person_mode:
		third_person_mode = ThirdPersonMode.new()
	
	_modes["first_person"] = first_person_mode
	_modes["third_person"] = third_person_mode
	
	# Validate default mode exists
	if not _modes.has(default_mode):
		push_warning("Default camera mode '%s' not found, falling back to 'third_person'" % default_mode)
		default_mode = "third_person"
	
	# Set default mode
	_set_camera_mode(default_mode, false) # No transition on start
	
	# Connect to input handler
	if _input_handler:
		_input_handler.camera_mode_toggle_requested.connect(_toggle_camera_mode)
		_input_handler.camera_input.connect(_handle_camera_input)
		_input_handler.zoom_requested.connect(_handle_zoom_input)
		_input_handler.strafe_mode_toggle_requested.connect(_toggle_strafe_mode)
		_input_handler.movement_input_changed.connect(_handle_movement_input)

func _physics_process(delta: float) -> void:
	if not _current_mode or not _spring_arm or not _camera:
		return
	
	# Handle transition
	if _is_transitioning:
		_update_transition(delta)
	else:
		# Apply current camera mode
		_current_mode.apply_to_spring_arm(_spring_arm, delta)
		_camera.fov = _current_mode.get_fov()
	
	# Update player visibility
	_update_player_visibility(_current_mode.requires_player_model_visibility())

func _toggle_camera_mode() -> void:
	var new_mode = "first_person" if _current_mode == _modes["third_person"] else "third_person"
	_set_camera_mode(new_mode, true)

func _set_camera_mode(mode_name: String, use_transition: bool = true) -> void:
	if not _modes.has(mode_name):
		push_error("Camera mode not found: " + mode_name)
		return
	
	var previous_mode = _current_mode
	var new_mode = _modes[mode_name]
	
	# Call deactivation on previous mode
	if previous_mode:
		previous_mode.on_mode_deactivated(_spring_arm)
	
	# Start transition if requested
	if use_transition and previous_mode:
		_start_transition(previous_mode, new_mode)
	else:
		_current_mode = new_mode
		_current_mode.on_mode_activated(_spring_arm)
	
	camera_mode_changed.emit(mode_name)

func _start_transition(from_mode: CameraStrategy, to_mode: CameraStrategy) -> void:
	if not _camera or not _spring_arm:
		push_error("Cannot start camera transition: missing camera or spring arm references")
		_current_mode = to_mode
		_current_mode.on_mode_activated(_spring_arm)
		return
	
	_is_transitioning = true
	_transition_time = 0.0
	
	# Store transition start values
	_transition_start_fov = _camera.fov
	_transition_target_fov = to_mode.get_fov()
	_transition_start_position = _spring_arm.position
	_transition_start_spring_length = _spring_arm.spring_length
	
	# Calculate target spring length
	if to_mode == _modes["first_person"]:
		_transition_target_spring_length = 0.0
	else:
		_transition_target_spring_length = third_person_mode.camera_distance
	
	_current_mode = to_mode
	_current_mode.on_mode_activated(_spring_arm)

func _update_transition(delta: float) -> void:
	_transition_time += delta
	var t = clamp(_transition_time / transition_duration, 0.0, 1.0)
	
	# Use curve if available, otherwise smoothstep
	if transition_curve:
		t = transition_curve.sample(t)
	else:
		t = smoothstep(0.0, 1.0, t)
	
	# Interpolate FOV
	_camera.fov = lerp(_transition_start_fov, _transition_target_fov, t)
	
	# Interpolate spring length
	_spring_arm.spring_length = lerp(_transition_start_spring_length, _transition_target_spring_length, t)
	
	# Let the current mode handle its own positioning during transition
	_current_mode.apply_to_spring_arm(_spring_arm, delta)
	
	# End transition
	if t >= 1.0:
		_is_transitioning = false

func _update_player_visibility(visible: bool) -> void:
	# Find all MeshInstance3D nodes in the player controller hierarchy
	if not _player_controller:
		push_warning("Player controller not available for visibility update")
		return
	
	_set_visibility_recursive(_player_controller, visible)

func _set_visibility_recursive(node: Node, visible: bool) -> void:
	# Set visibility for MeshInstance3D nodes
	if node is MeshInstance3D:
		node.visible = visible
	
	# Recursively check all children
	for child in node.get_children():
		_set_visibility_recursive(child, visible)

func get_current_mode_name() -> String:
	for mode_name in _modes:
		if _modes[mode_name] == _current_mode:
			return mode_name
	return ""

func get_current_mode() -> CameraStrategy:
	"""Get the current camera mode"""
	return _current_mode

func set_camera_mode(mode_name: String) -> void:
	_set_camera_mode(mode_name, true)

func handle_strafe_input(input_direction: Vector2) -> void:
	"""Pass movement input to current mode for strafe handling"""
	if _current_mode and _current_mode.has_method("handle_strafe_input"):
		_current_mode.handle_strafe_input(input_direction)

func _handle_camera_input(mouse_delta: Vector2) -> void:
	# Apply rotation immediately instead of accumulating
	if not _spring_arm:
		push_warning("SpringArm3D not available for camera input handling")
		return
	
	# Get the camera pivot (parent of SpringArm3D)
	var camera_pivot = _spring_arm.get_parent()
	if not camera_pivot:
		push_warning("Camera pivot (SpringArm3D parent) not found")
		return
	
	if not _player_controller:
		push_warning("Player controller not available for camera input handling")
		return
	
	# Check if current mode is in strafe mode
	var is_strafe_mode = false
	if _current_mode and _current_mode.has_method("is_strafe_mode_enabled"):
		is_strafe_mode = _current_mode.is_strafe_mode_enabled()
	
	# Mouse delta already includes sensitivity from InputHandler
	# Apply horizontal rotation (yaw) consistently - always to the player
	# The movement controller will handle making the player skin follow the camera in strafe mode
	_player_controller.rotation.y -= mouse_delta.x
	
	# Apply vertical rotation (pitch) to the camera pivot with limits
	_accumulated_pitch += mouse_delta.y
	var pitch_limit_up_rad = deg_to_rad(-pitch_limit_up) # Negative for looking up
	var pitch_limit_down_rad = deg_to_rad(pitch_limit_down) # Positive for looking down
	_accumulated_pitch = clamp(_accumulated_pitch, pitch_limit_up_rad, pitch_limit_down_rad)
	camera_pivot.rotation.x = _accumulated_pitch

func _handle_zoom_input(zoom_direction: float) -> void:
	# Only handle zoom for camera modes that support it
	if _current_mode and _current_mode.has_method("handle_zoom"):
		_current_mode.handle_zoom(zoom_direction)

func _toggle_strafe_mode() -> void:
	# Toggle strafe mode for third person camera
	if _current_mode and _current_mode.has_method("set_strafe_mode"):
		var current_strafe_state = _current_mode.is_strafe_mode_enabled() if _current_mode.has_method("is_strafe_mode_enabled") else false
		_current_mode.set_strafe_mode(not current_strafe_state)

func _handle_movement_input(input_direction: Vector2) -> void:
	# Pass movement input to current mode for strafe handling
	if _current_mode and _current_mode.has_method("handle_strafe_input"):
		_current_mode.handle_strafe_input(input_direction)

# Legacy compatibility methods for existing code
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

func _find_node_by_path_or_type(node_path: NodePath, type_name: String) -> Node:
	# First try the specified path
	var node = get_node_or_null(node_path)
	if node:
		return node
	
	# If path fails, search for the type in the scene tree
	push_warning("Node path '%s' not found, searching for type '%s' in scene tree. Consider updating the node path for better performance." % [node_path, type_name])
	var found_node = _find_node_by_type_recursive(get_tree().current_scene, type_name)
	
	if not found_node:
		push_error("Could not find node of type '%s' anywhere in the scene tree. Please ensure the node exists and is properly configured." % type_name)
	
	return found_node

func _find_node_by_type_recursive(node: Node, type_name: String) -> Node:
	# Check if current node matches the type
	if node.get_class() == type_name or (node.get_script() and node.get_script().get_global_name() == type_name):
		return node
	
	# Search children recursively
	for child in node.get_children():
		var result = _find_node_by_type_recursive(child, type_name)
		if result:
			return result
	
	return null
