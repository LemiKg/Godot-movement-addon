class_name EnhancedMovementSystem
extends Node

## Enhanced Movement System - Event-driven movement with the same calculations
## Maintains exact same movement behavior as original system

signal movement_applied(velocity: Vector3)

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

var _player: CharacterBody3D
var _camera: Camera3D
var _camera_controller: Node

# Movement state tracking (preserving original behavior)
var _current_movement_direction: Vector3 = Vector3.ZERO
var _last_movement_direction: Vector3 = Vector3.BACK
var _jump_buffer_timer: float = 0.0
var _coyote_time_timer: float = 0.0
var _was_on_floor: bool = true

# Current state for movement calculations
var _current_state: String = "idle"

func initialize(player: CharacterBody3D, camera: Camera3D, camera_controller: Node = null) -> void:
	_player = player
	_camera = camera
	_camera_controller = camera_controller
	_was_on_floor = _player.is_on_floor() if _player else true
	
	# Connect to event bus if available
	_connect_events()

func _connect_events() -> void:
	# We'll connect to events when EventBus is properly set up
	pass

func process_movement(delta: float, input_direction: Vector2) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	_calculate_movement_direction(input_direction)
	_apply_movement(delta)
	_update_rotation(delta)
	_track_floor_state()

func _update_timers(delta: float) -> void:
	# Update jump buffer (same as original)
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta
	
	# Update coyote time (same as original)
	if _player.is_on_floor():
		_coyote_time_timer = coyote_time
	else:
		_coyote_time_timer -= delta

func _apply_gravity(delta: float) -> void:
	# Apply gravity (same as original)
	if not _player.is_on_floor():
		_player.velocity.y -= gravity * delta

func _calculate_movement_direction(raw_input: Vector2) -> void:
	if not _camera:
		return
	
	# Check if strafe mode is enabled (same logic as original)
	var is_strafe_mode = _is_strafe_mode_enabled()
	
	if is_strafe_mode:
		# In strafe mode: forward/back relative to camera, left/right is strafing
		var forward = _camera.global_basis.z.normalized()
		var right = _camera.global_basis.x.normalized()
		var move_direction = forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		_current_movement_direction = move_direction.normalized()
		
		# In strafe mode, don't update last movement direction for player rotation
		if _current_movement_direction.length() > 0.2:
			_last_movement_direction = - _camera.global_basis.z.normalized()
		
		# Send strafe input to camera for tilt effect
		if _camera_controller and _camera_controller.has_method("handle_strafe_input"):
			_camera_controller.handle_strafe_input(raw_input)
	else:
		# Normal mode: movement relative to camera direction
		var forward = _camera.global_basis.z.normalized()
		var right = _camera.global_basis.x.normalized()
		var move_direction = forward * raw_input.y + right * raw_input.x
		move_direction.y = 0.0
		_current_movement_direction = move_direction.normalized()
		
		if _current_movement_direction.length() > 0.2:
			_last_movement_direction = _current_movement_direction

func _apply_movement(delta: float) -> void:
	# Get current speed based on state
	var current_speed = _get_speed_for_current_state()
	
	# Calculate horizontal movement direction (same as original)
	var target_velocity = _current_movement_direction * current_speed
	
	# Apply horizontal movement with acceleration (same as original)
	_player.velocity.x = move_toward(_player.velocity.x, target_velocity.x, acceleration * delta)
	_player.velocity.z = move_toward(_player.velocity.z, target_velocity.z, acceleration * delta)

func _update_rotation(delta: float) -> void:
	# Check if we're in strafe mode (same logic as original)
	var is_strafe_mode = _is_strafe_mode_enabled()
	var skin = _player.get_node_or_null("Character") as Node3D
	if not skin:
		return
	
	# In strafe mode, player skin should smoothly follow camera direction
	if is_strafe_mode:
		# Get camera forward direction in world space
		var camera_forward = - _camera.global_basis.z.normalized()
		camera_forward.y = 0.0 # Flatten to horizontal plane
		camera_forward = camera_forward.normalized()
		
		# Calculate target angle from camera direction
		var target_angle = Vector3.BACK.signed_angle_to(camera_forward, Vector3.UP)
		
		# Apply smooth rotation using the same lerp as normal mode
		skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, rotation_speed * delta)
	# Normal mode: rotate based on movement direction
	elif _current_movement_direction.length() > 0.2:
		var target_angle = Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, rotation_speed * delta)

func _track_floor_state() -> void:
	var is_on_floor = _player.is_on_floor()
	if is_on_floor != _was_on_floor:
		_was_on_floor = is_on_floor
		# Emit floor state change event when EventBus is available

func request_jump() -> void:
	_jump_buffer_timer = jump_buffer_time

func can_jump() -> bool:
	return _jump_buffer_timer > 0 and _coyote_time_timer > 0

func execute_jump() -> void:
	if can_jump():
		_player.velocity.y = jump_velocity
		_jump_buffer_timer = 0
		_coyote_time_timer = 0

func set_movement_state(state: String) -> void:
	_current_state = state

func get_movement_direction() -> Vector3:
	return _current_movement_direction

func _get_speed_for_current_state() -> float:
	match _current_state.to_lower():
		"idle":
			return 0.0
		"walking":
			return walk_speed
		"running":
			return run_speed
		"sprint":
			return sprint_speed
		"crouch_idle":
			return 0.0
		"crouch_move", "crouching_fwd", "crouch":
			return crouch_speed
		"jumping":
			return jump_air_control_speed
		"falling":
			return falling_air_control_speed
		"landing":
			return 0.0
		_:
			return walk_speed

func _is_strafe_mode_enabled() -> bool:
	"""Check if strafe mode is enabled in the current camera mode (same as original)"""
	if not _camera_controller:
		return false
	
	# Get current camera mode
	var current_mode = null
	if _camera_controller.has_method("get_current_mode"):
		current_mode = _camera_controller.get_current_mode()
	
	# Check if it's third person mode with strafe enabled
	if current_mode and current_mode.has_method("is_strafe_mode_enabled"):
		return current_mode.is_strafe_mode_enabled()
	
	return false
