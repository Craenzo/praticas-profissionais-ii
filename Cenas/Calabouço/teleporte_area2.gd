extends Area2D

@export var target_scene: String = "res://Cenas/Calabouço/quarto_3.tscn"  # MUDE pro caminho CERTO da sua cena! (vi na imagem)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("TeleportArea ativa! Monitoring: ", monitoring)  # Debug: roda no Output

func _on_body_entered(body: Node2D) -> void:
	print("ALGUÉM ENTROU! Nome: ", body.name)  # Debug 1
	if body.is_in_group("player"):
		print("É O PLAYER! Teleportando pra: ", target_scene)  # Debug 2
		get_tree().change_scene_to_file(target_scene)
	else:
		print("Não é player, ignorando.")
