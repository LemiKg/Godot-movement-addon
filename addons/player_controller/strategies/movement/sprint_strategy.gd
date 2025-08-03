class_name SprintMovementStrategy
extends MovementStrategy

## Sprint movement strategy  
## Implements the exact same sprint calculations as the original system

func _init():
	speed = MovementConstants.SPRINT_SPEED
	acceleration = MovementConstants.ACCELERATION_DEFAULT
	can_jump = true
	air_control = false

func get_strategy_name() -> String:
	return MovementConstants.STRATEGY_SPRINT

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Rotation is now handled centrally by MovementSystem to support strafe mode
	pass

func can_transition_to(state_name: String) -> bool:
	# Sprint can transition to most states except crouch
	return state_name in [
		MovementConstants.STATE_IDLE,
		MovementConstants.STATE_WALKING,
		MovementConstants.STATE_RUNNING,
		MovementConstants.STATE_JUMPING
	]

func on_enter() -> void:
	# Emit event when entering sprint state
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.movement_started.emit(Vector3.ZERO, speed)
