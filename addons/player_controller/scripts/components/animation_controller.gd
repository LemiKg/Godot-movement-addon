@tool
class_name AnimationController
extends Node

## Animation Controller Component - Single Responsibility: Handle animation logic
## Open/Closed: New animations can be added without modifying existing code

signal animation_finished(animation_name: String)
signal animation_event(event_name: String, event_data: Dictionary)

@export_group("Animation Mapping")
@export var idle_animation_name: String = "Idle"
@export var walk_animation_name: String = "Walk"
@export var run_animation_name: String = "Walk"
@export var sprint_animation_name: String = "Sprint"
@export var jump_animation_name: String = "Jump_Start"
@export var crouch_idle_animation_name: String = "Crouch_Idle"
@export var crouch_move_animation_name: String = "Crouch_Fwd"
@export var falling_animation_name: String = "Walk"
@export var landing_animation_name: String = "Jump_Land"

@export_group("Animation Parameters")
@export var idle_blend_parameter: String = "parameters/Idle/blend_position"
@export var walk_blend_parameter: String = "parameters/Walk/blend_position"
@export var run_blend_parameter: String = "parameters/Walk/blend_position"
@export var sprint_blend_parameter: String = "parameters/Sprint/blend_position"
@export var crouch_idle_blend_parameter: String = "parameters/Crouch_Idle/blend_position"
@export var crouch_move_blend_parameter: String = "parameters/Crouch_Fwd/blend_position"

@export_group("Animation Settings")
@export var default_animation_speed: float = 1.0
@export var validate_animation_tree: bool = true
@export var enable_animation_events: bool = false
@export var fallback_animation: String = "Idle"
@export var enable_debug_logging: bool = false

@export_group("Per-State Animation Speeds")
@export var idle_animation_speed: float = 1.0
@export var walk_animation_speed: float = 1.0
@export var run_animation_speed: float = 1.2
@export var sprint_animation_speed: float = 1.5
@export var jump_animation_speed: float = 1.0
@export var crouch_idle_animation_speed: float = 0.8
@export var crouch_move_animation_speed: float = 0.9
@export var falling_animation_speed: float = 1.0
@export var landing_animation_speed: float = 1.0

@export_group("Transition Settings")
@export var use_smooth_transitions: bool = true
@export var transition_duration: float = 0.1
@export var enable_transition_validation: bool = true

var _animation_tree: AnimationTree
var _state_machine: AnimationNodeStateMachinePlayback
var _current_animation: String = ""
var _animation_mapping: Dictionary = {}
var _blend_parameters: Dictionary = {}
var _animation_speeds: Dictionary = {}

func initialize(animation_tree: AnimationTree) -> void:
	_animation_tree = animation_tree
	if _animation_tree:
		_state_machine = _animation_tree.get("parameters/playback")
		_animation_tree.active = true
		
		# Validate animation tree if enabled
		if validate_animation_tree:
			_validate_animation_tree()
	
	# Build configuration dictionaries
	_build_animation_mapping()
	_build_blend_parameters()
	_build_animation_speeds()
	
	if enable_debug_logging:
		print("[AnimationController] Initialized with %d animations" % _animation_mapping.size())

func _build_animation_mapping() -> void:
	"""Build the animation mapping dictionary from export properties"""
	_animation_mapping = {
		"idle": idle_animation_name,
		"walking": walk_animation_name,
		"running": run_animation_name,
		"sprint": sprint_animation_name,
		"jumping": jump_animation_name,
		"crouch idle": crouch_idle_animation_name,
		"crouch move": crouch_move_animation_name,
		"falling": falling_animation_name,
		"landing": landing_animation_name
	}

func _build_blend_parameters() -> void:
	"""Build the blend parameters dictionary from export properties"""
	_blend_parameters = {
		"idle": idle_blend_parameter,
		"walking": walk_blend_parameter,
		"running": run_blend_parameter,
		"sprint": sprint_blend_parameter,
		"crouch idle": crouch_idle_blend_parameter,
		"crouch move": crouch_move_blend_parameter
	}

