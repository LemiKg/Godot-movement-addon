class_name PCLandingState
extends PCPlayerStateBase

## Landing State - Player just landed from a fall/jump

var _landing_timer: float = 0.0
var _landing_duration: float = 0.2 # Default, will be overridden by StateManager config

func enter() -> void:
	_landing_timer = 0.0
	# Get the configured landing duration from state manager
	if state_manager:
		_landing_duration = state_manager.landing_duration

func process_physics(delta: float) -> void:
	_landing_timer += delta
	
	# After landing duration, check what state to transition to
	if _landing_timer >= _landing_duration:
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
		if input_direction.length() > 0.1:
			if Input.is_action_pressed("sprint"):
				state_manager.transition_to_state(StateManager.StateType.SPRINT)
			elif Input.is_action_pressed("run"):
				state_manager.transition_to_state(StateManager.StateType.RUNNING)
			else:
				state_manager.transition_to_state(StateManager.StateType.WALKING)
		else:
			state_manager.transition_to_state(StateManager.StateType.IDLE)

func get_movement_speed() -> float:
	return 0.0 # No movement during landing

func get_state_name() -> String:
	return "Landing"
