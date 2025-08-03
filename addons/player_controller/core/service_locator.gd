class_name EnhancedServiceLocator
extends Node

## Service Locator for dependency injection
## Manages singleton services across the enhanced movement addon

static var _services: Dictionary = {}
static var _initialized: bool = false

static func initialize():
	if _initialized:
		return
	_initialized = true

static func register_service(service_name: String, service: Object) -> void:
	if not service:
		push_error("Cannot register null service: " + service_name)
		return
	
	_services[service_name] = service

static func get_service(service_name: String) -> Object:
	if service_name in _services:
		return _services[service_name]
	
	push_error("Service not found: " + service_name)
	return null

static func unregister_service(service_name: String) -> void:
	if service_name in _services:
		_services.erase(service_name)

static func has_service(service_name: String) -> bool:
	return service_name in _services

static func clear_all_services() -> void:
	_services.clear()
	_initialized = false

# Convenience methods for common services
static func get_event_bus() -> Object:
	return get_service("EventBus")

static func get_movement_system() -> Object:
	return get_service("MovementSystem")

static func get_state_machine() -> Object:
	return get_service("StateMachine")

static func get_camera_system() -> Object:
	return get_service("CameraSystem")

static func get_input_system() -> Object:
	return get_service("InputSystem")
