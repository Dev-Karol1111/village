extends Node

var time : TimeData

func _ready() -> void:
	time = TimeData.new()
	time.hours = 12

func time_loop():
	while Managment.running:
		if time == null:
			await get_tree().create_timer(1).timeout
			continue
		if Managment.speed_time > 0 and !Managment.totally_pause:
			time.add(1,0,0)
			Signals.time_updated.emit()
			if time.minutes % 60 == 0:
				Signals.hour_passed.emit()
			if time.hours % 12 == 0:
				Signals.day_passed.emit()
			await get_tree().create_timer(1).timeout
		else:
			await get_tree().process_frame
