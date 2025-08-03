class_name WalkingState
extends EnhancedStateBase

## Walking State - Player is walking
## Same logic as original walking state

func get_state_name() -> String:
	return "walking"

func get_movement_speed() -> float:
	return 5.0 # WALK_SPEED from original

func process_physics(delta: float) -> void:
	# Walking state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Walking can transition to most states (same as original)
	return new_state_name in [
		"idle",
		"running",
		"sprint",
		"jumping",
		"crouch_idle",
		"crouch_move"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to walk
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("walking")
