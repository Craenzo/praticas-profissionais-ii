extends Control

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("button"):
		# bind() liga os argumentos ao Callable — assim connect recebe só (signal, callable)
		button.connect("pressed", Callable(self, "on_button_pressed").bind(button))
		button.connect("mouse_exited", Callable(self, "mouse_interaction").bind(button, "exited"))
		button.connect("mouse_entered", Callable(self, "mouse_interaction").bind(button, "entered"))


func on_button_pressed(button: Button) -> void:
	match button.name:
		"Jogar":
			var _game: bool = get_tree().change_scene("#COLOQUE-AQUI-O-CAMINHO-DO-JOGO")
		"Saves":
			var _mic: bool = get_tree().change_scene("#COLOQUE-AQUI-O-CAMINHO-DO-BANCO-DE-DADOS")
		"Config":
			var _controls: bool = get_tree().change_scene("#COLOQUE-AQUI-O-CAMINHO-DA-TELA-DE-CONFIG")
		"Thegaymers":
			var _open_channel: bool = OS.shell_open("https://www.youtube.com/@corinthians")
		"quit":
			get_tree().quit()
