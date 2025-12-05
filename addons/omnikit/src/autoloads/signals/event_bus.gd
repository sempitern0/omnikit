## This EventBus does not replace the built-in signal system from Godot but provides a way
## to connect events on scripts that do not need to be in the SceneTree
## ----------------------------------------------------------------------
## It's recommended to create a separate script Events.gd to save your signal names as constants
## So OmniKitEventBus.subscribe(&"event_name", ...args) becomes OmniKitEventBus.subscribe(Events.score, ...args)
## This gives the advantage of only having to change the names of events in one place.
extends Node

class EventListener:
	var id: int
	var method: Callable
	var priority: int = 0
	var flag: ConnectFlags = ConnectFlags.CONNECT_PERSIST
	 
	
	func _init(_method: Callable, _priority: int = 0, _flag: ConnectFlags = CONNECT_PERSIST) -> void:
		id = _method.get_object_id()
		method = _method
		priority = _priority
		flag = _flag
		
	func call_method(payload: Array[Variant]) -> void:
		method.callv(payload)

class EventRecord:
	var event: StringName
	var listener: EventListener
	var timestamp: float
	var datetime: String
	
	func _init(_event: StringName, _listener: EventListener) -> void:
		event = _event
		listener = _listener
		timestamp = Time.get_unix_time_from_system()
		datetime = Time.get_datetime_string_from_unix_time(timestamp)

		
## Array[EventListener]
var events: Dictionary[StringName, Array] = {}
var event_history: Array[EventRecord] = []
var max_event_history_length: int = 50:
	set(value):
		max_event_history_length = maxi(0, value)


func subscribe(event: StringName, method: Callable, priority: int = 0, flag: ConnectFlags = CONNECT_PERSIST) -> void:
	if method.is_valid():
		var listener: EventListener = EventListener.new(method, priority, flag)
	
		if events.has(event):
			if not _event_has_method(event, method):
				events[event].append(listener)
		else:
			events[event] = [listener]
			
		events[event].sort_custom(_sort_listeners_by_priority)


func subscribe_once(event: StringName, method: Callable, priority: int = 0) -> void:
	subscribe(event, method, priority, CONNECT_ONE_SHOT)


func unsubscribe(event: StringName, method: Callable) -> void:
	if events.has(event):
		events[event] = events[event]\
			.filter(func(listener: EventListener): return listener.id != method.get_object_id())


func publish(event: StringName, ...payload) -> void:
	if events.has(event):
		for subscriber: EventListener in events[event]:
			match subscriber.flag:
				CONNECT_ONE_SHOT:
					subscriber.call_method(payload)
					unsubscribe(event, subscriber.method)
				CONNECT_DEFERRED:
					subscriber.call_deferred("call_method", payload)
				_:
					subscriber.call_method(payload)
			
			record_event(event, subscriber)
			
	
func record_event(event: StringName, subscriber: EventListener) -> void:
	if max_event_history_length > 0:
		if event_history.size() + 1 > max_event_history_length:
			event_history.pop_front()
			
		event_history.append(EventRecord.new(event, subscriber))
	
		
func flush_event_history() -> void:
	event_history.clear()
	
	
func _event_has_method(event: StringName, method: Callable) -> bool:
	return method.get_object_id() in events[event].map(func(listener: EventListener): return listener.id)


func _sort_listeners_by_priority(a: EventListener, b: EventListener) -> bool:
	return a.id < b.id
