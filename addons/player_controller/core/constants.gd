class_name MovementConstants
extends RefCounted

## Constants for the enhanced movement system
## Centralized configuration values

# Movement State Enum
enum MovementState {
	IDLE,
	WALKING,
	RUNNING,
	SPRINT,
	CROUCH_IDLE,
	CROUCH_MOVE,
	JUMPING,
	FALLING,
	LANDING
}

# Movement Strategy Enum
enum MovementStrategy {
	WALK,
	RUN,
	SPRINT,
	CROUCH,
	JUMP,
	FALL
}

# Camera Mode Enum
enum CameraMode {
	FIRST_PERSON,
	THIRD_PERSON
}

# Camera Strategy Enum
enum CameraStrategy {
	DEFAULT,
	CROUCH,
	SPRINT
}

# State Names (for compatibility with string-based systems)
const STATE_IDLE = "idle"
const STATE_WALKING = "walking"
const STATE_RUNNING = "running"
const STATE_SPRINT = "sprint"
const STATE_CROUCH_IDLE = "crouch_idle"
const STATE_CROUCH_MOVE = "crouch_move"
const STATE_JUMPING = "jumping"
const STATE_FALLING = "falling"
const STATE_LANDING = "landing"

# Movement Strategy Types
const STRATEGY_WALK = "walk"
const STRATEGY_RUN = "run"
const STRATEGY_SPRINT = "sprint"
const STRATEGY_CROUCH = "crouch"
const STRATEGY_JUMP = "jump"
const STRATEGY_FALL = "fall"

# Camera Strategy Types
const CAMERA_FIRST_PERSON = "first_person"
const CAMERA_THIRD_PERSON = "third_person"

# Input Constants
const INPUT_THRESHOLD = 0.2
const JUMP_BUFFER_DEFAULT = 0.2
const COYOTE_TIME_DEFAULT = 0.2

# Physics Constants
const GRAVITY_DEFAULT = 9.8
const ACCELERATION_DEFAULT = 20.0
const ROTATION_SPEED_DEFAULT = 20.0

# Speed Constants (matching original system)
const WALK_SPEED = 5.0
const RUN_SPEED = 8.0
const SPRINT_SPEED = 12.0
const CROUCH_SPEED = 3.0
const JUMP_VELOCITY = 4.5
const AIR_CONTROL_SPEED = 5.0

# Camera Constants
const LANDING_DURATION = 0.2

# Debug Categories
const DEBUG_STATE = "STATE"
const DEBUG_MOVEMENT = "MOVEMENT"
const DEBUG_CAMERA = "CAMERA"
const DEBUG_INPUT = "INPUT"
const DEBUG_SYSTEM = "SYSTEM"

# Utility functions for enum to string conversion
static func movement_state_to_string(state: MovementState) -> String:
	match state:
		MovementState.IDLE: return STATE_IDLE
		MovementState.WALKING: return STATE_WALKING
		MovementState.RUNNING: return STATE_RUNNING
		MovementState.SPRINT: return STATE_SPRINT
		MovementState.CROUCH_IDLE: return STATE_CROUCH_IDLE
		MovementState.CROUCH_MOVE: return STATE_CROUCH_MOVE
		MovementState.JUMPING: return STATE_JUMPING
		MovementState.FALLING: return STATE_FALLING
		MovementState.LANDING: return STATE_LANDING
		_: return STATE_IDLE

static func string_to_movement_state(state_string: String) -> MovementConstants.MovementState:
	match state_string:
		STATE_IDLE: return MovementState.IDLE
		STATE_WALKING: return MovementState.WALKING
		STATE_RUNNING: return MovementState.RUNNING
		STATE_SPRINT: return MovementState.SPRINT
		STATE_CROUCH_IDLE: return MovementState.CROUCH_IDLE
		STATE_CROUCH_MOVE: return MovementState.CROUCH_MOVE
		STATE_JUMPING: return MovementState.JUMPING
		STATE_FALLING: return MovementState.FALLING
		STATE_LANDING: return MovementState.LANDING
		_: return MovementState.IDLE

static func movement_strategy_to_string(strategy: MovementConstants.MovementStrategy) -> String:
	match strategy:
		MovementStrategy.WALK: return STRATEGY_WALK
		MovementStrategy.RUN: return STRATEGY_RUN
		MovementStrategy.SPRINT: return STRATEGY_SPRINT
		MovementStrategy.CROUCH: return STRATEGY_CROUCH
		MovementStrategy.JUMP: return STRATEGY_JUMP
		MovementStrategy.FALL: return STRATEGY_FALL
		_: return STRATEGY_WALK

static func string_to_movement_strategy(strategy_string: String) -> MovementConstants.MovementStrategy:
	match strategy_string:
		STRATEGY_WALK: return MovementStrategy.WALK
		STRATEGY_RUN: return MovementStrategy.RUN
		STRATEGY_SPRINT: return MovementStrategy.SPRINT
		STRATEGY_CROUCH: return MovementStrategy.CROUCH
		STRATEGY_JUMP: return MovementStrategy.JUMP
		STRATEGY_FALL: return MovementStrategy.FALL
		_: return MovementStrategy.WALK

# State to Strategy Mapping Helper
class StateStrategyMapper:
	static var _state_to_strategy_map: Dictionary = {
		MovementConstants.STATE_IDLE: MovementConstants.STRATEGY_WALK,
		MovementConstants.STATE_WALKING: MovementConstants.STRATEGY_WALK,
		MovementConstants.STATE_RUNNING: MovementConstants.STRATEGY_RUN,
		MovementConstants.STATE_SPRINT: MovementConstants.STRATEGY_SPRINT,
		MovementConstants.STATE_CROUCH_IDLE: MovementConstants.STRATEGY_CROUCH,
		MovementConstants.STATE_CROUCH_MOVE: MovementConstants.STRATEGY_CROUCH,
		MovementConstants.STATE_JUMPING: MovementConstants.STRATEGY_JUMP,
		MovementConstants.STATE_FALLING: MovementConstants.STRATEGY_FALL,
		MovementConstants.STATE_LANDING: MovementConstants.STRATEGY_WALK
	}
	
	static func get_strategy_for_state(state: String) -> String:
		return _state_to_strategy_map.get(state, MovementConstants.STRATEGY_WALK)
	
	static func has_strategy_for_state(state: String) -> bool:
		return state in _state_to_strategy_map
