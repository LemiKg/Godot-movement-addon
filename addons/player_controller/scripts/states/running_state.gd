class_name PCRunningState
extends PCPlayerStateBase

## Running State - Player is moving at increased speed

func process_physics(_delta: float) -> void:
	# Check for movement input
	var input_direction = Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_direction.y += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
	
	# Transition based on input
	if input_direction.length() < 0.1:
		state_manager.transition_to_state(StateManager.StateType.IDLE)
	elif Input.is_action_pressed("sprint"):
		state_manager.transition_to_state(StateManager.StateType.SPRINT)
	elif not Input.is_action_pressed("run"):
		state_manager.transition_to_state(StateManager.StateType.WALKING)
	
	# Check if we're falling
	if not player.is_on_floor():
		state_manager.transition_to_state(StateManager.StateType.FALLING)

func get_movement_speed() -> float:
	if movement_controller:
		return movement_controller.get_speed_for_state(get_state_name())
	return 8.0 # Fallback for running speed

func get_state_name() -> String:
	return "Running"
