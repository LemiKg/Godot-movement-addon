class_name CrouchMovementStrategy
extends MovementStrategy

## Crouch movement strategy
## Implements the exact same crouch calculations as the original system

func _init():
	speed = 3.0 # CROUCH_SPEED from original
	acceleration = 20.0
	can_jump = false # Cannot jump while crouching
	air_control = false

func get_strategy_name() -> String:
	return "crouch"

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	if not player or not camera:
		return
	
	var skin = player.get_node_or_null("Character") as Node3D
	if not skin:
		return
	
	# Calculate movement direction for rotation (same as original)
	if input_direction.length() > 0.2:
		var forward = - camera.global_basis.z.normalized()
		var right = camera.global_basis.x.normalized()
		var move_direction = forward * input_direction.y + right * input_direction.x
		move_direction.y = 0.0
		move_direction = move_direction.normalized()
		
		if move_direction.length() > 0.2:
			var target_angle = Vector3.BACK.signed_angle_to(move_direction, Vector3.UP)
			skin.global_rotation.y = lerp_angle(skin.global_rotation.y, target_angle, 20.0 * delta)

func can_transition_to(state_name: String) -> bool:
	# Crouch can transition to idle and walking
	return state_name in [
		"idle",
		"walking",
		"crouch_idle",
		"crouch_move"
	]

func on_enter() -> void:
	# Emit event when entering crouch state and adjust collision
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.crouch_toggled.emit(true)
		EnhancedEventBus.instance.movement_started.emit(Vector3.ZERO, speed)
	
	# Adjust collision shape for crouching (same as original)
	if player:
		var collision_shape = player.get_node_or_null("CollisionShape3D")
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = 1.0

func on_exit() -> void:
	# Reset collision shape when exiting crouch
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.crouch_toggled.emit(false)
	
	# Reset collision shape (same as original)
	if player:
		var collision_shape = player.get_node_or_null("CollisionShape3D")
		if collision_shape and collision_shape.shape is CapsuleShape3D:
			collision_shape.shape.height = 1.8
