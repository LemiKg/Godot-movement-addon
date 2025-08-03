class_name MovementSystem
extends Node

## Movement System - Handles all movement calculations using strategies
## Maintains the same movement calculations as the original system

signal movement_applied(velocity: Vector3)

@export_group("Movement Parameters")
@export var gravity: float = 9.8
@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var sprint_speed: float = 12.0
@export var crouch_speed: float = 3.0
@export var jump_velocity: float = 4.5
@export var acceleration: float = 20.0
@export var rotation_speed: float = 20.0

@export_group("Air Control")
@export var jump_air_control_speed: float = 5.0
@export var falling_air_control_speed: float = 5.0

@export_group("Input Buffers")
@export var jump_buffer_time: float = 0.2
@export var coyote_time: float = 0.2

var _player: CharacterBody3D
var _camera: Camera3D
var _camera_system: Node # Reference to camera system for strafe mode checking

# Strategy management
var _strategies: Dictionary = {}
var _current_strategy: MovementStrategy

# Movement state tracking (preserving original behavior)
var _last_movement_direction: Vector3 = Vector3.BACK
var _jump_buffer_timer: float = 0.0
var _coyote_time_timer: float = 0.0
var _was_on_floor: bool = true

# Current movement parameters
var current_speed: float = 5.0

func initialize(player: CharacterBody3D, camera: Camera3D, camera_system: Node = null) -> void:
	_player = player
	_camera = camera
	_camera_system = camera_system
	_was_on_floor = _player.is_on_floor() if _player else true
	_setup_strategies()
	_connect_events()

func _setup_strategies() -> void:
	# Load all movement strategies using constants
	_strategies[MovementConstants.STRATEGY_WALK] = preload("res://addons/player_controller/strategies/movement/walk_strategy.gd").new()
	_strategies[MovementConstants.STRATEGY_RUN] = preload("res://addons/player_controller/strategies/movement/run_strategy.gd").new()
	_strategies[MovementConstants.STRATEGY_SPRINT] = preload("res://addons/player_controller/strategies/movement/sprint_strategy.gd").new()
	_strategies[MovementConstants.STRATEGY_CROUCH] = preload("res://addons/player_controller/strategies/movement/crouch_strategy.gd").new()
	_strategies[MovementConstants.STRATEGY_JUMP] = preload("res://addons/player_controller/strategies/movement/jump_strategy.gd").new()
	_strategies[MovementConstants.STRATEGY_FALL] = preload("res://addons/player_controller/strategies/movement/fall_strategy.gd").new()
	
	# Initialize all strategies
	for strategy in _strategies.values():
		strategy.initialize(_player, _camera)
	
	# Set default strategy
	set_strategy(MovementConstants.STRATEGY_WALK)

func _connect_events() -> void:
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.state_changed.connect(_on_state_changed)
		EnhancedEventBus.instance.jump_pressed.connect(_on_jump_pressed)
		EnhancedEventBus.instance.physics_processed.connect(_on_physics_processed)

func set_strategy(strategy_name: String) -> void:
	if strategy_name not in _strategies:
		push_error("Movement strategy not found: " + strategy_name)
		return
	
	if _current_strategy:
		_current_strategy.on_exit()
	
	_current_strategy = _strategies[strategy_name]
	_current_strategy.on_enter()

func process_movement(input_direction: Vector2, delta: float) -> void:
	_update_timers(delta)
	_apply_gravity(delta)
	
	if _current_strategy:
		# Calculate target velocity using strategy
		var target_velocity = _current_strategy.calculate_movement(input_direction, delta)
		
		# Apply movement using strategy
		_current_strategy.apply_movement(target_velocity, delta)
		
		# Handle rotation centrally (with strafe mode support)
		_handle_rotation(input_direction, delta)
		
		# Emit movement event
		if EnhancedEventBus.instance:
			EnhancedEventBus.instance.movement_direction_changed.emit(target_velocity.normalized())
	
	# Track floor state changes
	_track_floor_state()

func _update_timers(delta: float) -> void:
	# Update jump buffer (same as original)
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta
	
	# Update coyote time (same as original)
	if _player.is_on_floor():
		_coyote_time_timer = MovementConstants.COYOTE_TIME_DEFAULT
	else:
		_coyote_time_timer -= delta

