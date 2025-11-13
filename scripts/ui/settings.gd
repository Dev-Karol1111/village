extends Control

@onready var fullscreen_change := $"VBox/fullscreen"
@onready var volume : HSlider = $"VBox/volume/volume_slider"

var settings_dir = "user://settings.cfg"
var config = ConfigFile.new()

var fullscreen := false
var volume_value := 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_settings()
	fullscreen_change.value_changed.connect(fullscreen_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func save_settings():
	config.set_value("audio", "music_volume", volume_value)
	config.set_value("video", "fullscreen", fullscreen)

	var err = config.save(settings_dir)
	if err != OK:
		print(err)

func load_settings():
	var err = config.load("user://settings.cfg")
	if err != OK:
		save_settings()
		return  

	volume_value = config.get_value("audio", "music_volume", volume_value)
	fullscreen = config.get_value("video", "fullscreen", fullscreen)

	volume.value = volume_value

	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_value))
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func fullscreen_changed(value):
	if value == "Fullscreen":
		fullscreen = true
	else:
		fullscreen = false

	save_settings()
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_value_changed(value: float) -> void:
	volume_value = value
	save_settings()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(volume_value))


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menu.tscn")
