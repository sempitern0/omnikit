class_name OmniKitHashSet extends RefCounted

var hashset: Dictionary[Variant, bool] = {}

func _init(init_values: Array[Variant] = []) -> void:
	merge(init_values)


func merge(new_values: Array[Variant] = []) -> void:
	for value: Variant in new_values:
		add(value)

	
func add(value: Variant) -> bool:
	if hashset.has(value):
		return false
		
	hashset[value] = true
	return true
	

func duplicate() -> OmniKitHashSet:
	return OmniKitHashSet.new(hashset.keys().duplicate())


func remove(value: Variant) -> bool:
	return hashset.erase(value)
		

func has(value: Variant) -> bool:
	return hashset.has(value)


func size() -> int:
	return hashset.size()


func is_empty() -> bool:
	return hashset.is_empty()


func equals(other: OmniKitHashSet) -> bool:
	if hashset.size() != other.size():
		return false
	
	var result: bool = true
	
	for value: Variant in hashset.keys():
		if not other.has(value):
			result = false
			break
	
	return result


func to_array() -> Array[Variant]:
	return hashset.keys()


func front() -> Variant:
	if hashset.is_empty():
		return null
		
	return hashset.keys().front()


func back() -> Variant:
	if hashset.is_empty():
		return null
		
	return hashset.keys().back()
	
	
func pop_back() -> Variant:
	var value: Variant = back()
	hashset.erase(value)
	
	return value


func pop_front() -> Variant:
	var value: Variant = front()
	hashset.erase(value)
	
	return value


func clear() -> void:
	hashset.clear()
