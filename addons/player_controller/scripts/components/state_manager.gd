@tool
class_name StateManager
extends Node

## State Manager - Manages player state transitions
## Implements State Pattern and follows Open/Closed principle

# Preload the base state class to ensure it's available
const PCPlayerStateBase = preload("res://addons/player_controller/scripts/states/player_state_base.gd")

signal state_changed(old_state: PCPlayerStateBase, new_state: PCPlayerStateBase)

@export_group("State Configuration")
@export var default_state: StateType = StateType.IDLE
@export var debug_state_transitions: bool = false
@export var landing_duration: float = 0.2

@export_group("Advanced Settings")
@export var allow_state_overrides: bool = false

enum StateType {
	IDLE,
	WALKING,
	RUNNING,
	SPRINT,
	CROUCHING_IDLE,
	CROUCHING_FWD,
	JUMPING,
	FALLING,
	LANDING
}

var _current_state: PCPlayerStateBase
var _states: Dictionary = {}
var _player: CharacterBody3D
var _movement_controller: MovementController

func initialize(player: CharacterBody3D, movement_controller: MovementController = null) -> void:
	_player = player
	_movement_controller = movement_controller
	_setup_states()
	_transition_to_state(default_state)

func _setup_states() -> void:
	# Load and instantiate all state scripts
	_states[StateType.IDLE] = preload("res://addons/player_controller/scripts/states/idle_state.gd").new()
	_states[StateType.WALKING] = preload("res://addons/player_controller/scripts/states/walking_state.gd").new()
	_states[StateType.RUNNING] = preload("res://addons/player_controller/scripts/states/running_state.gd").new()
	_states[StateType.SPRINT] = preload("res://addons/player_controller/scripts/states/sprint_state.gd").new()
	_states[StateType.CROUCHING_IDLE] = preload("res://addons/player_controller/scripts/states/crouch_idle_state.gd").new()
	_states[StateType.CROUCHING_FWD] = preload("res://addons/player_controller/scripts/states/crouch_move_state.gd").new()
	_states[StateType.JUMPING] = preload("res://addons/player_controller/scripts/states/jumping_state.gd").new()
	_states[StateType.FALLING] = preload("res://addons/player_controller/scripts/states/falling_state.gd").new()
	_states[StateType.LANDING] = preload("res://addons/player_controller/scripts/states/landing_state.gd").new()
	
	# Initialize all states
	for state in _states.values():
		state.player = _player
		state.state_manager = self
		state.movement_controller = _movement_controller

func process_physics(delta: float) -> void:
	if _current_state:
		_current_state.process_physics(delta)

func handle_input(event: InputEvent) -> void:
	if _current_state:
		_current_state.handle_input(event)

func transition_to_state(new_state_type: StateType) -> void:
	if new_state_type in _states:
		_transition_to_state(new_state_type)

func _transition_to_state(new_state_type: StateType) -> void:
	var new_state = _states[new_state_type]
	
	if _current_state == new_state:
		return
		
	if _current_state and not _current_state.can_transition_to(new_state_type):
		if debug_state_transitions:
			print("[StateManager] Transition blocked: %s -> %s" % [_current_state.get_state_name(), new_state.get_state_name()])
		return
	
	var old_state = _current_state
	
	# Exit current state
	if _current_state:
		_current_state.exit()
	
	# Enter new state
	_current_state = new_state
	_current_state.enter()
	
	# Log transition if debug mode is enabled
	log_state_transition(old_state, _current_state)
	
	# Emit signal
	state_changed.emit(old_state, _current_state)

func get_current_state() -> PCPlayerStateBase:
	return _current_state

func get_current_state_type() -> StateType:
	for state_type in _states:
		if _states[state_type] == _current_state:
			return state_type
	return StateType.IDLE

func is_in_state(state_type: StateType) -> bool:
	return get_current_state_type() == state_type

func can_move() -> bool:
	if _current_state:
		return get_current_state_type() in [
			StateType.IDLE,
			StateType.WALKING,
			StateType.RUNNING,
			StateType.SPRINT,
			StateType.CROUCHING_FWD
		]
	return false

func can_jump() -> bool:
	if _current_state:
		return get_current_state_type() in [
			StateType.IDLE,
			StateType.WALKING,
			StateType.RUNNING,
			StateType.SPRINT
		] and _player.is_on_floor()
	return false

func get_movement_speed() -> float:
	if _current_state:
		return _current_state.get_movement_speed()
	return 5.0

func set_debug_mode(enabled: bool) -> void:
	"""Enable or disable debug mode for state transitions"""
	debug_state_transitions = enabled

func log_state_transition(from_state: PCPlayerStateBase, to_state: PCPlayerStateBase) -> void:
	"""Log state transitions when debug mode is enabled"""
	if debug_state_transitions:
		var from_name = from_state.get_state_name() if from_state else "None"
		var to_name = to_state.get_state_name() if to_state else "None"
		print("[StateManager] Transition: %s -> %s" % [from_name, to_name])
