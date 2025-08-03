# Advanced Player Controller

A modular, component-based 3D player controller for Godot 4.x that follows SOLID principles and provides extensive configurability for easy customization and extension.

## Features

- **🏗️ Component-Based Architecture**: Fully modular design with single-responsibility components
- **🎯 State Management**: Clean state pattern with configurable transitions and timing
- **⚙️ Extensive Configurability**: All components feature comprehensive export properties
- **🎮 Advanced Input System**: Buffered input handling with configurable sensitivity and timing
- **🎬 Flexible Animation System**: Fully configurable animation mapping and parameters
- **📷 Dual Camera Modes**: Seamless first/third-person switching with transitions
- **🔧 Configuration Consolidation**: Single source of truth for all settings
- **🎨 SOLID Principles**: Maintainable, extensible, and testable architecture

## Installation

1. Copy the `addons/player_controller` folder to your project's `addons/` directory
2. Enable the plugin in Project Settings → Plugins → Advanced Player Controller
3. The custom node types will be available in the Create Node dialog

## Quick Start

### Method 1: Use the Prefab Scene (Recommended)
1. Instance `res://addons/player_controller/scenes/PlayerController.tscn` in your scene
2. Configure the components via Inspector properties:
   - **MovementController**: Adjust speeds, jump settings, physics parameters
   - **InputHandler**: Set mouse sensitivity, input buffer times
   - **CameraController**: Configure camera limits, transition settings
   - **StateManager**: Set default state, enable debug mode
   - **AnimationController**: Map animation names, set speeds (optional)

### Method 2: Manual Setup
1. Add a CharacterBody3D node
2. Attach the PlayerController script
3. Create this node hierarchy:
```
PlayerController (CharacterBody3D)
├── CollisionShape3D
├── Character (Node3D) - Your 3D model
├── CameraPivot (Node3D)
│   └── SpringArm3D
│       └── Camera3D
└── Components (Node)
    ├── InputHandler
    ├── MovementController
    ├── CameraController
    ├── StateManager
    └── AnimationController (optional)
```

## Required Input Actions

Configure these input actions in Project Settings → Input Map:
- `move_forward` (W key)
- `move_backward` (S key)
- `move_left` (A key)
- `move_right` (D key)
- `jump` (Space key)
- `crouch` (Ctrl key)
- `run` (Shift key)
- `sprint` (Shift key)
- `toggle_camera_mode` (C key)
- `left_click` (Mouse left button)
- `ui_cancel` (Escape key)

## Components Overview

All components follow the single responsibility principle and are highly configurable through Inspector properties.

### 🎮 InputHandler
**Responsibility**: Capture and process all player input with buffering and sensitivity control.

**Key Export Properties**:
- `mouse_sensitivity` (2.0): Mouse look sensitivity
- `input_buffer_time` (0.2): Input buffering duration in seconds

**Signals Emitted**: 
- `movement_input_changed(Vector2)`
- `jump_requested()`
- `camera_input(Vector2)`
- `camera_mode_toggle_requested()`

### 🏃 MovementController  
**Responsibility**: Handle all movement calculations, physics, and speed management (Single Source of Truth for movement).

**Key Export Properties**:
- **Movement Speeds**: `walk_speed` (5.0), `run_speed` (8.0), `sprint_speed` (12.0), `crouch_speed` (3.0)
- **Physics**: `jump_velocity` (4.5), `gravity` (9.8), `acceleration` (20.0)
- **Air Control**: `jump_air_control_speed` (5.0), `falling_air_control_speed` (5.0)
- **Input Buffers**: `jump_buffer_time` (0.2), `coyote_time` (0.2)

### 📷 CameraController
**Responsibility**: Manage camera modes, transitions, and rotation limits.

**Key Export Properties**:
- **Camera Limits**: `pitch_limit_up` (30.0), `pitch_limit_down` (60.0)
- **Transitions**: `transition_duration` (0.3), `transition_curve`
- **Modes**: `default_mode` ("third_person")

**Features**: Seamless first/third-person switching, collision-aware SpringArm3D, smooth transitions

### 🔄 StateManager
**Responsibility**: Manage state transitions and state-specific logic using the State Pattern.

**Key Export Properties**:
- `default_state` (IDLE): Starting player state
- `debug_state_transitions` (false): Enable transition logging
- `landing_duration` (0.2): Landing state duration

**Available States**: Idle, Walking, Running, Sprint, Crouch (Idle/Move), Jumping, Falling, Landing

### 🎬 AnimationController (Optional)
**Responsibility**: Bridge player states to animation system with full configurability.

**Key Export Properties**:
- **Animation Mapping**: Configurable state-to-animation name mapping
- **Blend Parameters**: Configurable blend position parameter names  
- **Animation Speeds**: Per-state animation speed multipliers
- **Validation**: `validate_animation_tree` (true), `fallback_animation` ("Idle")

**Features**: Works with any AnimationTree structure, runtime reconfiguration, graceful fallbacks
Manages state transitions using the State Pattern.

