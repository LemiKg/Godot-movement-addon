class_name CameraStrategyBase
extends RefCounted

## Base class for camera strategies
## Implements the strategy pattern for different camera behaviors

var spring_arm: SpringArm3D
var camera: Camera3D
var player: CharacterBody3D

# Camera parameters
var sensitivity: float = 2.0
var invert_horizontal: bool = false
var invert_vertical: bool = false
var zoom_speed: float = 2.0
var min_zoom: float = 2.0
var max_zoom: float = 10.0
var smoothing: float = 10.0

func initialize(spring_arm_ref: SpringArm3D, camera_ref: Camera3D, player_ref: CharacterBody3D) -> void:
	spring_arm = spring_arm_ref
	camera = camera_ref
	player = player_ref

func get_strategy_name() -> String:
	return "base"

func handle_input(mouse_delta: Vector2, delta: float) -> void:
	# Override in derived classes
	pass

func handle_zoom(zoom_delta: float) -> void:
	# Override in derived classes
	pass

func process(delta: float) -> void:
	# Override in derived classes
	pass

func on_enter() -> void:
	# Called when strategy becomes active
	pass

func on_exit() -> void:
	# Called when strategy becomes inactive
	pass

func apply_camera_settings() -> void:
	# Apply common camera settings
	if spring_arm:
		spring_arm.spring_length = clamp(spring_arm.spring_length, min_zoom, max_zoom)

func apply_mouse_input(mouse_delta: Vector2) -> Vector2:
	# Apply inversion settings to mouse input
	var adjusted_delta = mouse_delta
	if invert_horizontal:
		adjusted_delta.x = - adjusted_delta.x
	if invert_vertical:
		adjusted_delta.y = - adjusted_delta.y
	return adjusted_delta
