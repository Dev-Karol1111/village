extends Control

@onready var fullscreen_change: = $"VBox/fullscreen"
@onready var volume: HSlider = $"VBox/volume/volume_slider"
@onready var language_change := $"VBox/language"

var settings_dir = "user://settings.cfg"
var config = ConfigFile.new()

var fullscreen: = false
var volume_value: = 0.8
var language := "en"

func _ready() -> void :
	load_settings()
	fullscreen_change.value_changed.connect(fullscreen_changed)
	language_change.value_changed.connect(language_changed)

func _process(_delta: float) -> void :
	pass

func save_settings():
	config.set_value("audio", "music_volume", volume_value)
	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "language", language)
	
	var err = config.save(settings_dir)
	if err != OK:
		print(err)

func load_settings(pre_loading: bool = false):
	var err = config.load("user://settings.cfg")
	if err != OK:
		save_settings()
		return

	volume_value = config.get_value("audio", "music_volume", volume_value)
	fullscreen = config.get_value("video", "fullscreen", fullscreen)
	language = config.get_value("video", "language", language)	
	
	
	if !pre_loading:
		volume.value = volume_value

		if !fullscreen:
			fullscreen_change.select(-1)
			
		if language != "en":
			language_change.select(-1)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_value))
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	TranslationServer.set_locale(language)

func language_changed(value):
	if value == "English":
		language = "en"
	elif value == "Polish":
		language = "pl"
	
	save_settings()
	TranslationServer.set_locale(language)
		
func fullscreen_changed(value):
	if value == "fullscreen":
		fullscreen = true
	else:
		fullscreen = false

	save_settings()
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_value_changed(value: float) -> void :
	volume_value = value
	save_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_value))


func _on_back_to_menu_pressed() -> void :
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
