class_name CrouchMoveState
extends EnhancedStateBase

## Crouch Move State - Player is crouching and moving
## Same logic as original crouch move state

func get_state_name() -> String:
	return "crouch_move"

func get_movement_speed() -> float:
	return 3.0 # CROUCH_SPEED from original

func process_physics(delta: float) -> void:
	# Crouch move state physics (same as original)
	pass

func can_transition_to(new_state_name: String) -> bool:
	# Crouch move can transition to other crouch states and standing (same as original)
	# Allow direct transitions to running/sprint when uncrouch + run is pressed
	return new_state_name in [
		"idle",
		"walking",
		"running",
		"sprint",
		"jumping",
		"crouch_idle"
	]

func enter() -> void:
	super.enter()
	# Set movement strategy to crouch and adjust collision shape
	if movement_system and movement_system.has_method("set_movement_state"):
		movement_system.set_movement_state("crouch_move")
	
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
