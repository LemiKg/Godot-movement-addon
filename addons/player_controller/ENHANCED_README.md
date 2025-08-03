# Enhanced Movement System

An event-driven, decoupled movement system for Godot 4 that maintains the exact same functionality as the original player controller but with improved architecture.

## 🚀 Key Features

### ✅ **Complete Feature Parity**
- All movement calculations are **identical** to the original system
- Same camera behavior (first person, third person, strafe mode)
- Same state transitions and movement speeds
- Same input handling and responsiveness
- Same collision detection and physics

### 🏗️ **Improved Architecture**
- **Event-driven communication** via EventBus
- **Strategy Pattern** for movement and camera behaviors
- **Decoupled systems** that can be easily extended
- **Service Locator** for dependency management
- **SOLID principles** throughout the codebase

## 📁 Project Structure

```
addons/enhanced_movement/
├── core/                           # Core systems
│   ├── event_bus.gd               # Global event bus for decoupled communication
│   ├── service_locator.gd         # Dependency injection and service management
│   └── constants.gd               # Centralized configuration constants
├── systems/                        # Main system components
│   ├── enhanced_movement_system.gd # Movement calculations (same as original)
│   ├── state_machine.gd           # State management with event bus
│   ├── input_system.gd            # Input handling and processing
│   └── camera_system.gd           # Camera management with strategies
├── strategies/                     # Strategy pattern implementations
│   ├── movement/                   # Movement behavior strategies
│   │   ├── movement_strategy.gd    # Base movement strategy
│   │   ├── walk_strategy.gd        # Walking movement
│   │   ├── run_strategy.gd         # Running movement
│   │   ├── sprint_strategy.gd      # Sprint movement
│   │   ├── crouch_strategy.gd      # Crouch movement
│   │   ├── jump_strategy.gd        # Jump/air control
│   │   └── fall_strategy.gd        # Falling/air control
│   └── camera/                     # Camera behavior strategies
│       ├── camera_strategy.gd      # Base camera strategy
│       ├── first_person_strategy.gd # First person camera
│       └── third_person_strategy.gd # Third person camera with strafe
├── states/                         # State pattern implementations
│   ├── base_state.gd              # Base state class
│   ├── idle_state.gd              # Idle state
│   ├── walking_state.gd           # Walking state
│   ├── running_state.gd           # Running state
│   ├── sprint_state.gd            # Sprint state
│   ├── jumping_state.gd           # Jumping state
│   ├── falling_state.gd           # Falling state
│   ├── landing_state.gd           # Landing state
│   ├── crouch_idle_state.gd       # Crouch idle state
│   └── crouch_move_state.gd       # Crouch moving state
├── components/                     # Main controller components
│   └── enhanced_player_controller.gd # Main player controller
└── scenes/                         # Scene files and examples
    └── enhanced_player_controller.tscn
```

## 🔄 System Architecture

### Event Bus Pattern
All systems communicate through a centralized event bus, eliminating direct dependencies:

```gdscript
# Movement events
EventBus.movement_started.emit(direction, speed)
EventBus.jump_initiated.emit(jump_force)

# State events  
EventBus.state_changed.emit(old_state, new_state)

# Camera events
EventBus.camera_mode_changed.emit(mode_name)
```

### Strategy Pattern
Different behaviors are implemented as interchangeable strategies:

```gdscript
# Movement strategies
movement_system.set_strategy("walk")    # 5.0 speed
movement_system.set_strategy("run")     # 8.0 speed  
movement_system.set_strategy("sprint")  # 12.0 speed

# Camera strategies
camera_system.set_camera_mode("first_person")   # FOV 90, no player model
camera_system.set_camera_mode("third_person")   # FOV 75, show player model
```

### Service Locator
Systems register themselves for easy access across the addon:

```gdscript
# Register services
ServiceLocator.register_service("MovementSystem", movement_system)
ServiceLocator.register_service("StateMachine", state_machine)

# Access services
var movement = ServiceLocator.get_movement_system()
var state_machine = ServiceLocator.get_state_machine()
```

## 🎮 Usage

### Basic Setup

1. **Enable the addon** in Project Settings → Plugins
2. **Add the player controller** to your scene
3. **Configure the controller** in the inspector

### Input Map Requirements

Ensure these actions exist in your Input Map:
- `move_left`, `move_right`, `move_forward`, `move_backward`
- `jump`, `crouch`, `sprint`, `run`
- `toggle_camera_mode`, `toggle_strafe_mode` (optional)

## 🔧 Status

**Current Implementation Status:**

✅ **Completed:**
- Event bus architecture
- Service locator pattern  
- Enhanced movement system with same calculations
- State machine with event communication
- Input system with correct crouch/sprint handling
- Base strategy classes
- All state classes (idle, walking, running, sprint, jump, fall, landing, crouch)
- Movement strategies (walk, run, sprint, crouch, jump, fall)
- Camera strategies (first person, third person)
- Strafe mode functionality matching original
- Main enhanced player controller
- Plugin configuration
- Fixed crouch-to-running transitions

⚠️ **Known Issues:**
- Type checking errors due to cross-references (functionality works)
- Scene file needs to be created in Godot editor
- Animation system not yet implemented
- Some strategy preloading needs refinement

🔄 **Next Steps:**
- Create scene file in Godot editor
- Add animation system integration
- Fix type checking issues
- Add example scenes and documentation
- Performance testing and optimization

## 📋 Requirements

- **Godot 4.0+**
- **Input Map** with movement actions configured
- **3D scene** with proper node hierarchy (SpringArm3D + Camera3D)

---

*The Enhanced Movement System - Same great functionality, better architecture! 🚀*
