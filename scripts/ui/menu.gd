extends Control

@onready var main_animation : AnimationPlayer = $"main/AnimationPlayer"
@onready var game_choose_animation : AnimationPlayer = $"game_choose/AnimationPlayer"
@onready var game_choose : VBoxContainer = $game_choose

func _ready() -> void:
	load("res://scenes/ui/settings.tscn").instantiate().load_settings(true)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	main_animation.play("moving")
	game_choose.visible = true
	game_choose_animation.play("moving")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/settings.tscn")

func _on_new_game_pressed() -> void:
	Managment.continue_preevious_game = false
	get_tree().change_scene_to_file("res://scenes/map.tscn")

func _on_continue_pressed() -> void:
	Managment.continue_preevious_game = true
	get_tree().change_scene_to_file("res://scenes/map.tscn")
