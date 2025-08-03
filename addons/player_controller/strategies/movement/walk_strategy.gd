class_name WalkMovementStrategy
extends MovementStrategy

## Walking movement strategy
## Implements the exact same walking calculations as the original system

func _init():
	speed = 5.0 # MovementConstants.WALK_SPEED
	acceleration = 20.0 # MovementConstants.ACCELERATION_DEFAULT
	can_jump = true
	air_control = false

func get_strategy_name() -> String:
	return "walk"

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	# Rotation is now handled centrally by MovementSystem to support strafe mode
	pass

func can_transition_to(state_name: String) -> bool:
	# Walking can transition to most states
	return state_name in [
		"idle",
		"running",
		"sprint",
		"jumping",
		"crouch_idle",
		"crouch_move"
	]

func on_enter() -> void:
	# Emit event when entering walk state
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.movement_started.emit(Vector3.ZERO, speed)
