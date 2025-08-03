@tool
class_name ThirdPersonMode
extends CameraStrategy

@export var camera_distance: float = 5.0
@export var camera_height: float = 0.5
@export var camera_side_offset: float = 0.5
@export var fov: float = 75.0
@export var collision_mask: int = 1
@export var smooth_position: bool = true
@export var position_smoothing: float = 10.0

@export_group("Zoom Settings")
@export var min_zoom_distance: float = 2.0
@export var max_zoom_distance: float = 10.0
@export var zoom_speed: float = 2.0
@export var smooth_zoom: bool = true
@export var zoom_smoothing: float = 8.0

@export_group("Strafe Mode Settings")
@export var strafe_mode_enabled: bool = false
@export var strafe_camera_tilt_amount: float = 5.0 # Degrees of camera tilt when strafing
@export var strafe_camera_smoothing: float = 10.0
@export var player_follows_camera: bool = false # When true, player rotates with camera

var _target_position: Vector3
var _current_zoom_distance: float = 5.0 # Initialize with default camera distance
var _target_zoom_distance: float = 5.0 # Initialize with default camera distance
var _initialized: bool = false
var _current_strafe_tilt: float = 0.0 # Current camera tilt from strafing
var _target_strafe_tilt: float = 0.0 # Target camera tilt

func apply_to_spring_arm(spring_arm: SpringArm3D, delta: float) -> void:
	# Ensure initialization happens after export variables are available
	if not _initialized:
		_current_zoom_distance = camera_distance
		_target_zoom_distance = camera_distance
		# Initialize strafe mode variables to prevent null errors
		if _current_strafe_tilt == null:
			_current_strafe_tilt = 0.0
		if _target_strafe_tilt == null:
			_target_strafe_tilt = 0.0
		_initialized = true
	
	# Apply smooth zoom if enabled
	if smooth_zoom:
		_current_zoom_distance = lerp(_current_zoom_distance, _target_zoom_distance, zoom_smoothing * delta)
	else:
		_current_zoom_distance = _target_zoom_distance
	
	# Set spring arm length with zoom
	spring_arm.spring_length = _current_zoom_distance
	
	# Handle strafe mode camera tilt
	if strafe_mode_enabled:
		_apply_strafe_camera_tilt(spring_arm, delta)
	else:
		# Reset tilt when strafe mode is disabled
		# Ensure _current_strafe_tilt is a valid float
		if _current_strafe_tilt == null:
			_current_strafe_tilt = 0.0
		_current_strafe_tilt = lerp(_current_strafe_tilt, 0.0, strafe_camera_smoothing * delta)
		
		# Reset camera rotation
		var camera = spring_arm.get_child(0) as Camera3D
		if camera:
			camera.rotation_degrees.y = _current_strafe_tilt
	
	# Set target position
	_target_position = Vector3(camera_side_offset, camera_height, 0.0)
	
	# Apply smooth positioning if enabled
	if smooth_position:
		spring_arm.position = spring_arm.position.lerp(_target_position, position_smoothing * delta)
	else:
		spring_arm.position = _target_position

func get_fov() -> float:
	return fov

func requires_player_model_visibility() -> bool:
	return true # Show player model in third person

func on_mode_activated(spring_arm: SpringArm3D) -> void:
	# Initialize zoom values
	_current_zoom_distance = camera_distance
	_target_zoom_distance = camera_distance
	
	# Enable collision for third person
	spring_arm.collision_mask = collision_mask
	# SpringArm3D already handles collision detection and camera positioning


func handle_zoom(zoom_direction: float) -> void:
	"""Handle zoom input from the camera controller"""
	_target_zoom_distance += zoom_direction * zoom_speed
	_target_zoom_distance = clamp(_target_zoom_distance, min_zoom_distance, max_zoom_distance)

func set_zoom_distance(distance: float) -> void:
	"""Set the zoom distance programmatically"""
	_target_zoom_distance = clamp(distance, min_zoom_distance, max_zoom_distance)

func get_current_zoom_distance() -> float:
	"""Get the current zoom distance"""
	return _current_zoom_distance

func reset_zoom() -> void:
	"""Reset zoom to default camera distance"""
	_target_zoom_distance = camera_distance

func handle_strafe_input(input_direction: Vector2) -> void:
	"""Handle strafe input to adjust camera tilt"""
	if not strafe_mode_enabled:
		return
	
	# Calculate target tilt based on horizontal input
	# Positive input (right) = positive tilt (camera tilts right)
	# Negative input (left) = negative tilt (camera tilts left)
	_target_strafe_tilt = input_direction.x * strafe_camera_tilt_amount

func _apply_strafe_camera_tilt(spring_arm: SpringArm3D, delta: float) -> void:
	"""Apply smooth camera rotation for strafe mode"""
	# Ensure variables are valid floats
	if _current_strafe_tilt == null:
		_current_strafe_tilt = 0.0
	if _target_strafe_tilt == null:
		_target_strafe_tilt = 0.0
	
	_current_strafe_tilt = lerp(_current_strafe_tilt, _target_strafe_tilt, strafe_camera_smoothing * delta)
	
	# Apply rotation to the camera inside the spring arm, not the spring arm itself
	var camera = spring_arm.get_child(0) as Camera3D
	if camera:
		camera.rotation_degrees.y = _current_strafe_tilt

func set_strafe_mode(enabled: bool) -> void:
	"""Toggle strafe mode on/off"""
	strafe_mode_enabled = enabled
	if not enabled:
		_target_strafe_tilt = 0.0

func is_strafe_mode_enabled() -> bool:
	"""Check if strafe mode is currently enabled"""
	return strafe_mode_enabled
