## Referenced from https://forum.godotengine.org/t/how-to-use-the-new-logger-class-in-godot-4-5/127006
class_name OmnikitLogger extends Logger

const MaxQueueSize: int = 20
const FileExtension: String = ".log"

const EventColors: Dictionary[Event, String] = {
	Event.Info: "lime_green",
	Event.Warning: "gold",
	Event.SystemError: "tomato",
	Event.Critical: "crimson",
}

enum Event {
	Info,
	Warning,
	SystemError,
	Critical,
	Flush
}

static var DefaultFilePath: String = OS.get_user_data_dir() + "/logs"
static var _mutex: Mutex = Mutex.new()
static var _event_strings: PackedStringArray = Event.keys()
static var _message_queue: PackedStringArray
static var _queue_size: int:
	set(value):
		_queue_size = clampi(value, 0, MaxQueueSize)

static var _log_path: String
static var _is_valid: bool = false
static var current_logger: OmnikitLogger


static func _static_init() -> void:
	enable()


static func enable() -> void:
	_log_path = _create_log_file()
	_message_queue.resize(MaxQueueSize)
	_is_valid = not _log_path.is_empty() and _message_queue.size() == MaxQueueSize
	current_logger = OmnikitLogger.new()
	OS.add_logger(current_logger)


static func disable() -> bool:
	if current_logger:
		OS.remove_logger(current_logger)
		return true
		
	return false


static func _create_log_file() -> String:
	var file_name: String = Time.get_date_string_from_system() + FileExtension
	var file_path: String = DefaultFilePath + "/%s" % file_name
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)

	return file_path if file else ""


## Tracking player progression, state changes, or routine successful actions.
static func info(message: String) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.Info
	message = _format_log_message(message, event)
	
	_add_message_to_queue(message, event)
	_print_event(message, event)


## Notifying of non-critical issues (e.g., missing resource files, deprecated calls) that don't halt execution.
static func warn(message: String) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.Warning
	message = _format_log_message(message, event)
	
	_add_message_to_queue(message, event)
	_print_event(message, event)


## Logging application errors, failed API calls, or issues that prevent intended functionality. Includes a script backtrace.
static func error(message: String) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.SystemError
	message = _format_log_message(message, event)
	
	var script_backtraces: Array[ScriptBacktrace] = Engine.capture_script_backtraces()

	if not script_backtraces.is_empty():
		message += '\n' + str(script_backtraces.front())
	
	_add_message_to_queue(message, event)
	_print_event(message, event)

## Logging failures that may lead to instability or immediate crashes. Includes a script backtrace.
static func critical(message: String) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.Critical
	message = _format_log_message(message, event)
	
	var script_backtraces: Array[ScriptBacktrace] = Engine.capture_script_backtraces()
	
	if not script_backtraces.is_empty():
		message += '\n' + str(script_backtraces.front())
		
	_add_message_to_queue(message, event)
	_print_event(message, event)


static func force_flush() -> void:
	_add_message_to_queue("", Event.Flush)

		
func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.Warning if error_type == ERROR_TYPE_WARNING else Event.SystemError
	var message: String = "[{time}] {event}: {rationale}\n{code}\n{file}:{line} @ {function}()".format({
		"time": Time.get_time_string_from_system(),
		"event": _event_strings[event],
		"rationale": rationale,
		"code": code,
		"file": file,
		"line": line,
		"function": function,
 	})
	
	_add_message_to_queue(message, event)


func _log_message(message: String, is_error: bool) -> void:
	if not _is_valid:
		return
		
	var event: Event = Event.SystemError if is_error else Event.Info
	message = _format_log_message(message.trim_suffix('\n'), event)
	
	if is_error:
		var script_backtraces: Array[ScriptBacktrace] = Engine.capture_script_backtraces()
		
		if not script_backtraces.is_empty():
			message += '\n' + str(script_backtraces.front())

	_add_message_to_queue(message, event)	
	

static func _format_log_message(message: String, event: Event) -> String:
	return "[{time}] {event}: {message}".format({
		"time": Time.get_datetime_string_from_system(),
		"event": _event_strings[event],
		"message": message,
	})


static func _add_message_to_queue(message: String, event: Event) -> void:
	_mutex.lock()
	
	if not _is_valid:
		_mutex.unlock()
		return
		
	if not message.is_empty():
		_message_queue[_queue_size] = message
		_queue_size += 1
		
	if _queue_size >= MaxQueueSize or event == Event.Flush:
		_is_valid = _flush()
		_queue_size = 0
		
	_mutex.unlock()


static func _flush() -> bool:
	var file: FileAccess = FileAccess.open(_log_path, FileAccess.READ_WRITE)
	
	if file == null:
		return false
		
	file.seek_end()
	
	for message: int in range(_queue_size):
		if not file.store_line(_message_queue[message]):
			return false
			
	return true


static func _print_event(message: String, event: Event) -> void:
	var message_lines: PackedStringArray = message.split('\n')
	
	message_lines[0] = "[b][color=%s]%s[/color][/b]" % [EventColors[event], message_lines[0]]
	print_rich.call_deferred("[lang=tlh]%s[/lang]" % '\n'.join(message_lines))
