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

var _target_position: Vector3
var _current_zoom_distance: float = 5.0 # Initialize with default camera distance
var _target_zoom_distance: float = 5.0 # Initialize with default camera distance
var _initialized: bool = false

func apply_to_spring_arm(spring_arm: SpringArm3D, delta: float) -> void:
	# Ensure initialization happens after export variables are available
	if not _initialized:
		_current_zoom_distance = camera_distance
		_target_zoom_distance = camera_distance
		_initialized = true
	
	# Apply smooth zoom if enabled
	if smooth_zoom:
		_current_zoom_distance = lerp(_current_zoom_distance, _target_zoom_distance, zoom_smoothing * delta)
	else:
		_current_zoom_distance = _target_zoom_distance
	
	# Set spring arm length with zoom
	spring_arm.spring_length = _current_zoom_distance
	
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
