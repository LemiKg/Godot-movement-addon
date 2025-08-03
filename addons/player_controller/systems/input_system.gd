class_name EnhancedInputSystem
extends Node

## Enhanced Input System - Event-driven input handling
## Maintains same input logic as original but with event bus communication

signal input_processed(input_data: Dictionary)

@export_group("Input Settings")
@export var input_threshold: float = 0.2
@export var mouse_sensitivity: float = 0.002
@export var invert_mouse_y: bool = false

@export_group("Input Buffers")
@export var jump_buffer_time: float = 0.2

var _current_input_vector: Vector2 = Vector2.ZERO
var _is_sprinting: bool = false
var _is_crouching: bool = false
var _jump_just_pressed: bool = false

var _state_machine: Node
var _movement_system: Node

func initialize(state_machine: Node, movement_system: Node) -> void:
	_state_machine = state_machine
	_movement_system = movement_system
	
	# Connect to event bus if available
	_connect_events()

func _connect_events() -> void:
	# We'll connect to events when EventBus is properly set up
	pass

func _ready() -> void:
	set_process_unhandled_input(true)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	# Process input every physics frame
	_process_movement_input()
	_process_state_transitions()

func _unhandled_input(event: InputEvent) -> void:
	_handle_jump_input(event)

func _process_movement_input() -> void:
	# Get movement input (same as original system)
	var input_vector = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1.0
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1.0
	if Input.is_action_pressed("move_forward"):
		input_vector.y += 1.0 # Fixed: forward should be positive
	if Input.is_action_pressed("move_backward"):
		input_vector.y -= 1.0 # Fixed: backward should be negative
	
	# Update sprint and crouch state every frame (same as original)
	_is_sprinting = Input.is_action_pressed("sprint")
	_is_crouching = Input.is_action_pressed("crouch")
	
	# Normalize input vector
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()
	
	_current_input_vector = input_vector
	
	# Send input to movement system
	if _movement_system and _movement_system.has_method("process_movement"):
		_movement_system.process_movement(_current_input_vector, get_physics_process_delta_time())

func _process_state_transitions() -> void:
	# Request state changes based on current input
	if _state_machine and _state_machine.has_method("request_movement_state"):
		_state_machine.request_movement_state(_current_input_vector, _is_sprinting, _is_crouching)

func _handle_jump_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		_jump_just_pressed = true
		
		# Request jump from state machine
		if _state_machine and _state_machine.has_method("request_jump"):
			_state_machine.request_jump()
		
		# Request jump from movement system for buffering
		if _movement_system and _movement_system.has_method("request_jump"):
			_movement_system.request_jump()

# Getter methods
func get_input_vector() -> Vector2:
	return _current_input_vector

func is_sprinting() -> bool:
	return _is_sprinting

func is_crouching() -> bool:
	return _is_crouching

func was_jump_just_pressed() -> bool:
	var result = _jump_just_pressed
	_jump_just_pressed = false # Reset after checking
	return result
