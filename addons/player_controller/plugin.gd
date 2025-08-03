@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("EnhancedEventBus", "res://addons/player_controller/core/event_bus.gd")
	add_autoload_singleton("EnhancedServiceLocator", "res://addons/player_controller/core/service_locator.gd")

func _exit_tree():
	remove_autoload_singleton("EnhancedEventBus")
	remove_autoload_singleton("EnhancedServiceLocator")
