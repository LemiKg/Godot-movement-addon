class_name MovementStrategy
extends Resource

## Base class for all movement strategies
## Implements the Strategy Pattern for different movement behaviors

@export var speed: float = 5.0
@export var acceleration: float = 20.0
@export var can_jump: bool = true
@export var air_control: bool = false

# Reference to the player for movement calculations
var player: CharacterBody3D
var camera: Camera3D

func initialize(player_ref: CharacterBody3D, camera_ref: Camera3D) -> void:
	player = player_ref
	camera = camera_ref

## Calculate movement based on input direction and delta time
## Returns the target velocity for this movement type
func calculate_movement(input_direction: Vector2, delta: float) -> Vector3:
	if not player or not camera:
		return Vector3.ZERO
	
	# Default implementation - basic movement
	var forward = - camera.global_basis.z.normalized()
	var right = camera.global_basis.x.normalized()
	var move_direction = forward * input_direction.y + right * input_direction.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	return move_direction * speed

## Apply movement to the player
## This preserves the exact same movement calculations as the original system
func apply_movement(target_velocity: Vector3, delta: float) -> void:
	if not player:
		return
	
	# Apply horizontal movement with acceleration (same as original)
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, acceleration * delta)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, acceleration * delta)

## Handle rotation for this movement type
func handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Default implementation - no rotation handling
	pass

## Can this movement type transition to the given state?
func can_transition_to(state_name: String) -> bool:
	return true

## Get the strategy name for debugging
func get_strategy_name() -> String:
	return "base_movement"

## Called when this strategy becomes active
func on_enter() -> void:
	pass

## Called when this strategy is deactivated
func on_exit() -> void:
	pass
