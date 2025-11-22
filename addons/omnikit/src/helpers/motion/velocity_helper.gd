class_name OmniKitVelocityHelper

enum SpeedUnit {
	KilometersPerHour,
	MilesPerHour,
}


static func current_speed_on(speed_unit: SpeedUnit, velocity: Variant) -> float:
		match speed_unit:
			SpeedUnit.KilometersPerHour:
				return current_speed_on_kilometers_per_hour(velocity)
			SpeedUnit.MilesPerHour:
				return current_speed_on_miles_per_hour(velocity)
			_:
				return 0.0


static func current_speed_on_miles_per_hour(velocity: Variant) -> float:
	if velocity is Vector2 or velocity is Vector2i:
		return roundf(velocity.length() * OmniKitMathHelper.MetersPerSecondToMilePerHourFactor)
	
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * OmniKitMathHelper.MetersPerSecondToMilePerHourFactor)
	
	elif velocity is Vector3i:
		return roundf(Vector3i(velocity.x, 0, velocity.z).length() * OmniKitMathHelper.MetersPerSecondToMilePerHourFactor)
	
	elif velocity is float: ## We assume we received the velocity length
		return roundf(velocity * OmniKitMathHelper.MetersPerSecondToMilePerHourFactor)
	else:
		return 0.0


static func current_speed_on_kilometers_per_hour(velocity: Variant) -> float:
	if velocity is Vector2 or velocity is Vector2i:
		return roundf(velocity.length() * OmniKitMathHelper.MetersPerSecondToKilometersPerHourFactor)
	
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * OmniKitMathHelper.MetersPerSecondToKilometersPerHourFactor)
	
	elif velocity is Vector3i:
		return roundf(Vector3i(velocity.x, 0, velocity.z).length() * OmniKitMathHelper.MetersPerSecondToKilometersPerHourFactor)
	
	elif velocity is float: ## We assume we received the velocity length
		return roundf(velocity * OmniKitMathHelper.MetersPerSecondToKilometersPerHourFactor)
	else:
		return 0.0