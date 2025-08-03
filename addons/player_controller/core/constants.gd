class_name EnhancedMovementConstants
extends RefCounted

## Constants for the enhanced movement system
## Centralized configuration values

# State Names
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
const CAMERA_DEFAULT = "default"
const CAMERA_CROUCH = "crouch"
const CAMERA_SPRINT = "sprint"

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
