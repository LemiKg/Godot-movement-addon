@tool
class_name PlayerController
extends CharacterBody3D

## Main Player Controller - Coordinates all player components
## Follows Single Responsibility and Dependency Inversion principles
## Part of the Advanced Player Controller addon

@export_group("References")
@export var camera_pivot: Node3D
@export var camera: Camera3D
@export var skin: Node3D
@export var animation_tree: AnimationTree # Optional - can be null
@export var collision_shape: CollisionShape3D

# Components
@onready var input_handler = get_node_or_null("Components/InputHandler")
@onready var movement_controller = get_node_or_null("Components/MovementController")
@onready var camera_controller = get_node_or_null("Components/CameraController")
@onready var animation_controller = get_node_or_null("Components/AnimationController")
@onready var state_manager = get_node_or_null("Components/StateManager")

var _current_input_direction := Vector2.ZERO

func _ready() -> void:
	# Auto-assign references if not set in inspector
	if not camera_pivot:
		camera_pivot = get_node_or_null("CameraPivot")
	if not camera:
		camera = get_node_or_null("CameraPivot/Camera3D")
	if not skin:
		skin = get_node_or_null("Character")
	if not collision_shape:
		collision_shape = get_node_or_null("CollisionShape3D")
	
	_setup_components()
	_connect_signals()

func _setup_components() -> void:
	# Initialize all components with required references
	if movement_controller:
		movement_controller.initialize(self, camera)
	
	# Camera controller is now self-initializing in _ready()
	# No need to call initialize() anymore
	
	# Initialize animation controller only if available and animation tree is set
	if animation_controller and animation_tree:
		animation_controller.initialize(animation_tree)
	
	if state_manager:
		state_manager.initialize(self, movement_controller)

func _connect_signals() -> void:
	# Connect component signals with null checks
	if input_handler:
		input_handler.movement_input_changed.connect(_on_movement_input_changed)
		input_handler.jump_requested.connect(_on_jump_pressed)
		input_handler.crouch_toggled.connect(_on_crouch_toggled)
		input_handler.run_toggled.connect(_on_run_toggled)
		input_handler.sprint_toggled.connect(_on_sprint_toggled)
		
		# Camera input is now handled directly by CameraController
		# No need to manually connect camera input signals
	
	# Connect animation controller only if available and animation tree is set
	if animation_controller and animation_tree and state_manager:
		state_manager.state_changed.connect(animation_controller.on_state_changed)
	
	if state_manager:
		state_manager.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	# Don't process physics in the editor
	if Engine.is_editor_hint():
		return
		
	# Update all components in proper order with null checks
	if state_manager:
		state_manager.process_physics(delta)
	
	# Camera rotation is now handled automatically by CameraController in _physics_process
	
	# Get current movement speed from state manager
	var current_speed = 5.0 # Default speed
	if state_manager:
		current_speed = state_manager.get_movement_speed()
	
	# Process movement through movement controller
	if movement_controller:
		movement_controller.process_movement(delta, _current_input_direction, current_speed)
	
	# Apply physics movement (this is crucial!)
	move_and_slide()
	
	# Update animations only if animation controller and tree are available
	if animation_controller and animation_tree:
		animation_controller.update_animation_parameters(_current_input_direction.length())

func _input(event: InputEvent) -> void:
	# Don't process input in the editor
	if Engine.is_editor_hint():
		return
		
	if state_manager:
		state_manager.handle_input(event)

# Signal handlers
func _on_movement_input_changed(direction: Vector2) -> void:
	_current_input_direction = direction

func _on_jump_pressed() -> void:
	if movement_controller:
		movement_controller.request_jump()
		if movement_controller.can_jump():
			movement_controller.execute_jump()
			if state_manager:
				state_manager.transition_to_state(StateManager.StateType.JUMPING)

func _on_crouch_toggled(is_crouching: bool) -> void:
	if not state_manager:
		return
		
	if is_crouching:
		if _current_input_direction.length() > 0.1:
			state_manager.transition_to_state(StateManager.StateType.CROUCHING_FWD)
		else:
			state_manager.transition_to_state(StateManager.StateType.CROUCHING_IDLE)
	else:
		state_manager.transition_to_state(StateManager.StateType.IDLE)

func _on_run_toggled(is_running: bool) -> void:
	if not state_manager:
		return
		
	if is_running and _current_input_direction.length() > 0.1:
		state_manager.transition_to_state(StateManager.StateType.RUNNING)

func _on_sprint_toggled(is_sprinting: bool) -> void:
	if not state_manager:
		return
		
	if is_sprinting and _current_input_direction.length() > 0.1:
		state_manager.transition_to_state(StateManager.StateType.SPRINT)

func _on_state_changed(_old_state: PCPlayerStateBase, _new_state: PCPlayerStateBase) -> void:
	# Handle state-specific behaviors like collision shape changes
	if not state_manager or not collision_shape:
		return
		
	var current_state_type = state_manager.get_current_state_type()
	match current_state_type:
		StateManager.StateType.CROUCHING_IDLE, StateManager.StateType.CROUCHING_FWD:
			if collision_shape.shape is CapsuleShape3D:
				collision_shape.shape.height = 1.0
		_:
			if collision_shape.shape is CapsuleShape3D:
				collision_shape.shape.height = 1.8

# Public API for external systems
func get_current_state() -> StateManager.StateType:
	if state_manager:
		return state_manager.get_current_state_type()
	return StateManager.StateType.IDLE

func is_in_state(state: StateManager.StateType) -> bool:
	if state_manager:
		return state_manager.is_in_state(state)
	return false

func can_move() -> bool:
	if state_manager:
		return state_manager.can_move()
	return false

func can_jump() -> bool:
	if state_manager:
		return state_manager.can_jump()
	return false