**Available States:**
- Idle
- Walking
- Running
- Sprint
- Crouching (Idle/Moving)
- Jumping
- Falling
- Landing

### AnimationController (Optional)
Integrates with Godot's AnimationTree for character animations with comprehensive configurability.

**Animation Mapping (Configure animation names for each state):**
- `idle_animation_name`: Animation for idle state (default: "Idle")
- `walk_animation_name`: Animation for walking (default: "Walk")
- `run_animation_name`: Animation for running (default: "Walk")
- `sprint_animation_name`: Animation for sprinting (default: "Sprint")
- `jump_animation_name`: Animation for jumping (default: "Jump_Start")
- `crouch_idle_animation_name`: Animation for crouch idle (default: "Crouch_Idle")
- `crouch_move_animation_name`: Animation for crouch moving (default: "Crouch_Fwd")
- `falling_animation_name`: Animation for falling (default: "Walk")
- `landing_animation_name`: Animation for landing (default: "Jump_Land")

**Animation Parameters (Configure blend parameters):**
- `idle_blend_parameter`: Blend parameter for idle (default: "parameters/Idle/blend_position")
- `walk_blend_parameter`: Blend parameter for walking (default: "parameters/Walk/blend_position")
- `sprint_blend_parameter`: Blend parameter for sprinting (default: "parameters/Sprint/blend_position")

**Animation Settings:**
- `default_animation_speed`: Global animation speed multiplier (default: 1.0)
- `validate_animation_tree`: Validate animations exist in tree (default: true)
- `fallback_animation`: Animation to use if configured animation not found (default: "Idle")
- `enable_debug_logging`: Enable debug output for animations (default: false)

**Per-State Animation Speeds:**
- Individual speed multipliers for each animation state
- `idle_animation_speed`, `walk_animation_speed`, `run_animation_speed`, etc.

**Transition Settings:**
- `use_smooth_transitions`: Use smooth transitions between animations (default: true)
- `transition_duration`: Duration of transitions (default: 0.1)
- `enable_transition_validation`: Validate transitions before applying (default: true)

## Extending the System

### Adding New States
1. Create a new script extending `PCPlayerStateBase`
2. Override the required methods (`enter()`, `exit()`, `process_physics()`, `get_state_name()`)
3. Add the state to `StateManager.StateType` enum
4. Add the state to `StateManager._setup_states()`
5. Update `MovementController.get_speed_for_state()` if needed
6. Map animations in `AnimationController` if used

### Adding New Components
1. Create a script extending Node with `@tool` and `class_name`
2. Add component to PlayerController's Components node
3. Initialize in PlayerController's `_ready()` method
4. Connect signals in `_connect_signals()`
5. Follow single responsibility principle

## API Reference

### PlayerController Public Methods
```gdscript
# State queries
get_current_state() -> PCPlayerStateBase
is_in_state(state_type: StateManager.StateType) -> bool
can_move() -> bool
can_jump() -> bool

# Component access
get_movement_controller() -> MovementController
get_input_handler() -> InputHandler
get_camera_controller() -> CameraController
get_state_manager() -> StateManager
get_animation_controller() -> AnimationController
```

### StateManager API
```gdscript
# Manual state transitions
transition_to_state(new_state_type: StateType) -> void

# State queries
get_current_state() -> PCPlayerStateBase
get_current_state_type() -> StateType
is_in_state(state_type: StateType) -> bool

# Configuration
set_debug_mode(enabled: bool) -> void
```

### MovementController API
```gdscript
# Speed management (Single Source of Truth)
get_speed_for_state(state_name: String) -> float
set_speed_modifier(modifier: float) -> void

# Jump system
request_jump() -> void
can_jump() -> bool
execute_jump() -> void
```

### AnimationController API
```gdscript
# Animation control
transition_to_animation(animation_name: String) -> void
set_animation_parameter(parameter_name: String, value) -> void
set_animation_speed(speed: float) -> void

# Configuration
configure_animation_mapping(state_name: String, animation_name: String) -> void
set_blend_parameter(state_name: String, parameter_name: String) -> void
```

## Advanced Topics

### Animation System Setup
See `ANIMATION_CONFIGURATION_GUIDE.md` for detailed animation setup instructions.

### Configuration Consolidation
See `CONFIGURATION_CONSOLIDATION_GUIDE.md` for information about the single source of truth principle and how configurations are organized.

## Troubleshooting

### Common Issues
- **Input not responding**: Check Input Map actions are defined correctly
- **Animations not playing**: Verify AnimationTree structure matches configured names
- **Camera not moving**: Ensure mouse sensitivity is set appropriately (try 2.0)
- **State transitions not working**: Enable debug mode in StateManager to see transition logs

### Debug Features
- Enable `StateManager.debug_state_transitions` for state transition logging
- Enable `AnimationController.enable_debug_logging` for animation debugging
- Use `MovementController` debug draw options for physics visualization

## License

This addon is provided as-is for educational and commercial use.
