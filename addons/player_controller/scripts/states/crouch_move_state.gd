class_name PCCrouchMoveState
extends PCPlayerStateBase

## Crouch Move State - Player is crouched and moving

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
	
	# Transition to crouch idle if no movement
	if input_direction.length() < 0.1:
		state_manager.transition_to_state(StateManager.StateType.CROUCHING_IDLE)
	
	# Exit crouch
	if not Input.is_action_pressed("crouch"):
		state_manager.transition_to_state(StateManager.StateType.WALKING)
	
	# Check if we're falling
	if not player.is_on_floor():
		state_manager.transition_to_state(StateManager.StateType.FALLING)

func get_movement_speed() -> float:
	if movement_controller:
		return movement_controller.get_speed_for_state("crouching_fwd")
	return 3.0 # Fallback crouch movement speed

func get_state_name() -> String:
	return "Crouch Move"
