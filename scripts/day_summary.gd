extends Node

func day_summary():
	#	SECTION - UI
	Managment.spawn_ui("res://scenes/ui/day_summary_ui.tscn")
	# SECTION - Eating
	var did_everyone_eat := true
	var did_everyone_drank := true
	for people in Managment.people:
		if !eat(people, Managment.products.get("fruit", 0)): 
			people.healt -= 5
			did_everyone_eat = false
		else:
			Managment.products["fruit"] -= people.need_food
		
		var need_water = 1 if TimeManagment.time.days != 4 else 2
		
		if Managment.products.get("water", 0) >= need_water:
			Managment.products["water"] -= need_water
		else:
			people.healt -= 15
			did_everyone_drank = false
	
	if !did_everyone_eat:
		Signals.add_information.emit("warning", "Food", "Everyone didn't eat\nsome damage was taken")
	if !did_everyone_drank:
		Signals.add_information.emit("warning", "Water", "Everyone didn't drink\nsome damage was taken")
	
	
	
func eat(people: People, food_count: int) -> bool:
	if food_count >= people.need_food:
		return true
	else: return false		
