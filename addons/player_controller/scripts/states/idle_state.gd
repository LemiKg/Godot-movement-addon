class_name PCIdleState
extends PCPlayerStateBase

## Idle State - Player is standing still
## Handles transitions to movement states

func enter() -> void:
	pass

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
	
	# Transition to movement states based on input
	if input_direction.length() > 0.1:
		if Input.is_action_pressed("sprint"):
			state_manager.transition_to_state(StateManager.StateType.SPRINT)
		elif Input.is_action_pressed("run"):
			state_manager.transition_to_state(StateManager.StateType.RUNNING)
		else:
			state_manager.transition_to_state(StateManager.StateType.WALKING)
	
	# Check for crouch
	if Input.is_action_pressed("crouch"):
		state_manager.transition_to_state(StateManager.StateType.CROUCHING_IDLE)
	
	# Check if we're falling
	if not player.is_on_floor():
		state_manager.transition_to_state(StateManager.StateType.FALLING)

func get_movement_speed() -> float:
	if movement_controller:
		return movement_controller.get_speed_for_state(get_state_name())
	return 0.0 # Idle has no movement

func get_state_name() -> String:
	return "Idle"
