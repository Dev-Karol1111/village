extends Resource

class_name TimeData

@export var minutes := 0
@export var hours := 0
@export var days := 0

func add(minutes_add: int = 0, hours_add: int = 0, days_add: int = 0) -> void:
	minutes += minutes_add
	hours += hours_add
	days += days_add	

	while minutes >= 60:
		minutes -= 60
		hours += 1

	while hours >= 24:
		hours -= 24
		days += 1

				
func to_one_data() -> int:
	return minutes + (hours * 60) + (days * 24 * 60)