class_name EnhancedStateBase
extends Resource

## Base class for all enhanced player states
## Implements the State Pattern with event-driven communication

var player: CharacterBody3D
var state_machine: Node
var movement_system: Node
var camera_system: Node

func enter() -> void:
	"""Called when entering this state"""
	# Emit event through state machine if available
	if state_machine and state_machine.has_method("emit_state_event"):
		state_machine.emit_state_event("state_enter", get_state_name())

func exit() -> void:
	"""Called when exiting this state"""
	# Emit event through state machine if available
	if state_machine and state_machine.has_method("emit_state_event"):
		state_machine.emit_state_event("state_exit", get_state_name())

func process_physics(delta: float) -> void:
	"""Called every physics frame while in this state"""
	pass

func handle_input(event: InputEvent) -> void:
	"""Handle input events specific to this state"""
	pass

func can_transition_to(new_state_name: String) -> bool:
	"""Override to define valid state transitions"""
	return true

func get_state_name() -> String:
	"""Return the name of this state for debugging"""
	return "base_state"

func get_movement_speed() -> float:
	"""Override to define movement speed for this state"""
	return 5.0
