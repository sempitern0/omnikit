class_name OmniKitNameGenerator extends RefCounted

var repository: OmniKitNameRepository
var names_bag: OmniKitShuffleBag
var surnames_bag: OmniKitShuffleBag


func _init(_repository: OmniKitNameRepository) -> void:
	repository = _repository
	
	if repository.use_shuffle_bag:
		names_bag = OmniKitShuffleBag.new(repository.names)
		surnames_bag = OmniKitShuffleBag.new(repository.surnames)
	

func generate(include_surname: bool = true) -> String:
	var result: String = ""
	
	if repository.names.size():
		result += generate_name()
		
	if include_surname and repository.surnames.size():
		result += " %s" % generate_surname()
	
	return result


func generate_name() -> String:
	if repository.names.size():
		return names_bag.random() if repository.use_shuffle_bag else repository.names.pick_random() 
		
	return ""


func generate_surname() -> String:
	if repository.surnames.size():
		return surnames_bag.random() if repository.use_shuffle_bag else repository.surnames.pick_random() 
		
	return ""
	
	
func change_repository(new_repository: OmniKitNameRepository) -> OmniKitNameGenerator:
	repository = new_repository
	names_bag = OmniKitShuffleBag.new(repository.names)
	surnames_bag = OmniKitShuffleBag.new(repository.surnames)
	
	return self