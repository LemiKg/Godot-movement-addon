@tool
class_name MovementController
extends Node

## Movement Controller Component - Single Responsibility: Handle movement calculations
## Open/Closed: Can be extended without modifying existing functionality

signal movement_direction_changed(direction: Vector3)

@export_group("Movement Parameters")
@export var walk_speed := 5.0
@export var run_speed := 8.0
@export var sprint_speed := 12.0
@export var crouch_speed := 3.0
@export var jump_velocity := 4.5
@export var acceleration := 20.0
@export var rotation_speed := 20.0
@export var gravity := 9.8

@export_group("Air Control")
@export var jump_air_control_speed := 5.0
@export var falling_air_control_speed := 5.0

@export_group("Input Buffers")
@export var jump_buffer_time := 0.2
@export var coyote_time := 0.2

var _current_movement_direction := Vector3.ZERO
var _last_movement_direction := Vector3.BACK
var _jump_buffer_timer := 0.0
var _coyote_time_timer := 0.0
var _current_speed_modifier := 1.0

var _player: CharacterBody3D
var _camera: Camera3D

func initialize(player: CharacterBody3D, camera: Camera3D) -> void:
	_player = player
	_camera = camera

func process_movement(_delta: float, input_direction: Vector2, current_speed: float) -> void:
	_update_timers(_delta)
	_apply_gravity(_delta)
	_calculate_movement_direction(input_direction)
	_apply_movement(_delta, current_speed)
	_update_rotation(_delta)

func _update_timers(delta: float) -> void:
	# Update jump buffer
	if _jump_buffer_timer > 0:
		_jump_buffer_timer -= delta
	
	# Update coyote time
	if _player.is_on_floor():
		_coyote_time_timer = coyote_time
	else:
		_coyote_time_timer -= delta

func _apply_gravity(delta: float) -> void:
	if not _player.is_on_floor():
		_player.velocity.y -= gravity * delta

func _calculate_movement_direction(raw_input: Vector2) -> void:
	if not _camera:
		return
		
	var forward := _camera.global_basis.z.normalized()
	var right := _camera.global_basis.x.normalized()
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	_current_movement_direction = move_direction.normalized()
	
	if _current_movement_direction.length() > 0.2:
		_last_movement_direction = _current_movement_direction
	
	movement_direction_changed.emit(_current_movement_direction)

func _apply_movement(delta: float, current_speed: float) -> void:
	# Calculate horizontal movement direction
	var target_velocity = _current_movement_direction * current_speed
	
	# Apply horizontal movement with acceleration
	_player.velocity.x = move_toward(_player.velocity.x, target_velocity.x, acceleration * delta)
	_player.velocity.z = move_toward(_player.velocity.z, target_velocity.z, acceleration * delta)
	
	# Don't call move_and_slide here - let the player script handle it

func _update_rotation(delta: float) -> void:
	if _current_movement_direction.length() > 0.2:
		var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
		var skin = _player.get_node_or_null("Character") as Node3D
		if skin:
			skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, rotation_speed * delta)

func request_jump() -> void:
	_jump_buffer_timer = jump_buffer_time

func can_jump() -> bool:
	return _jump_buffer_timer > 0 and _coyote_time_timer > 0

func execute_jump() -> void:
	if can_jump():
		_player.velocity.y = jump_velocity
		_jump_buffer_timer = 0
		_coyote_time_timer = 0

func get_movement_direction() -> Vector3:
	return _current_movement_direction

func get_speed_for_state(state_name: String) -> float:
	match state_name.to_lower():
		"idle":
			return 0.0
		"walking":
			return walk_speed
		"running":
			return run_speed
		"sprint":
			return sprint_speed
		"crouch idle":
			return 0.0
		"crouch move", "crouching_fwd", "crouch":
			return crouch_speed
		"jumping":
			return jump_air_control_speed
		"falling":
			return falling_air_control_speed
		"landing":
			return 0.0
		_:
			return walk_speed

func set_speed_modifier(modifier: float) -> void:
	_current_speed_modifier = modifier

func get_speed_modifier() -> float:
	return _current_speed_modifier

func get_input_direction() -> Vector2:
	# Convert 3D movement direction back to 2D input direction for compatibility
	if _current_movement_direction.length() > 0:
		return Vector2(_current_movement_direction.x, _current_movement_direction.z)
	return Vector2.ZERO
