class_name JumpingState
extends EnhancedStateBase

## Jumping State - Player is jumping
## Same logic as original jumping state

func get_state_name() -> String:
	return "jumping"

func get_movement_speed() -> float:
	return 5.0 # AIR_CONTROL_SPEED from original

func process_physics(delta: float) -> void:
	# Check if we should transition to falling (same as original)
	if player and player.velocity.y < 0:
		if state_machine and state_machine.has_method("transition_to_state"):
			state_machine.transition_to_state("falling")

func can_transition_to(new_state_name: String) -> bool:
	# Jumping can only transition to falling (same as original)
	return new_state_name in ["falling"]

func enter() -> void:
	super.enter()
	# Set movement strategy to jump
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("jumping")
