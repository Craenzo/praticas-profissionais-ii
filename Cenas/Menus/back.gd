extends Button

func _ready() -> void:
	# Godot 4 exige que a função não receba parâmetros quando você usa o sinal pressed
	pressed.connect(_voltar_para_menu)


func _voltar_para_menu() -> void:   # <- sem parâmetros!
	get_tree().change_scene_to_file("res://Cenas/Menus/Menu_config.tscn")
