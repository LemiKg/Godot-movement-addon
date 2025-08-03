class_name FallingState
extends EnhancedStateBase

## Falling State - Player is falling
## Same logic as original falling state

func get_state_name() -> String:
	return "falling"

func get_movement_speed() -> float:
	return 5.0 # FALLING_AIR_CONTROL_SPEED from original

func process_physics(delta: float) -> void:
	# Check if we should transition to landing (same as original)
	if player and player.is_on_floor():
		if state_machine and state_machine.has_method("transition_to_state"):
			state_machine.transition_to_state("landing")

func can_transition_to(new_state_name: String) -> bool:
	# Falling can only transition to landing (same as original)
	return new_state_name in ["landing"]

func enter() -> void:
	super.enter()
	# Set movement strategy to fall
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("falling")
