## Wait for multiple callables to finish
## EXAMPLE:
## var jobs = OmniKitJobs.new()
## jobs.add(func(): ## do stuff):
## jobs.add(func(): ## do secondary stuff):
## await jobs.completed
class_name OmniKitJobs extends RefCounted

signal completed

var started: int = 0
var finished: int = 0


func add(new_job: Callable):
	if new_job.is_valid():
		started += 1
		_run_job(new_job)
		
	
func reset() -> void:
	started = 0
	finished = 0
	

func _run_job(job: Callable) -> void:
	await job.call()
	finished += 1

	if started == finished:
		reset()
		await Engine.get_main_loop().process_frame
		completed.emit()
