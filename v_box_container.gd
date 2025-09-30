extends Control

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button"):
		button.connect("pressed", self, "on_button_pressed", [button])
		button.connect("mouse_exited", self, "mouse_interaction", [button, "exited"])
		button.connect("mouse_entered", self, "mouse_interaction", [button, "entered"])


func on_button_pressed(button: Button) -> void:
	match button.name:
		"Play":
			var _game: bool = get_tree().change_scene("res://scenes/interface/mic_screen.tscn")
		"ConfigureMic":
			var _mic: bool = get_tree().change_scene("res://scenes/interface/mic_screen.tscn")
		"Controls":
			var _controls: bool = get_tree().change_scene("res://scenes/interface/controls.tscn")
		"DevBandeira":
			var _open_channel: bool = OS.shell_open("https://www.youtube.com/@DevBandeira/feat")
		"Quit":
			get_tree().quit()
