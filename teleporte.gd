extends Area2D

@export var next_scene: PackedScene

func _ready() -> void:
	# garante que a Area está monitorando e conecta o sinal
	monitoring = true
	if not is_connected("body_entered", Callable(self, "_on_body_entered")):
		connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# debug — vai aparecer no Output ao testar
	print("[Area2D] body_entered -> ", body, " class=", body.get_class(), " groups=", body.get_groups())
	# checagem por grupo 'player' (mantenha o grupo no Player)
	if body.is_in_group("player"):
		if next_scene:
			# usa call_deferred pra evitar problemas de trocar cena no mesmo frame
			get_tree().call_deferred("change_scene_to_packed", next_scene)
			print("[Area2D] trocando pra cena:", next_scene)
		else:
			print("[Area2D] next_scene não foi setada no Inspector")
