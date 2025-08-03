@tool
class_name FirstPersonMode
extends CameraStrategy

@export var eye_height: float = 1.6
@export var fov: float = 90.0
@export var head_bob_enabled: bool = true
@export var head_bob_amplitude: float = 0.05
@export var head_bob_frequency: float = 2.0

var _head_bob_time: float = 0.0
var _original_spring_length: float = 0.0

func apply_to_spring_arm(spring_arm: SpringArm3D, delta: float) -> void:
	# Set spring arm length to 0 for first person
	spring_arm.spring_length = 0.0
	
	# Position at eye height
	spring_arm.position.y = eye_height
	spring_arm.position.x = 0.0
	spring_arm.position.z = 0.0
	
	# Apply head bob if enabled and player is moving
	if head_bob_enabled:
		var player = spring_arm.get_parent().get_parent() # Get player from SpringArm parent
		var player_velocity = Vector3.ZERO
		
		# Safely get velocity using proper type checking
		if player and player is CharacterBody3D:
			player_velocity = player.velocity
		
		if player_velocity.length() > 0.1:
			_head_bob_time += delta * head_bob_frequency
			var bob_offset = sin(_head_bob_time) * head_bob_amplitude
			spring_arm.position.y = eye_height + bob_offset

func get_fov() -> float:
	return fov

func requires_player_model_visibility() -> bool:
	return false # Hide player model in first person

func on_mode_activated(spring_arm: SpringArm3D) -> void:
	# Store original spring length
	_original_spring_length = spring_arm.spring_length
	# Disable collision (we don't need it in first person)
	spring_arm.collision_mask = 0

func on_mode_deactivated(spring_arm: SpringArm3D) -> void:
	# Reset head bob
	_head_bob_time = 0.0
