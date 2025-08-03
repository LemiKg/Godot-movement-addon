class_name EnhancedCameraStrategy
extends Resource

## Base class for enhanced camera strategies
## Implements the Strategy Pattern for different camera behaviors

@export var fov: float = 75.0
@export var requires_player_model: bool = true

# Reference to camera components
var spring_arm: SpringArm3D
var camera: Camera3D
var player: CharacterBody3D

func initialize(spring_arm_ref: SpringArm3D, camera_ref: Camera3D, player_ref: CharacterBody3D) -> void:
	spring_arm = spring_arm_ref
	camera = camera_ref
	player = player_ref

## Apply camera positioning and settings
func apply_to_spring_arm(spring_arm_ref: SpringArm3D, delta: float) -> void:
	pass

## Called when this camera mode becomes active
func on_mode_activated(spring_arm_ref: SpringArm3D) -> void:
	pass

## Called when this camera mode is deactivated
func on_mode_deactivated(spring_arm_ref: SpringArm3D) -> void:
	pass

## Get the FOV for this camera mode
func get_fov() -> float:
	return fov

## Whether this mode requires the player model to be visible
func requires_player_model_visibility() -> bool:
	return requires_player_model

## Handle zoom input (override if zoom is supported)
func handle_zoom(zoom_direction: float) -> void:
	pass

## Get the strategy name for debugging
func get_strategy_name() -> String:
	return "base_camera"
