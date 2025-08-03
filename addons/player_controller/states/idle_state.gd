class_name IdleState
extends EnhancedStateBase

## Idle State - Player is stationary
## Same logic as original idle state

func get_state_name() -> String:
	return "idle"

func get_movement_speed() -> float:
	return 0.0

func process_physics(delta: float) -> void:
	# Idle state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Idle can transition to most states (same as original)
	return new_state_name in [
		"walking",
		"running",
		"sprint",
		"jumping",
		"crouch_idle",
		"crouch_move"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to idle/walk
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("idle")
