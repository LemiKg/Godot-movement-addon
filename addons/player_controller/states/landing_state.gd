class_name LandingState
extends EnhancedStateBase

## Landing State - Player just landed
## Same logic as original landing state with timed transition

var _landing_timer: float = 0.0
var _landing_duration: float = 0.2 # Same as original

func get_state_name() -> String:
	return "landing"

func get_movement_speed() -> float:
	return 0.0 # No movement during landing

func process_physics(delta: float) -> void:
	# Handle landing duration (same as original)
	_landing_timer += delta
	if _landing_timer >= _landing_duration:
		if state_machine and state_machine.has_method("transition_to_state"):
			state_machine.transition_to_state("idle")

func can_transition_to(new_state_name: String) -> bool:
	# Landing transitions to idle after duration (same as original)
	return new_state_name in ["idle", "walking", "running"]

func enter() -> void:
	super.enter()
	_landing_timer = 0.0
	# Set movement strategy to idle during landing
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("landing")
