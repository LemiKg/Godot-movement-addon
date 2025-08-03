# Godot Enhanced Movement Addon

A comprehensive, event-driven movement system addon for Godot 4 that provides advanced player controller functionality with decoupled architecture, strategy patterns, and flexible camera controls.

## 🚀 Features

### 🎮 **Complete Movement System**
- **Enhanced Player Controller**: Event-driven architecture with comprehensive movement
- **Advanced Camera System**: First/third-person camera with strafe mode and smooth transitions
- **State Management**: Robust state machine for all movement states
- **Input Handling**: Flexible input system with configurable controls
- **Strategy Pattern**: Interchangeable movement and camera behaviors

### 🏗️ **Architecture Highlights**
- **Event-Driven Communication**: Decoupled systems via EventBus singleton
- **Strategy Pattern**: Interchangeable movement and camera strategies
- **Service Locator**: Clean dependency injection and management
- **SOLID Principles**: Maintainable and extensible codebase
- **Modular Design**: Easy to customize and extend individual components

### 🎯 **Movement Features**
- **Multiple States**: Idle, Walking, Running, Sprint, Crouch, Jump, Fall, Landing
- **Smooth Transitions**: Fluid state changes with proper physics
- **Jump Buffering**: Better jump responsiveness
- **Coyote Time**: Jump grace period after leaving platforms
- **Air Control**: Adjustable mid-air movement control
- **Gravity Control**: Customizable gravity and fall speeds

### 📷 **Camera Features**
- **First Person**: Immersive FPS-style camera with customizable FOV
- **Third Person**: Over-the-shoulder camera with zoom and strafe modes
- **Smooth Transitions**: Seamless switching between camera modes
- **Configurable Controls**: Sensitivity, inversion, zoom settings
- **Strafe Mode**: Camera tilt during strafing for dynamic feel
- **Collision Detection**: Camera collision avoidance

## 📁 Project Structure

```
addons/
└── player_controller/          # Enhanced movement system
    ├── core/                   # Core architecture
    │   ├── event_bus.gd       # Global event communication
    │   ├── service_locator.gd # Dependency injection
    │   └── constants.gd       # Configuration constants
    ├── systems/               # Main system components
    │   ├── enhanced_movement_system.gd  # Advanced movement calculations
    │   ├── movement_system.gd           # Core movement logic
    │   ├── state_machine.gd             # State management
    │   ├── input_system.gd              # Input handling
    │   └── camera_system.gd             # Camera management
    ├── strategies/            # Strategy pattern implementations
    │   ├── movement/          # Movement behavior strategies
    │   └── camera/            # Camera behavior strategies
    ├── states/                # Movement state implementations
    ├── components/            # Main controller components
    │   └── enhanced_player_controller.gd # Main controller
    ├── scenes/                # Pre-configured scenes
    │   └── EnhancedPlayerController.tscn # Ready-to-use controller
    ├── plugin.gd             # Plugin registration
    └── plugin.cfg            # Plugin configuration

Assets/                        # Example assets
├── models/                    # 3D models and animations
└── Character/                 # Character assets

Levels/                        # Example levels
Scenes/                        # Example player scenes
```

## 🚀 Quick Start

### 1. Installation

1. Copy the `addons` folder to your project
2. Enable the plugin in **Project Settings → Plugins**:
   - **Player Movement Controller**

### 2. Input Map Setup

Ensure these actions exist in **Project Settings → Input Map**:

**Movement Controls:**
- `move_left` (A key)
- `move_right` (D key) 
- `move_forward` (W key)
- `move_backward` (S key)
- `jump` (Space key)
- `crouch` (Ctrl key)
- `run` (Shift key)
- `sprint` (Shift key)

**Camera Controls:**
- `toggle_camera_mode` (T key)
- `toggle_strafe_mode` (G key)

### 3. Scene Setup

#### Option A: Use Pre-built Scene (Recommended)
```gdscript
# Instance the pre-configured scene:
res://addons/player_controller/scenes/EnhancedPlayerController.tscn
```

#### Option B: Manual Setup
```gdscript
# Create a new scene with this structure:
PlayerController (CharacterBody3D)
├── EnhancedPlayerController (Script: enhanced_player_controller.gd)
├── CollisionShape3D
│   └── CapsuleShape3D
├── MeshInstance3D (Player model)
├── CameraPivot (Node3D)
│   └── SpringArm3D
│       └── Camera3D
├── Character (Node3D - optional visual)
└── Systems (Node)
    ├── MovementSystem (Node)
    ├── InputSystem (Node)
    ├── CameraSystem (Node)
    └── StateMachine (Node)
```

