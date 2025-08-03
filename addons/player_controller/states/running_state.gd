class_name RunningState
extends EnhancedStateBase

## Running State - Player is running
## Same logic as original running state

func get_state_name() -> String:
	return "running"

func get_movement_speed() -> float:
	return 8.0 # RUN_SPEED from original

func process_physics(delta: float) -> void:
	# Running state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Running can transition to other movement states (same as original)
	return new_state_name in [
		"idle",
		"walking",
		"sprint",
		"jumping"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to run
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("running")
