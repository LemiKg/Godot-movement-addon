class_name ThirdPersonCameraStrategy
extends CameraStrategyBase

## Third Person camera strategy
## Implements the exact same third person behavior as the original system

var _rotation: Vector3 = Vector3.ZERO
var _current_distance: float = 5.0
var _target_distance: float = 5.0
var strafe_mode: bool = false
var _current_strafe_tilt: float = 0.0
var _target_strafe_tilt: float = 0.0

# Configurable parameters (same as original)
var camera_distance: float = 5.0
var camera_height: float = 1.5
var camera_side_offset: float = 0.0
var position_smoothing: float = 10.0
var strafe_tilt_amount: float = 5.0
var strafe_smoothing: float = 10.0

func get_strategy_name() -> String:
	return "third_person"

func set_distance(distance: float) -> void:
	camera_distance = distance
	_current_distance = distance
	_target_distance = distance

func set_height(height: float) -> void:
	camera_height = height

func set_side_offset(offset: float) -> void:
	camera_side_offset = offset

func set_strafe_tilt_amount(amount: float) -> void:
	strafe_tilt_amount = amount

func set_strafe_smoothing(smoothing: float) -> void:
	strafe_smoothing = smoothing

func set_position_smoothing(smooth: float) -> void:
	position_smoothing = smooth

func handle_input(mouse_delta: Vector2, delta: float) -> void:
	if not spring_arm or not camera:
		return
	
	# Same rotation calculation as original
	_rotation.y -= mouse_delta.x * sensitivity
	_rotation.x -= mouse_delta.y * sensitivity
	
	# Clamp pitch (same as original)
	_rotation.x = clamp(_rotation.x, -30.0, 60.0)
	
	# Apply rotation
	spring_arm.rotation_degrees = _rotation

func handle_zoom(zoom_delta: float) -> void:
	if not spring_arm:
		return
	
	# Handle mouse wheel zoom (same as original)
	_target_distance += zoom_delta * zoom_speed
	_target_distance = clamp(_target_distance, min_zoom, max_zoom)

func process(delta: float) -> void:
	if not spring_arm:
		return
	
	# Smooth distance transition
	_current_distance = lerp(_current_distance, _target_distance, smoothing * delta)
	spring_arm.spring_length = _current_distance
	
	# Apply strafe camera tilt (same as original - to camera Y rotation, not spring arm Z)
	_apply_strafe_camera_tilt(delta)

func _apply_strafe_camera_tilt(delta: float) -> void:
	# Ensure variables are valid floats (same as original)
	if _current_strafe_tilt == null:
		_current_strafe_tilt = 0.0
	if _target_strafe_tilt == null:
		_target_strafe_tilt = 0.0
	
	_current_strafe_tilt = lerp(_current_strafe_tilt, _target_strafe_tilt, strafe_smoothing * delta)
	
	# Apply rotation to the camera inside the spring arm, not the spring arm itself (same as original)
	if camera:
		camera.rotation_degrees.y = _current_strafe_tilt

func on_enter() -> void:
	if spring_arm:
		spring_arm.spring_length = 5.0
		spring_arm.position = Vector3(0, 1.5, 0) # Camera height
		_current_distance = 5.0
		_target_distance = 5.0
	if camera:
		camera.fov = 75.0 # Standard third person FOV

func on_exit() -> void:
	# Reset any rotations when switching away
	if spring_arm:
		spring_arm.rotation.z = 0.0
	if camera:
		camera.rotation_degrees.y = 0.0
	_current_strafe_tilt = 0.0
	_target_strafe_tilt = 0.0

func set_strafe_mode(enabled: bool) -> void:
	strafe_mode = enabled
	if not enabled:
		_target_strafe_tilt = 0.0

func is_strafe_mode_enabled() -> bool:
	return strafe_mode

func handle_strafe_input(input_direction: Vector2) -> void:
	# Handle strafe input to adjust camera tilt (same as original)
	if not strafe_mode:
		return
	
	# Calculate target tilt based on horizontal input (same as original)
	# Positive input (right) = positive tilt (camera tilts right)  
	# Negative input (left) = negative tilt (camera tilts left)
	_target_strafe_tilt = input_direction.x * strafe_tilt_amount

func requires_player_model_visibility() -> bool:
	return true # Show player model in third person