## 🎮 Usage Examples

### Basic Setup

```gdscript
extends CharacterBody3D

@onready var enhanced_controller = $EnhancedPlayerController
@onready var camera_system = $Systems/CameraSystem
@onready var movement_system = $Systems/MovementSystem

func _ready():
    # Systems auto-initialize when the scene loads
    
    # Connect to events if needed
    if EnhancedEventBus.instance:
        EnhancedEventBus.instance.state_changed.connect(_on_state_changed)
        EnhancedEventBus.instance.camera_mode_changed.connect(_on_camera_mode_changed)

func _on_state_changed(old_state: String, new_state: String):
    print("Player state: %s → %s" % [old_state, new_state])

func _on_camera_mode_changed(mode: String):
    print("Camera mode: %s" % mode)
```

### Camera Configuration

```gdscript
# Access camera system from the scene
var camera_system = $Systems/CameraSystem

# Configure camera settings
camera_system.sensitivity = 2.0
camera_system.invert_horizontal = false
camera_system.invert_vertical = true  # Inverted Y-axis

# Set camera modes
camera_system.set_camera_mode("first_person")
camera_system.set_camera_mode("third_person")

# Configure third person settings
camera_system.third_person_distance = 5.0
camera_system.third_person_height = 1.5
camera_system.strafe_mode_enabled = true

# Configure first person settings
camera_system.first_person_height = 1.7
camera_system.first_person_fov = 90.0
```

### Movement System Access

```gdscript
# Get movement information from the controller
var movement_system = $Systems/MovementSystem
var state_machine = $Systems/StateMachine

# Check current state
var current_state = state_machine.get_current_state()
print("Current state: %s" % current_state)

# Get movement data
var velocity = movement_system.get_velocity()
var is_grounded = movement_system.is_grounded()
var can_jump = movement_system.can_jump()

# Force state changes
state_machine.change_state("jumping")

# Access through service locator (alternative)
var movement_sys = EnhancedServiceLocator.get_movement_system()
var state_sys = EnhancedServiceLocator.get_state_machine()
```

### Custom Event Handling

```gdscript
# Connect to specific events
func _ready():
    if EnhancedEventBus.instance:
        # Movement events
        EnhancedEventBus.instance.movement_started.connect(_on_movement_started)
        EnhancedEventBus.instance.jump_initiated.connect(_on_jump_initiated)
        
        # Camera events
        EnhancedEventBus.instance.camera_mode_changed.connect(_on_camera_changed)

func _on_movement_started(direction: Vector2, speed: float):
    print("Moving in direction %s at speed %f" % [direction, speed])

func _on_jump_initiated(jump_force: float):
    print("Jumping with force: %f" % jump_force)
    # Play jump sound, particles, etc.
```

## ⚙️ Configuration

### Camera Settings

| Property | Description | Default |
|----------|-------------|---------|
| `sensitivity` | Mouse sensitivity | 2.0 |
| `invert_horizontal` | Invert X-axis | false |
| `invert_vertical` | Invert Y-axis | false |
| `zoom_speed` | Zoom wheel speed | 2.0 |
| `min_zoom` | Minimum zoom distance | 2.0 |
| `max_zoom` | Maximum zoom distance | 10.0 |

### Movement Settings

| Property | Description | Default |
|----------|-------------|---------|
| `walk_speed` | Walking speed | 5.0 |
| `run_speed` | Running speed | 8.0 |
| `sprint_speed` | Sprint speed | 12.0 |
| `crouch_speed` | Crouching speed | 3.0 |
| `jump_velocity` | Jump force | 12.0 |
| `gravity` | Gravity strength | 30.0 |

### Advanced Camera Features

#### Strafe Mode
```gdscript
# Enable strafe mode for dynamic camera tilt
camera_system.strafe_mode_enabled = true
camera_system.strafe_tilt_amount = 5.0  # Degrees of tilt
camera_system.strafe_smoothing = 10.0   # Smoothing factor
```

#### Camera Transitions
```gdscript
# Smooth transitions between camera modes
camera_system.transition_duration = 0.3
camera_system.set_camera_mode("first_person", true)  # Use transition
```

## 🔧 Extending the System

### Adding Custom Movement States

```gdscript
# 1. Create new state class
class_name CustomState
extends BaseState

func get_state_name() -> String:
    return "custom"

func enter_state() -> void:
    # State entry logic
    pass

func process_state(delta: float) -> void:
    # State processing logic
    pass

func can_transition_to(state_name: String) -> bool:
    # Define valid transitions
    return state_name in ["idle", "walking"]

# 2. Register the state with the state machine
var state_machine = $Systems/StateMachine
state_machine.add_state("custom", CustomState.new())
```

