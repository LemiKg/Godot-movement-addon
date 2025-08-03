class_name EnhancedStateMachine
extends Node

## Enhanced State Machine - Event-driven state management
## Maintains same state logic as original but with event bus communication

signal state_changed(old_state: String, new_state: String)

@export_group("State Configuration")
@export var default_state: String = "idle"
@export var debug_state_transitions: bool = false
@export var landing_duration: float = 0.2

@export_group("Advanced Settings")
@export var allow_state_overrides: bool = false

var _current_state: String = ""
var _previous_state: String = ""
var _state_timer: float = 0.0

var _player: CharacterBody3D
var _movement_system: Node
var _input_system: Node

# State transition rules (same logic as original)
var _valid_transitions: Dictionary = {
	"idle": ["walking", "running", "sprint", "jumping", "crouch_idle"],
	"walking": ["idle", "running", "sprint", "jumping", "crouch_idle", "crouch_move"],
	"running": ["idle", "walking", "sprint", "jumping"],
	"sprint": ["idle", "walking", "running", "jumping"],
	"crouch_idle": ["idle", "walking", "crouch_move"],
	"crouch_move": ["crouch_idle", "idle", "walking"],
	"jumping": ["falling", "landing"],
	"falling": ["landing"],
	"landing": ["idle", "walking", "running"]
}

func initialize(player: CharacterBody3D, movement_system: Node, input_system: Node = null) -> void:
	_player = player
	_movement_system = movement_system
	_input_system = input_system
	
	# Connect to event bus if available
	_connect_events()
	
	# Set initial state
	transition_to_state(default_state)

func _connect_events() -> void:
	# We'll connect to events when EventBus is properly set up
	pass

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	_state_timer += delta
	_update_state_logic(delta)

func _update_state_logic(delta: float) -> void:
	# Handle automatic state transitions based on player conditions
	match _current_state:
		"jumping":
			if _player.velocity.y < 0:
				transition_to_state("falling")
		
		"falling":
			if _player.is_on_floor():
				transition_to_state("landing")
		
		"landing":
			if _state_timer >= landing_duration:
				transition_to_state("idle")

func transition_to_state(new_state: String, force: bool = false) -> void:
	if new_state == _current_state:
		return
	
	# Check if transition is valid
	if not force and not _can_transition_to(new_state):
		if debug_state_transitions:
			print("[StateMachine] Transition blocked: %s -> %s" % [_current_state, new_state])
		return
	
	# Perform transition
	var old_state = _current_state
	_previous_state = _current_state
	_current_state = new_state
	_state_timer = 0.0
	
	# Update movement system
	if _movement_system:
		_movement_system.set_movement_state(_current_state)
	
	# Log transition if debug mode is enabled
	if debug_state_transitions:
		print("[StateMachine] Transition: %s -> %s" % [old_state, _current_state])
	
	# Emit signals
	state_changed.emit(old_state, _current_state)

func _can_transition_to(new_state: String) -> bool:
	if _current_state == "":
		return true
	
	if _current_state in _valid_transitions:
		return new_state in _valid_transitions[_current_state]
	
	return true

func get_current_state() -> String:
	return _current_state

func get_previous_state() -> String:
	return _previous_state

func is_in_state(state: String) -> bool:
	return _current_state == state

func can_move() -> bool:
	return _current_state in ["idle", "walking", "running", "sprint", "crouch_move"]

func can_jump() -> bool:
	return _current_state in ["idle", "walking", "running", "sprint"] and _player.is_on_floor()

func get_state_timer() -> float:
	return _state_timer

# State transition request handlers (will be connected to events)
func request_movement_state(input_direction: Vector2, is_sprinting: bool, is_crouching: bool) -> void:
	var input_magnitude = input_direction.length()
	
	if is_crouching:
		if input_magnitude > 0.1:
			transition_to_state("crouch_move")
		else:
			transition_to_state("crouch_idle")
	elif input_magnitude > 0.1:
		if is_sprinting:
			transition_to_state("sprint")
		elif input_magnitude > 0.7:
			transition_to_state("running")
		else:
			transition_to_state("walking")
	else:
		transition_to_state("idle")

func request_jump() -> void:
	if can_jump():
		transition_to_state("jumping")
		if _movement_system:
			_movement_system.execute_jump()

func set_debug_mode(enabled: bool) -> void:
	debug_state_transitions = enabled
