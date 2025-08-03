class_name RunMovementStrategy
extends MovementStrategy

## Running movement strategy
## Implements the exact same running calculations as the original system

func _init():
	speed = 8.0 # RUN_SPEED from original
	acceleration = 20.0
	can_jump = true
	air_control = false

func get_strategy_name() -> String:
	return "run"

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Rotation is now handled centrally by MovementSystem to support strafe mode
	pass

func can_transition_to(state_name: String) -> bool:
	# Running can transition to most states
	return state_name in [
		"idle",
		"walking",
		"sprint",
		"jumping"
	]

func on_enter() -> void:
	# Emit event when entering run state
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.movement_started.emit(Vector3.ZERO, speed)