### Creating Custom Camera Strategies

```gdscript
# 1. Create camera strategy
class_name CustomCameraStrategy
extends CameraStrategyBase

func get_strategy_name() -> String:
    return "custom_camera"

func handle_input(mouse_delta: Vector2, delta: float) -> void:
    # Custom camera behavior
    pass

func on_enter() -> void:
    # Setup when strategy becomes active
    pass

func on_exit() -> void:
    # Cleanup when strategy changes
    pass

# 2. Register strategy with camera system
var camera_system = $Systems/CameraSystem
camera_system.add_strategy("custom_camera", CustomCameraStrategy.new())
camera_system.set_camera_mode("custom_camera")
```

### Custom Events

```gdscript
# The EventBus is automatically available as a singleton
# 1. Connect to existing events
func _ready():
    if EnhancedEventBus.instance:
        # Movement events
        EnhancedEventBus.instance.movement_started.connect(_on_movement_started)
        EnhancedEventBus.instance.jump_initiated.connect(_on_jump_initiated)
        
        # Camera events
        EnhancedEventBus.instance.camera_mode_changed.connect(_on_camera_changed)

# 2. Emit events from your systems
func _on_special_ability_used():
    if EnhancedEventBus.instance:
        EnhancedEventBus.instance.emit_signal("custom_ability_used", ability_data)

func _on_movement_started(direction: Vector3, speed: float):
    print("Moving in direction %s at speed %f" % [direction, speed])

func _on_jump_initiated(jump_force: float):
    print("Jumping with force: %f" % jump_force)
    # Play jump sound, particles, etc.
```

## 🐛 Debugging

### Enable Debug Mode
```gdscript
# Enable debug output in the main controller
var enhanced_controller = $EnhancedPlayerController
enhanced_controller.enable_debug_logging = true

# This will show:
# - State transitions
# - Movement calculations  
# - Event emissions
# - System initialization
```

### Debug Information
```gdscript
# Get debug information from systems
var state_machine = $Systems/StateMachine
var movement_system = $Systems/MovementSystem
var camera_system = $Systems/CameraSystem

var debug_info = {
    "current_state": state_machine.get_current_state(),
    "velocity": velocity,
    "is_grounded": is_on_floor(),
    "camera_mode": camera_system.get_current_mode_name(),
    "input_vector": movement_system._current_input_direction
}
print(debug_info)
```

## 📊 Performance

The enhanced system provides excellent performance characteristics:

- **Efficient Event System**: Minimal overhead for event-driven communication
- **Strategy Pattern**: No performance penalty for flexible architecture
- **Modular Design**: Only active systems consume resources
- **Optimized Physics**: Efficient movement calculations with proper delta time usage
- **Memory Efficient**: No unnecessary allocations during runtime
- **Scalable Architecture**: Easy to extend without performance degradation

## � Architecture Details

### Core Components

- **EnhancedPlayerController**: Main controller managing all systems
- **MovementSystem**: Handles physics-based movement calculations
- **CameraSystem**: Manages camera behavior with strategy pattern
- **StateMachine**: Controls movement states and transitions
- **InputSystem**: Processes and distributes input events
- **EventBus**: Global communication hub for decoupled systems
- **ServiceLocator**: Dependency injection for system access

## 🤝 Contributing

### Development Setup
1. Clone the repository
2. Open in Godot 4.0+
3. Enable the Player Movement Controller plugin
4. Run example scenes to test functionality

### Guidelines
- Follow GDScript conventions and style guides
- Add tests for new features when possible
- Update documentation for any new functionality
- Ensure backward compatibility when modifying existing systems
- Use the event system for communication between components

### Plugin Structure
- Keep systems decoupled using the EventBus
- Follow the strategy pattern for extensible behaviors
- Use the ServiceLocator for dependency management
- Maintain clear separation of concerns between systems

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Built for the Godot 4 community
- Inspired by modern game development architecture patterns
- Designed with flexibility and extensibility in mind
- Created by Mile Rajević

---

## 📚 Additional Resources

- [Godot Documentation](https://docs.godotengine.org/)
- [GDScript Style Guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Event-Driven Programming in Godot](https://docs.godotengine.org/en/stable/tutorials/scripting/signals.html)

**Ready to enhance your movement system? Get started with the pre-built scene! 🚀**
