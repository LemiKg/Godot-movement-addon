class_name EnhancedEventBus
extends Node

## Global Event Bus for decoupled communication
## Singleton pattern implementation for enhanced movement system

# Movement Events
signal movement_started(direction: Vector3, speed: float)
signal movement_stopped()
signal movement_speed_changed(old_speed: float, new_speed: float)
signal movement_direction_changed(direction: Vector3)
signal jump_initiated(jump_force: float)
signal landed(fall_height: float)
signal crouch_toggled(is_crouching: bool)
signal gravity_applied(delta: float)

# State Events
signal state_change_requested(new_state: String, force: bool)
signal state_changed(old_state: String, new_state: String)
signal state_enter(state_name: String)
signal state_exit(state_name: String)
signal state_transition_blocked(from_state: String, to_state: String)

# Camera Events
signal camera_fov_change_requested(new_fov: float, duration: float)
signal camera_shake_requested(intensity: float, duration: float)
signal camera_height_change_requested(new_height: float, duration: float)
signal camera_mode_changed(new_mode: String)
signal camera_strafe_input(input_vector: Vector2)

# Input Events
signal input_vector_changed(input_vector: Vector2)
signal jump_pressed()
signal jump_buffered()
signal crouch_pressed()
signal crouch_released()
signal sprint_pressed()
signal sprint_released()

# Physics Events
signal physics_processed(delta: float)
signal collision_detected(collision: KinematicCollision3D)
signal floor_state_changed(is_on_floor: bool)

# System Events
signal system_initialized(system_name: String)
signal system_error(system_name: String, error: String)
signal debug_message(message: String, category: String)

static var instance: EnhancedEventBus

func _enter_tree():
	if instance == null:
		instance = self
		name = "EnhancedEventBus"
	else:
		queue_free()

func _exit_tree():
	if instance == self:
		instance = null

# Helper methods for common event emissions
func emit_movement_event(direction: Vector3, speed: float):
	if direction.length() > 0.1:
		movement_started.emit(direction, speed)
	else:
		movement_stopped.emit()

func emit_state_change(old_state: String, new_state: String):
	state_changed.emit(old_state, new_state)

func emit_debug(message: String, category: String = "DEBUG"):
	debug_message.emit(message, category)