func _apply_gravity(delta: float) -> void:
	# Apply gravity (same as original)
	if not _player.is_on_floor():
		_player.velocity.y -= gravity * delta
	
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.gravity_applied.emit(delta)

func _track_floor_state() -> void:
	var is_on_floor = _player.is_on_floor()
	if is_on_floor != _was_on_floor:
		_was_on_floor = is_on_floor
		if EnhancedEventBus.instance:
			EnhancedEventBus.instance.floor_state_changed.emit(is_on_floor)

func _handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Check if we're in strafe mode (same logic as original)
	var is_strafe_mode = _is_strafe_mode_enabled()
	var skin = _player.get_node_or_null("Character") as Node3D
	if not skin:
		return
	
	# In strafe mode, player should face camera direction (same as original)
	if is_strafe_mode:
		# Get camera forward direction in world space
		var camera_forward = - _camera.global_basis.z.normalized()
		camera_forward.y = 0.0 # Flatten to horizontal plane
		camera_forward = camera_forward.normalized()
		
		# Calculate target angle from camera direction
		var target_angle = Vector3.BACK.signed_angle_to(camera_forward, Vector3.UP)
		
		# Apply smooth rotation using rotation speed
		skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, rotation_speed * delta)
	
	# Normal mode: rotate based on movement direction (same as original)
	elif input_direction.length() > MovementConstants.INPUT_THRESHOLD:
		var forward = - _camera.global_basis.z.normalized()
		var right = _camera.global_basis.x.normalized()
		var move_direction = forward * input_direction.y + right * input_direction.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()
		
		if move_direction.length() > MovementConstants.INPUT_THRESHOLD:
			var target_angle = Vector3.BACK.signed_angle_to(move_direction, Vector3.UP)
			skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, rotation_speed * delta)

func _is_strafe_mode_enabled() -> bool:
	# Check if strafe mode is enabled in the current camera mode (same as original)
	if not _camera_system:
		return false
	
	# Get current camera strategy
	var current_strategy = null
	if _camera_system.has_method("get_current_strategy"):
		current_strategy = _camera_system.get_current_strategy()
	
	# Check if it's third person mode with strafe enabled
	if current_strategy and current_strategy.has_method("is_strafe_mode_enabled"):
		return current_strategy.is_strafe_mode_enabled()
	
	return false

func request_jump() -> void:
	_jump_buffer_timer = MovementConstants.JUMP_BUFFER_DEFAULT
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.jump_buffered.emit()

func can_jump() -> bool:
	# Simplified jump check - just check if player is on floor and has current strategy
	if not _player or not _current_strategy:
		return false
	return _player.is_on_floor() and _current_strategy.can_jump

func execute_jump() -> void:
	if _player and _player.is_on_floor(): # Simplified check
		_player.velocity.y = MovementConstants.JUMP_VELOCITY
		_jump_buffer_timer = 0
		_coyote_time_timer = 0
		
		if EnhancedEventBus.instance:
			EnhancedEventBus.instance.jump_initiated.emit(MovementConstants.JUMP_VELOCITY)

func get_current_strategy() -> MovementStrategy:
	return _current_strategy

func get_movement_speed() -> float:
	if _current_strategy:
		return _current_strategy.speed
	return MovementConstants.WALK_SPEED # Default walk speed

func set_movement_state(state: String) -> void:
	# Use the helper class for cleaner mapping
	if MovementConstants.StateStrategyMapper.has_strategy_for_state(state):
		var strategy = MovementConstants.StateStrategyMapper.get_strategy_for_state(state)
		set_strategy(strategy)

# Event handlers
func _on_state_changed(old_state: String, new_state: String) -> void:
	# Use the helper class for cleaner mapping
	if MovementConstants.StateStrategyMapper.has_strategy_for_state(new_state):
		var strategy = MovementConstants.StateStrategyMapper.get_strategy_for_state(new_state)
		set_strategy(strategy)

func _on_jump_pressed() -> void:
	request_jump()

func _on_physics_processed(delta: float) -> void:
	# This will be called by the main physics processor
	pass
