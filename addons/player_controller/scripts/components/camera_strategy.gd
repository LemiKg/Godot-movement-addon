@tool
class_name CameraStrategy
extends Resource

## Abstract base class for camera strategies using SpringArm3D

func apply_to_spring_arm(spring_arm: SpringArm3D, delta: float) -> void:
	push_error("apply_to_spring_arm() must be implemented in derived class")

func get_fov() -> float:
	return 75.0

func requires_player_model_visibility() -> bool:
	return true

func get_transition_duration() -> float:
	return 0.3

func on_mode_activated(spring_arm: SpringArm3D) -> void:
	# Optional: Called when this mode becomes active
	pass

func on_mode_deactivated(spring_arm: SpringArm3D) -> void:
	# Optional: Called when switching away from this mode
	pass

func handle_zoom(zoom_direction: float) -> void:
	# Optional: Handle zoom input for camera modes that support it
	# zoom_direction: -1.0 for zoom in, 1.0 for zoom out
	pass
