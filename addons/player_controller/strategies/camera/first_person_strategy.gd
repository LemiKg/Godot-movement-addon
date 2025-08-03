class_name FirstPersonCameraStrategy
extends CameraStrategyBase

## First Person camera strategy
## Implements the exact same first person behavior as the original system

var _rotation: Vector3 = Vector3.ZERO

func get_strategy_name() -> String:
	return "first_person"

func handle_input(mouse_delta: Vector2, delta: float) -> void:
	if not spring_arm or not camera:
		return
	
	# Apply inversion settings from base class
	var adjusted_delta = apply_mouse_input(mouse_delta)
	
	# Same rotation calculation as original
	_rotation.y -= adjusted_delta.x * sensitivity
	_rotation.x += adjusted_delta.y * sensitivity
	
	# Clamp pitch (same as original)
	_rotation.x = clamp(_rotation.x, -30.0, 60.0)
	
	# Apply rotation
	spring_arm.rotation_degrees = _rotation

func handle_zoom(zoom_delta: float) -> void:
	# First person doesn't use zoom
	pass

func on_enter() -> void:
	if spring_arm:
		spring_arm.spring_length = 0.1 # Very close for first person
		spring_arm.position = Vector3(0, 1.7, 0) # Head height
	if camera:
		camera.fov = 90.0 # Wider FOV for first person

func on_exit() -> void:
	# Reset FOV when leaving first person
	if camera:
		camera.fov = 75.0
	if spring_arm:
		spring_arm.position = Vector3.ZERO

func requires_player_model_visibility() -> bool:
	return false # Hide player model in first person

# Configuration methods
func set_fov(new_fov: float) -> void:
	if camera:
		camera.fov = new_fov

func set_head_height(height: float) -> void:
	if spring_arm:
		spring_arm.position = Vector3(0, height, 0)
