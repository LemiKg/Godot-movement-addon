class_name EnhancedPlayerController
extends CharacterBody3D

## Enhanced Player Controller - Event-driven architecture with same functionality
## Maintains exact same movement and camera behavior as original system

@export_group("Component References")
@export var spring_arm: SpringArm3D
@export var camera: Camera3D
@export var character_mesh: Node3D
@export var collision_shape: CollisionShape3D

@export_group("Movement Parameters")
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var sprint_speed: float = 12.0
@export var crouch_speed: float = 3.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 20.0
@export var rotation_speed: float = 20.0
@export var gravity: float = 9.8

@export_group("Air Control")
@export var jump_air_control_speed: float = 5.0
@export var falling_air_control_speed: float = 5.0

@export_group("Input Buffers")
@export var jump_buffer_time: float = 0.2
@export var coyote_time: float = 0.2

@export_group("Camera Parameters")
@export var camera_sensitivity: float = 2.0
@export var zoom_speed: float = 2.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 10.0
@export var camera_smoothing: float = 10.0
@export var strafe_mode_enabled: bool = false

@export_group("System Configuration")
@export var enable_debug_logging: bool = false
@export var auto_capture_mouse: bool = true

# Systems - these will be initialized in _ready()
var _movement_system: Node
var _state_machine: Node
var _input_system: Node
var _camera_system: Node

# Current input state
var _current_input_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Auto-assign references if not set in inspector (same as original)
	if not spring_arm:
		spring_arm = get_node_or_null("CameraPivot/SpringArm3D")
	if not camera:
		camera = get_node_or_null("CameraPivot/SpringArm3D/Camera3D")
	if not character_mesh:
		character_mesh = get_node_or_null("Character")
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape3D")
	
	# Capture mouse on start if enabled
	if auto_capture_mouse:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	_setup_systems()
	_connect_signals()

func _setup_systems() -> void:
	# Get system nodes from the scene
	_movement_system = get_node_or_null("Systems/MovementSystem")
	_state_machine = get_node_or_null("Systems/StateMachine")
	_input_system = get_node_or_null("Systems/InputSystem")
	_camera_system = get_node_or_null("Systems/CameraSystem")
	
	# Configure systems with exported parameters
	if _movement_system:
		_movement_system.gravity = gravity
		_movement_system.initialize(self, camera, _camera_system)
	
	if _state_machine:
		_state_machine.initialize(self, _movement_system, _input_system)
	
	if _input_system:
		# Pass jump buffer time to input system if it has this property
		if _input_system.has_method("set_jump_buffer_time"):
			_input_system.set_jump_buffer_time(jump_buffer_time)
		_input_system.initialize(_state_machine, _movement_system)
	
	if _camera_system:
		# Apply camera configuration
		_camera_system.sensitivity = camera_sensitivity
		_camera_system.zoom_speed = zoom_speed
		_camera_system.min_zoom = min_zoom
		_camera_system.max_zoom = max_zoom
		_camera_system.smoothing = camera_smoothing
		_camera_system.strafe_mode_enabled = strafe_mode_enabled
		_camera_system.initialize(self, _input_system)

func _connect_signals() -> void:
	# Connect input system signals (same as original pattern)
	if _input_system:
		# Movement input
		if _input_system.has_signal("input_processed"):
			_input_system.input_processed.connect(_on_input_processed)
	
	# Connect state machine signals (same as original pattern)
	if _state_machine:
		_state_machine.state_changed.connect(_on_state_changed)
	
	# Connect camera system signals
	if _camera_system:
		_camera_system.camera_mode_changed.connect(_on_camera_mode_changed)

func _physics_process(delta: float) -> void:
	# Don't process physics in the editor
	if Engine.is_editor_hint():
		return
	
	# Process all systems in proper order (same as original)
	if _state_machine:
		_state_machine._process(delta)
	
	# Get current input from input system
	if _input_system:
		_current_input_direction = _input_system.get_input_vector()
		
		# Pass strafe input to camera system for tilt effect
		if _camera_system:
			_camera_system.handle_strafe_input(_current_input_direction)
	
	# Apply physics movement (same as original)
	move_and_slide()

func _input(event: InputEvent) -> void:
	# Don't process input in the editor
	if Engine.is_editor_hint():
		return
	
	# Handle camera input through camera system (same as original)
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if _camera_system:
			var mouse_delta = event.screen_relative * camera_sensitivity * 0.001 # Use configurable sensitivity
			_camera_system.handle_camera_input(mouse_delta)
	
	# Handle camera mode toggle
	if event.is_action_pressed("toggle_camera_mode") and _camera_system:
		_camera_system.toggle_camera_mode()
	
	# Handle strafe mode toggle (if action exists)
	if InputMap.has_action("toggle_strafe_mode") and event.is_action_pressed("toggle_strafe_mode"):
		if _camera_system:
			_camera_system.toggle_strafe_mode()
	
	# Handle zoom input
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if _camera_system:
				_camera_system.handle_zoom_input(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if _camera_system:
				_camera_system.handle_zoom_input(zoom_speed)

# Signal handlers (same pattern as original)
func _on_input_processed(input_data: Dictionary) -> void:
	# Handle processed input data
	pass

func _on_state_changed(old_state: String, new_state: String) -> void:
	# Handle state-specific behaviors (same as original)
	if enable_debug_logging:
		print("[EnhancedPlayerController] State changed: %s -> %s" % [old_state, new_state])
	
	# Handle collision shape changes for crouching (same as original)
	match new_state:
		"crouch_idle", "crouch_move":
			if collision_shape and collision_shape.shape is CapsuleShape3D:
				collision_shape.shape.height = 1.0
		_:
			if collision_shape and collision_shape.shape is CapsuleShape3D:
				collision_shape.shape.height = 1.8

func _on_camera_mode_changed(mode_name: String) -> void:
	if enable_debug_logging:
		print("[EnhancedPlayerController] Camera mode changed to: %s" % mode_name)

# Public API for external systems (same as original)
func get_current_state() -> String:
	if _state_machine:
		return _state_machine.get_current_state()
	return "idle"

func is_in_state(state: String) -> bool:
	if _state_machine:
		return _state_machine.is_in_state(state)
	return false

func can_move() -> bool:
	if _state_machine:
		return _state_machine.can_move()
	return false

func can_jump() -> bool:
	if _state_machine:
		return _state_machine.can_jump()
	return false

func get_movement_system() -> Node:
	return _movement_system

func get_state_machine() -> Node:
	return _state_machine

func get_input_system() -> Node:
	return _input_system

func get_camera_system() -> Node:
	return _camera_system

# Utility methods for setup validation
func validate_setup() -> bool:
	var is_valid = true
	
	# Check required references (same as original)
	if not spring_arm:
		push_error("[EnhancedPlayerController] Spring arm not found")
		is_valid = false
	if not camera:
		push_error("[EnhancedPlayerController] Camera not found")
		is_valid = false
	if not character_mesh:
		push_warning("[EnhancedPlayerController] Character mesh not found")
	if not collision_shape:
		push_error("[EnhancedPlayerController] Collision shape not found")
		is_valid = false
	
	# Check system initialization
	if not _movement_system:
		push_error("[EnhancedPlayerController] Movement system not initialized")
		is_valid = false
	if not _state_machine:
		push_error("[EnhancedPlayerController] State machine not initialized")
		is_valid = false
	if not _input_system:
		push_error("[EnhancedPlayerController] Input system not initialized")
		is_valid = false
	if not _camera_system:
		push_error("[EnhancedPlayerController] Camera system not initialized")
		is_valid = false
	
	return is_valid
