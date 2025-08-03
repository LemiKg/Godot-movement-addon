class_name JumpMovementStrategy
extends MovementStrategy

## Jump movement strategy
## Implements the exact same jump calculations as the original system

func _init():
	speed = MovementConstants.AIR_CONTROL_SPEED
	acceleration = MovementConstants.ACCELERATION_DEFAULT
	can_jump = false # Already jumping
	air_control = true

func get_strategy_name() -> String:
	return MovementConstants.STRATEGY_JUMP

func calculate_movement(input_direction: Vector2, delta: float) -> Vector3:
	if not player or not camera:
		return Vector3.ZERO
	
	# Air control movement (same as original)
	var forward = - camera.global_basis.z.normalized()
	var right = camera.global_basis.x.normalized()
	var move_direction = forward * input_direction.y + right * input_direction.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	return move_direction * speed

func handle_rotation(input_direction: Vector2, delta: float) -> void:
	if not player or not camera:
		return
	
	var skin = player.get_node_or_null("Character") as Node3D
	if not skin:
		return
	
	# Keep rotation during jump (same as original)
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
	# Jump can only transition to falling when velocity.y < 0
	return state_name in [MovementConstants.STATE_FALLING]

func on_enter() -> void:
	# Emit event when entering jump state
	if EnhancedEventBus.instance:
		EnhancedEventBus.instance.jump_initiated.emit(MovementConstants.JUMP_VELOCITY)
