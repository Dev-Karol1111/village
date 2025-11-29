extends Node

var time : int = 720

func time_loop():
	while Managment.running:
		if Managment.speed_time > 0 and !Managment.totally_pause:
			time += 1 
			Signals.time_updated.emit()
			if time % 10 == 0:
				Signals.hour_passed.emit()
			if time % 60 % 12:
				Signals.day_passed.emit()
			await get_tree().create_timer(1).timeout
		else:
			await get_tree().process_frame