@tool
extends EditorPlugin

## Advanced Player Controller Plugin
## Adds custom node types for the player controller system

const PlayerController = preload("res://addons/player_controller/scripts/player_controller.gd")
const InputHandler = preload("res://addons/player_controller/scripts/components/input_handler.gd")
const MovementController = preload("res://addons/player_controller/scripts/components/movement_controller.gd")
const CameraController = preload("res://addons/player_controller/scripts/components/camera_controller.gd")
const AnimationController = preload("res://addons/player_controller/scripts/components/animation_controller.gd")
const StateManager = preload("res://addons/player_controller/scripts/components/state_manager.gd")

func _enter_tree():
	# Add custom node types
	add_custom_type(
		"PlayerController",
		"CharacterBody3D",
		PlayerController,
		preload("res://addons/player_controller/icons/player_controller.svg")
	)
	add_custom_type(
		"InputHandler",
		"Node",
		InputHandler,
		preload("res://addons/player_controller/icons/input_handler.svg")
	)
	add_custom_type(
		"MovementController",
		"Node",
		MovementController,
		preload("res://addons/player_controller/icons/movement_controller.svg")
	)
	add_custom_type(
		"CameraController",
		"Node",
		CameraController,
		preload("res://addons/player_controller/icons/camera_controller.svg")
	)
	add_custom_type(
		"AnimationController",
		"Node",
		AnimationController,
		preload("res://addons/player_controller/icons/animation_controller.svg")
	)
	add_custom_type(
		"StateManager",
		"Node",
		StateManager,
		preload("res://addons/player_controller/icons/state_manager.svg")
	)

func _exit_tree():
	# Remove custom node types
	remove_custom_type("PlayerController")
	remove_custom_type("InputHandler")
	remove_custom_type("MovementController")
	remove_custom_type("CameraController")
	remove_custom_type("AnimationController")
	remove_custom_type("StateManager")
