@tool
class_name InputHandler
extends Node

## Input Handler Component - Single Responsibility: Handle all player input
## Emits signals instead of directly modifying state (Dependency Inversion)

signal movement_input_changed(direction: Vector2)
signal jump_requested
signal crouch_toggled(is_crouching: bool)
signal run_toggled(is_running: bool)
signal sprint_toggled(is_sprinting: bool)
signal camera_input(mouse_delta: Vector2)
signal interact_requested
signal mouse_mode_toggle_requested
signal camera_mode_toggle_requested
signal zoom_requested(zoom_direction: float)

@export_group("Input Settings")
@export var mouse_sensitivity := 2.0: ## Mouse sensitivity multiplier. Higher values = faster camera movement
	set(value):
		mouse_sensitivity = clamp(value, 0.1, 10.0) # Reasonable range for mouse sensitivity
@export var input_buffer_time := 0.2 ## Time in seconds to buffer inputs like jump and interact

var _is_crouching := false
var _is_running := false
var _is_sprinting := false
var _input_buffer := {} # Dictionary to store buffered inputs with timestamps

func _ready() -> void:
	set_process_unhandled_input(true)
	# Connect to own signal to handle mouse mode changes
	mouse_mode_toggle_requested.connect(_toggle_mouse_mode)

func _input(event: InputEvent) -> void:
	# Don't process input in the editor
	if Engine.is_editor_hint():
		return
		
	# Handle mouse capture - only use left click and escape
	if event.is_action_pressed("left_click") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		mouse_mode_toggle_requested.emit()
	elif event.is_action_released("ui_cancel") or (event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed):
		mouse_mode_toggle_requested.emit()

func _unhandled_input(event: InputEvent) -> void:
	# Don't process input in the editor
	if Engine.is_editor_hint():
		return
		
	_handle_camera_input(event)
	_handle_zoom_input(event)

func _process(_delta: float) -> void:
	# Don't process input in the editor
	if Engine.is_editor_hint():
		return
	
	_handle_movement_input()
	_handle_action_input()

func _handle_movement_input() -> void:
	# Check if all movement actions exist before using them
	if not InputMap.has_action("move_left") or not InputMap.has_action("move_right") or \
	   not InputMap.has_action("move_forward") or not InputMap.has_action("move_backward"):
		movement_input_changed.emit(Vector2.ZERO)
		return
		
	var movement_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	movement_input_changed.emit(movement_direction)

func _handle_action_input() -> void:
	# Clean expired buffer entries
	_clean_input_buffer()
	
	# Jump input with buffering
	if InputMap.has_action("jump"):
		if Input.is_action_just_pressed("jump"):
			_input_buffer["jump"] = Time.get_ticks_msec() / 1000.0
			jump_requested.emit()
		elif _input_buffer.has("jump"):
			jump_requested.emit()
			_input_buffer.erase("jump")
	
	# Crouch input
	if InputMap.has_action("crouch"):
		var crouch_pressed = Input.is_action_pressed("crouch")
		if crouch_pressed != _is_crouching:
			_is_crouching = crouch_pressed
			crouch_toggled.emit(_is_crouching)
	
	# Run input
	if InputMap.has_action("run"):
		var run_pressed = Input.is_action_pressed("run")
		if run_pressed != _is_running:
			_is_running = run_pressed
			run_toggled.emit(_is_running)
	
	# Sprint input
	if InputMap.has_action("sprint"):
		var sprint_pressed = Input.is_action_pressed("sprint")
		if sprint_pressed != _is_sprinting:
			_is_sprinting = sprint_pressed
			sprint_toggled.emit(_is_sprinting)
	
	# Interact input with buffering
	if InputMap.has_action("interact"):
		if Input.is_action_just_pressed("interact"):
			_input_buffer["interact"] = Time.get_ticks_msec() / 1000.0
			interact_requested.emit()
		elif _input_buffer.has("interact"):
			interact_requested.emit()
			_input_buffer.erase("interact")
	
	# Camera mode toggle
	if InputMap.has_action("toggle_camera_mode"):
		if Input.is_action_just_pressed("toggle_camera_mode"):
			camera_mode_toggle_requested.emit()

func _handle_camera_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Apply mouse sensitivity to the raw mouse delta
		# event.screen_relative gives mouse movement in screen coordinates
		var mouse_delta = event.screen_relative * mouse_sensitivity * 0.001 # Scale down for reasonable values
		camera_input.emit(mouse_delta)

func _handle_zoom_input(event: InputEvent) -> void:
	# Handle mouse wheel zoom
	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_requested.emit(-1.0) # Zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_requested.emit(1.0) # Zoom out
	
	# Handle keyboard zoom (optional)
	if InputMap.has_action("zoom_in") and Input.is_action_just_pressed("zoom_in"):
		zoom_requested.emit(-1.0)
	elif InputMap.has_action("zoom_out") and Input.is_action_just_pressed("zoom_out"):
		zoom_requested.emit(1.0)

func get_movement_input() -> Vector2:
	# Check if all movement actions exist before using them
	if not InputMap.has_action("move_left") or not InputMap.has_action("move_right") or \
	   not InputMap.has_action("move_forward") or not InputMap.has_action("move_backward"):
		return Vector2.ZERO
		
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

func is_crouching() -> bool:
	return _is_crouching

func is_running() -> bool:
	return _is_running

func is_sprinting() -> bool:
	return _is_sprinting

func _toggle_mouse_mode() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _clean_input_buffer() -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	var keys_to_remove = []
	for action in _input_buffer:
		if current_time - _input_buffer[action] > input_buffer_time:
			keys_to_remove.append(action)
	for key in keys_to_remove:
		_input_buffer.erase(key)