func _build_animation_speeds() -> void:
	"""Build the animation speeds dictionary from export properties"""
	_animation_speeds = {
		"idle": idle_animation_speed,
		"walking": walk_animation_speed,
		"running": run_animation_speed,
		"sprint": sprint_animation_speed,
		"jumping": jump_animation_speed,
		"crouch idle": crouch_idle_animation_speed,
		"crouch move": crouch_move_animation_speed,
		"falling": falling_animation_speed,
		"landing": landing_animation_speed
	}

func _validate_animation_tree() -> void:
	"""Validate that the animation tree contains the required animations"""
	if not _animation_tree:
		push_error("[AnimationController] Animation tree is null")
		return
	
	if not _state_machine:
		push_warning("[AnimationController] StateMachinePlayback not found. Ensure your AnimationTree has a StateMachine root.")
		return
	
	# Check if fallback animation exists
	if not _animation_exists(fallback_animation):
		push_warning("[AnimationController] Fallback animation '%s' not found in AnimationTree" % fallback_animation)

func _animation_exists(animation_name: String) -> bool:
	"""Check if an animation exists in the animation tree"""
	if not _state_machine:
		return false
	
	# This is a simplified check - in practice you'd want to inspect the StateMachine nodes
	return animation_name != ""

func update_animation_parameters(movement_amount: float) -> void:
	if not _animation_tree:
		return
	
	# Update blend positions for movement states based on configured parameters
	var current_state = get_current_animation().to_lower()
	if current_state in _blend_parameters:
		var blend_param = _blend_parameters[current_state]
		if blend_param != "":
			_animation_tree.set(blend_param, movement_amount)
			if enable_debug_logging:
				print("[AnimationController] Updated %s blend: %f" % [blend_param, movement_amount])

func transition_to_animation(animation_name: String) -> void:
	if not _state_machine:
		if enable_debug_logging:
			push_warning("[AnimationController] Cannot transition: StateMachine not available")
		return
	
	# Validate transition if enabled
	if enable_transition_validation and not _animation_exists(animation_name):
		if enable_debug_logging:
			push_warning("[AnimationController] Animation '%s' not found, using fallback '%s'" % [animation_name, fallback_animation])
		animation_name = fallback_animation
	
	# Apply animation speed for this state
	_apply_animation_speed(animation_name)
	
	# Perform transition
	if use_smooth_transitions:
		_state_machine.travel(animation_name)
	else:
		_state_machine.start(animation_name)
	
	_current_animation = animation_name
	
	if enable_debug_logging:
		print("[AnimationController] Transitioned to: %s" % animation_name)

func _apply_animation_speed(animation_name: String) -> void:
	"""Apply the configured speed for the given animation"""
	var state_key = _get_state_key_for_animation(animation_name)
	var speed = _animation_speeds.get(state_key, default_animation_speed)
	set_animation_speed(speed)

func _get_state_key_for_animation(animation_name: String) -> String:
	"""Get the state key that corresponds to the given animation name"""
	for state_key in _animation_mapping:
		if _animation_mapping[state_key] == animation_name:
			return state_key
	return "idle" # Default fallback

func play_animation(animation_name: String) -> void:
	if _state_machine:
		_apply_animation_speed(animation_name)
		_state_machine.start(animation_name)
		_current_animation = animation_name
		
		if enable_debug_logging:
			print("[AnimationController] Playing: %s" % animation_name)

func get_current_animation() -> String:
	if _state_machine:
		return _state_machine.get_current_node()
	return _current_animation

func is_animation_playing(animation_name: String) -> bool:
	return get_current_animation() == animation_name

func set_animation_parameter(parameter_name: String, value) -> void:
	if _animation_tree:
		_animation_tree.set(parameter_name, value)
		if enable_debug_logging:
			print("[AnimationController] Set parameter %s: %s" % [parameter_name, str(value)])

func get_animation_parameter(parameter_name: String):
	if _animation_tree:
		return _animation_tree.get(parameter_name)
	return null

func set_animation_speed(speed: float) -> void:
	if _animation_tree:
		_animation_tree.set("parameters/TimeScale/scale", speed)

# Configuration methods for runtime changes
func set_animation_mapping(state_name: String, animation_name: String) -> void:
	"""Change animation mapping at runtime"""
	_animation_mapping[state_name.to_lower()] = animation_name
	if enable_debug_logging:
		print("[AnimationController] Updated mapping: %s -> %s" % [state_name, animation_name])

