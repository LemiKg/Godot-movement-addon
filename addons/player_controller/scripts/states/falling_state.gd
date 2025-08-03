class_name PCFallingState
extends PCPlayerStateBase

## Falling State - Player is in the air and falling

func process_physics(_delta: float) -> void:
	# Check if we've landed
	if player.is_on_floor():
		state_manager.transition_to_state(StateManager.StateType.LANDING)

func get_movement_speed() -> float:
	if movement_controller:
		return movement_controller.get_speed_for_state(get_state_name())
	return 5.0 # Fallback air control speed

func get_state_name() -> String:
	return "Falling"
