class_name PCJumpingState
extends PCPlayerStateBase

## Jumping State - Player is in the air after jumping

func enter() -> void:
	# Apply jump velocity when entering this state
	if player and movement_controller:
		player.velocity.y = movement_controller.jump_velocity
	elif player:
		player.velocity.y = 4.5 # Fallback jump velocity

func process_physics(_delta: float) -> void:
	# Check if we're falling (velocity going down)
	if player.velocity.y <= 0:
		state_manager.transition_to_state(StateManager.StateType.FALLING)

func can_transition_to(new_state_type: StateManager.StateType) -> bool:
	# Can only transition to falling state from jumping
	return new_state_type == StateManager.StateType.FALLING

func get_movement_speed() -> float:
	if movement_controller:
		return movement_controller.get_speed_for_state(get_state_name())
	return 5.0 # Fallback air control speed

func get_state_name() -> String:
	return "Jumping"
