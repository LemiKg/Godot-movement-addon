class_name CrouchIdleState
extends EnhancedStateBase

## Crouch Idle State - Player is crouching and idle
## Same logic as original crouch idle state

func get_state_name() -> String:
	return "crouch_idle"

func get_movement_speed() -> float:
	return 0.0 # No movement while crouching idle

func process_physics(delta: float) -> void:
	# Crouch idle state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Crouch idle can transition to other crouch states and standing (same as original)
	# Allow direct transitions to running/sprint when uncrouch + run is pressed
	return new_state_name in [
		"idle",
		"walking",
		"running",
		"sprint",
		"jumping",
		"crouch_move"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to crouch and adjust collision shape
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("crouch_idle")
	
	# Adjust collision shape for crouching (same as original)
	if player:
		var collision_shape = player.get_node_or_null("CollisionShape3D")
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = 1.0

func exit() -> void:
	super.exit()
	# Reset collision shape when exiting crouch (same as original)
	if player:
		var collision_shape = player.get_node_or_null("CollisionShape3D")
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = 1.8
