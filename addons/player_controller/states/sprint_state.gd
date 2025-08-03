class_name SprintState
extends EnhancedStateBase

## Sprint State - Player is sprinting
## Same logic as original sprint state

func get_state_name() -> String:
	return "sprint"

func get_movement_speed() -> float:
	return 12.0 # SPRINT_SPEED from original

func process_physics(delta: float) -> void:
	# Sprint state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Sprint can transition to other movement states (same as original)
	return new_state_name in [
		"idle",
		"walking",
		"running",
		"jumping"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to sprint
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("sprint")
