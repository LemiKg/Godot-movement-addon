class_name SprintMovementStrategy
extends MovementStrategy

## Sprint movement strategy  
## Implements the exact same sprint calculations as the original system

func _init():
	speed = 12.0 # SPRINT_SPEED from original
	acceleration = 20.0
	can_jump = true
	air_control = false

func get_strategy_name() -> String:
	return "sprint"

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Rotation is now handled centrally by MovementSystem to support strafe mode
	pass

func can_transition_to(state_name: String) -> bool:
	# Sprint can transition to other movement states
	return state_name in [
		"idle",
		"walking",
		"running",
		"jumping"
	]

func on_enter() -> void:
	# Emit event when entering sprint state
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.movement_started.emit(Vector3.ZERO, speed)
