extends Node

var time : TimeData

var day_summary_code = load("res://scripts/day_summary.gd").new()

func _ready() -> void:
	time = TimeData.new()
	time.hours = 6

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
			
			if time.hours == 20 and time.minutes == 30:
				day_summary_code.day_summary()
			
			if time.hours == 6 and time.minutes == 10:
				PeopleManagment.can_work = true
			elif time.hours == 18 and time.minutes == 0:
				PeopleManagment.can_work = false
			
			await get_tree().create_timer(float(Managment.speed_time) / Managment.multiple_speed).timeout
		else:
			await get_tree().process_frame


func set_time(new_time : int):
	time.minutes = new_time % 60
	time.hours = (new_time / 60) % 24
	time.days = new_time / 60 / 24
