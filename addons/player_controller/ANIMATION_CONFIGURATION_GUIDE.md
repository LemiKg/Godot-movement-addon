# Animation Configuration Guide

## Overview

The AnimationController has been completely overhauled with comprehensive configurability. You can now configure every aspect of the animation system through the Inspector without modifying code.

## Configuration Rating: 9/10 (Highly Configurable)

### ✅ What's Now Configurable:
- **Animation State Names**: Map any state to any animation name
- **Blend Parameters**: Configure custom blend parameter paths
- **Per-State Animation Speeds**: Individual speed control for each state
- **Transition Settings**: Control how animations transition
- **Animation Events**: Optional event system for animation callbacks
- **Fallback System**: Graceful handling of missing animations
- **Debug System**: Comprehensive logging and validation

## Quick Start

### 1. Basic Setup
1. Add an AnimationController node to your PlayerController's Components
2. Set the AnimationTree reference in the PlayerController script
3. Configure animation names in the Inspector

### 2. Animation Mapping Configuration
Configure which animation plays for each player state:

```
Animation Mapping:
├── Idle Animation Name: "Idle"
├── Walk Animation Name: "Walk" 
├── Run Animation Name: "Walk"           # Can reuse animations
├── Sprint Animation Name: "Sprint"
├── Jump Animation Name: "Jump_Start"
├── Crouch Idle Animation Name: "Crouch_Idle"
├── Crouch Move Animation Name: "Crouch_Fwd"
├── Falling Animation Name: "Walk"       # Fallback to walk
└── Landing Animation Name: "Jump_Land"
```

### 3. Blend Parameters Configuration
Configure the AnimationTree parameter paths:

```
Animation Parameters:
├── Idle Blend Parameter: "parameters/Idle/blend_position"
├── Walk Blend Parameter: "parameters/Walk/blend_position"
├── Sprint Blend Parameter: "parameters/Sprint/blend_position"
├── Crouch Idle Blend Parameter: "parameters/Crouch_Idle/blend_position"
└── Crouch Move Blend Parameter: "parameters/Crouch_Fwd/blend_position"
```

### 4. Animation Speed Configuration
Set individual speeds for each animation state:

```
Per-State Animation Speeds:
├── Idle Animation Speed: 1.0
├── Walk Animation Speed: 1.0
├── Run Animation Speed: 1.2          # 20% faster
├── Sprint Animation Speed: 1.5        # 50% faster
├── Jump Animation Speed: 1.0
├── Crouch Idle Animation Speed: 0.8   # 20% slower
├── Crouch Move Animation Speed: 0.9   # 10% slower
├── Falling Animation Speed: 1.0
└── Landing Animation Speed: 1.0
```

## Advanced Configuration

### Transition Settings
Control how animations blend between states:

```
Transition Settings:
├── Use Smooth Transitions: true       # Use travel() vs start()
├── Transition Duration: 0.1           # Seconds for transition
└── Enable Transition Validation: true # Check animations exist
```

### Animation Settings
Global configuration options:

```
Animation Settings:
├── Default Animation Speed: 1.0       # Global speed multiplier
├── Validate Animation Tree: true      # Check tree on initialization
├── Fallback Animation: "Idle"         # Default if animation missing
└── Enable Debug Logging: false       # Debug output to console
```

## Runtime Configuration

The new system supports runtime reconfiguration:

```gdscript
# Change animation mapping at runtime
animation_controller.set_animation_mapping("walking", "New_Walk_Animation")

# Change animation speed for a state
animation_controller.set_state_animation_speed("sprint", 2.0)

# Change blend parameter
animation_controller.set_blend_parameter("walking", "parameters/Custom/blend")

# Get current configuration
var config = animation_controller.get_configuration_summary()
print("Current config: ", config)
```

## Animation Events System

Enable the event system for advanced animation integration:

```gdscript
# Enable in Inspector
Enable Animation Events: true

# Connect to events in your script
animation_controller.animation_event.connect(_on_animation_event)

func _on_animation_event(event_name: String, event_data: Dictionary):
    match event_name:
        "state_changed":
            print("Animation changed: ", event_data.animation)
        "custom_event":
            print("Custom event: ", event_data)

# Trigger custom events
animation_controller.trigger_animation_event("footstep", {"foot": "left"})
```

## Validation and Debugging

### Built-in Validation
The system includes comprehensive validation:

```gdscript
# Check configuration
var is_valid = animation_controller.validate_configuration()
if not is_valid:
    print("Animation configuration has issues!")

# Get detailed configuration summary
var summary = animation_controller.get_configuration_summary()
```

### Debug Logging
Enable debug logging to see what's happening:

```
Enable Debug Logging: true
```

Console output will show:
```
[AnimationController] Initialized with 9 animations
[AnimationController] Transitioned to: Walk
[AnimationController] Updated parameters/Walk/blend_position blend: 0.75
[AnimationController] State changed to walking, playing animation: Walk
```

## Common Use Cases

### 1. Different Character Rigs
```
# For a quadruped character:
Idle Animation Name: "Quadruped_Idle"
Walk Animation Name: "Quadruped_Walk"
Sprint Animation Name: "Quadruped_Run"
```

### 2. Custom Animation Tree Structure
```
# For custom parameter names:
Walk Blend Parameter: "parameters/Movement/walk_blend"
Sprint Blend Parameter: "parameters/Movement/sprint_blend"
```

### 3. Shared Animations
```
# Reuse walk animation for multiple states:
Walk Animation Name: "Movement"
Run Animation Name: "Movement"       # Same animation, different speeds
Sprint Animation Name: "Movement"
```

### 4. Animation Speed Variations
```
# Slow, methodical character:
Walk Animation Speed: 0.8
Run Animation Speed: 1.0
Sprint Animation Speed: 1.3

# Fast, energetic character:
Walk Animation Speed: 1.2
Run Animation Speed: 1.5
Sprint Animation Speed: 2.0
```

## Troubleshooting

### Animation Not Playing
1. Check animation name matches AnimationTree node name exactly
2. Ensure `Validate Animation Tree` is enabled to see warnings
3. Check fallback animation is set correctly
4. Enable debug logging to see transition attempts

### Blend Parameters Not Working
1. Verify parameter path matches AnimationTree structure
2. Check for typos in parameter names
3. Ensure blend tree is properly configured
4. Test with simple parameter names first

### Performance Issues
1. Disable debug logging in production
2. Disable transition validation if not needed
3. Use fewer blend parameters for simple cases
4. Consider animation LOD system for distant characters

## Migration from Old System

### Old Hard-coded System:
```gdscript
# Old way - required code changes
func play_walk_animation():
    transition_to_animation("Walk")
```

### New Configurable System:
```gdscript
# New way - configured in Inspector
Walk Animation Name: "Walk"  # or any other animation name
```

The new system is backward compatible - existing animation names will work without changes, but you gain the flexibility to change them without code modification.

## Best Practices

1. **Use Descriptive Names**: `"Character_Walk"` instead of `"Walk"`
2. **Test with Validation**: Always enable validation during development
3. **Document Custom Setups**: Note any non-standard configurations
4. **Use Events Sparingly**: Only enable events if you need them
5. **Consistent Naming**: Use consistent naming patterns across characters
6. **Speed Ranges**: Keep animation speeds between 0.5-2.0 for best results

## Conclusion

The new AnimationController provides **excellent configurability (9/10)** while maintaining ease of use. You can now:

- Configure any animation system without code changes
- Support multiple character types and rigs
- Fine-tune animation timing and transitions
- Debug animation issues easily
- Extend functionality at runtime

This makes the animation system truly modular and reusable across different projects and character types.