func set_blend_parameter(state_name: String, parameter_name: String) -> void:
	"""Change blend parameter at runtime"""
	_blend_parameters[state_name.to_lower()] = parameter_name
	if enable_debug_logging:
		print("[AnimationController] Updated blend parameter: %s -> %s" % [state_name, parameter_name])

func set_state_animation_speed(state_name: String, speed: float) -> void:
	"""Change animation speed for a specific state at runtime"""
	_animation_speeds[state_name.to_lower()] = speed
	if enable_debug_logging:
		print("[AnimationController] Updated speed: %s -> %f" % [state_name, speed])

func get_animation_mapping() -> Dictionary:
	"""Get current animation mapping configuration"""
	return _animation_mapping.duplicate()

func get_available_animations() -> Array:
	"""Get list of all configured animation names"""
	return _animation_mapping.values()

# Convenience methods for common animations - now using configurable mapping
func play_idle_animation() -> void:
	transition_to_animation(_animation_mapping.get("idle", fallback_animation))

func play_walk_animation() -> void:
	transition_to_animation(_animation_mapping.get("walking", fallback_animation))

func play_run_animation() -> void:
	transition_to_animation(_animation_mapping.get("running", fallback_animation))

func play_sprint_animation() -> void:
	transition_to_animation(_animation_mapping.get("sprint", fallback_animation))

func play_jump_animation() -> void:
	transition_to_animation(_animation_mapping.get("jumping", fallback_animation))

func play_crouch_idle_animation() -> void:
	transition_to_animation(_animation_mapping.get("crouch idle", fallback_animation))

func play_crouch_move_animation() -> void:
	transition_to_animation(_animation_mapping.get("crouch move", fallback_animation))

func play_falling_animation() -> void:
	transition_to_animation(_animation_mapping.get("falling", fallback_animation))

func play_landing_animation() -> void:
	transition_to_animation(_animation_mapping.get("landing", fallback_animation))

# State change handler for connecting to StateManager - now fully configurable
func on_state_changed(_old_state: PCPlayerStateBase, new_state: PCPlayerStateBase) -> void:
	if not new_state:
		return
	
	var state_name = new_state.get_state_name().to_lower()
	
	# Use configurable animation mapping
	var animation_name = _animation_mapping.get(state_name, fallback_animation)
	
	if enable_debug_logging:
		print("[AnimationController] State changed to %s, playing animation: %s" % [state_name, animation_name])
	
	transition_to_animation(animation_name)
	
	# Emit animation event if enabled
	if enable_animation_events:
		animation_event.emit("state_changed", {
			"old_state": _old_state.get_state_name() if _old_state else "none",
			"new_state": state_name,
			"animation": animation_name
		})

# Animation event system
func trigger_animation_event(event_name: String, event_data: Dictionary = {}) -> void:
	"""Manually trigger an animation event"""
	if enable_animation_events:
		animation_event.emit(event_name, event_data)
		if enable_debug_logging:
			print("[AnimationController] Animation event: %s" % event_name)

# Validation and debugging methods
func validate_configuration() -> bool:
	"""Validate the current configuration and report issues"""
	var is_valid = true
	
	# Check if all configured animations exist
	for state_name in _animation_mapping:
		var animation_name = _animation_mapping[state_name]
		if animation_name == "":
			push_warning("[AnimationController] Empty animation name for state: %s" % state_name)
			is_valid = false
	
	# Check if animation tree is properly configured
	if not _animation_tree:
		push_error("[AnimationController] Animation tree not assigned")
		is_valid = false
	elif not _state_machine:
		push_error("[AnimationController] StateMachine playback not found in animation tree")
		is_valid = false
	
	if enable_debug_logging:
		print("[AnimationController] Configuration validation: %s" % ("PASSED" if is_valid else "FAILED"))
	
	return is_valid

func get_configuration_summary() -> Dictionary:
	"""Get a summary of the current configuration for debugging"""
	return {
		"animation_mapping": _animation_mapping,
		"blend_parameters": _blend_parameters,
		"animation_speeds": _animation_speeds,
		"fallback_animation": fallback_animation,
		"current_animation": get_current_animation(),
		"tree_active": _animation_tree.active if _animation_tree else false
	}
