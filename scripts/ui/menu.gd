extends Control

func _ready() -> void:
	load("res://scenes/ui/settings.tscn").instantiate().load_settings(true)

func _on_exit_pressed() -> void:
	get_tree().quit()
	

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")
