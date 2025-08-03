@tool
class_name ThirdPersonMode
extends CameraStrategy

@export var camera_distance: float = 5.0
@export var camera_height: float = 2.0
@export var camera_side_offset: float = 0.5
@export var fov: float = 75.0
@export var collision_mask: int = 1
@export var smooth_position: bool = true
@export var position_smoothing: float = 10.0

var _target_position: Vector3

func apply_to_spring_arm(spring_arm: SpringArm3D, delta: float) -> void:
	# Set spring arm length for third person
	spring_arm.spring_length = camera_distance
	
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
	# Enable collision for third person
	spring_arm.collision_mask = collision_mask
	# SpringArm3D already handles collision detection and camera positioning
