class_name PCPlayerStateBase
extends Resource

## Base class for all player states following the State Pattern
## Implements SOLID principles by providing a common interface for all states

var player: CharacterBody3D
var state_manager: StateManager
var movement_controller: MovementController

func enter() -> void:
	"""Called when entering this state"""
	pass
	
func exit() -> void:
	"""Called when exiting this state"""
	pass
	
func process_physics(_delta: float) -> void:
	"""Called every physics frame while in this state"""
	pass
	
func handle_input(_event: InputEvent) -> void:
	"""Handle input events specific to this state"""
	pass
	
func can_transition_to(_new_state_type: int) -> bool:
	"""Override to define valid state transitions"""
	return true

func get_state_name() -> String:
	"""Return the name of this state for debugging"""
	return "BaseState"

func get_movement_speed() -> float:
	"""Override to define movement speed for this state"""
	if movement_controller:
		return movement_controller.get_speed_for_state(get_state_name())
	return 5.0 # Fallback default speed
