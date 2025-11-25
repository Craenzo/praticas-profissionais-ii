extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	for node in get_tree().get_nodes_in_group("button"):
	   
		if node is Button:
			node.connect("pressed", Callable(self, "on_button_pressed").bind(node))
		if node.has_signal("mouse_entered"):
			node.connect("mouse_entered", Callable(self, "mouse_interaction").bind(node, "entered"))
		if node.has_signal("mouse_exited"):
			node.connect("mouse_exited", Callable(self, "mouse_interaction").bind(node, "exited"))


#quando um botão é pressionado
func on_button_pressed(button: Button) -> void:
	match button.name:
		"Jogar":
			var err = get_tree().change_scene_to_file("res://Cenas/Calabouço/Quarto1-MP1.tscn")
			if err != OK:
				push_error("Falha ao trocar para player.tscn: %s" % str(err))
		"Saves":
			# ajuste o caminho para a cena de saves se tiver uma
			var err2 = get_tree().change_scene_to_file("")
			if err2 != OK:
				push_error("Falha ao trocar para saves.tscn: %s" % str(err2))
		"Config":
			var err3 = get_tree().change_scene_to_file("res://Cenas/Menus/Menu_config.tscn")
			if err3 != OK:
				push_error("Falha ao trocar para config.tscn: %s" % str(err3))
		"Thegamers":
			# abre link externo (substitua se quiser outro URL)
			OS.shell_open("https://www.youtube.com/@corinthians")
		"quit":
			get_tree().quit()
		
