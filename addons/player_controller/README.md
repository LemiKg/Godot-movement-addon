# Enhanced Movement System

A refactored movement system with decoupled architecture using event bus and strategy patterns. Maintains exact same movement calculations and behavior as the original system.

## Architecture Overview

### Core Principles
- **Event-Driven**: All components communicate through an event bus
- **Strategy Pattern**: Different movement behaviors are implemented as strategies
- **Single Responsibility**: Each system handles one specific concern
- **Same Calculations**: All movement math preserved from original system

### Systems

#### 1. Enhanced Movement System (`enhanced_movement_system.gd`)
- Handles all movement calculations using the exact same formulas as original
- Supports strafe mode, gravity, acceleration, rotation
- Preserves jump buffering and coyote time mechanics
- Event-driven communication

#### 2. Enhanced State Machine (`state_machine.gd`)
- Manages player state transitions
- Same state logic as original (idle, walking, running, sprint, crouch, jump, fall, land)
- Event-driven state changes
- Debug mode support

#### 3. Enhanced Input System (`input_system.gd`)
- Processes player input
- Communicates with other systems through events
- Same input handling as original

#### 4. Enhanced Player Controller (`enhanced_player_controller.gd`)
- Main component that orchestrates all systems
- Maintains same public interface as original
- Easy drop-in replacement

### Event Bus (`event_bus.gd`)
- Central communication hub
- Movement, state, camera, input, and system events
- Singleton pattern for global access

### Service Locator (`service_locator.gd`)
- Dependency injection container
- Manages system references
- Singleton services

## Usage

### Basic Setup
```gdscript
# Create player with enhanced movement
var player = preload("res://addons/enhanced_movement/components/enhanced_player_controller.gd").new()
player.camera = camera_node
player.camera_controller = camera_controller_node
```

### Accessing Systems
```gdscript
# Get current state
var current_state = player.get_current_state()

# Check if can jump
var can_jump = player.can_jump()

# Get movement direction
var direction = player.get_movement_direction()
```

### Event Handling
```gdscript
# Connect to state changes
if EventBus.instance:
    EventBus.instance.state_changed.connect(_on_state_changed)

func _on_state_changed(old_state: String, new_state: String):
    print("State changed: %s -> %s" % [old_state, new_state])
```

## Migration from Original System

The enhanced system is designed as a drop-in replacement:

1. **Same Interface**: All public methods preserved
2. **Same Behavior**: Identical movement calculations
3. **Same Performance**: No additional overhead
4. **Same Configuration**: All export variables maintained

### Differences
- **Architecture**: Event-driven vs direct coupling
- **Extensibility**: Easy to add new movement types
- **Debugging**: Better event tracing
- **Testing**: Systems can be tested independently

## Extension Points

### Adding New Movement Strategies
1. Create new strategy class extending `MovementStrategy`
2. Implement movement calculations
3. Register in movement system

### Adding New States
1. Add state to constants
2. Update state machine transitions
3. Create corresponding movement strategy

### Custom Events
1. Add signals to EventBus
2. Connect in relevant systems
3. Emit events when needed

## Debugging

Enable debug mode for detailed logging:
```gdscript
player.set_debug_mode(true)
```

This will show:
- State transitions
- Movement calculations
- Event emissions
- System initialization

## Performance

The enhanced system maintains the same performance characteristics:
- Same physics calculations
- Same frame processing
- Minimal event overhead
- No garbage collection issues
