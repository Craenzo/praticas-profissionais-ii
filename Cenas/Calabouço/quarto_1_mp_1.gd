extends Node2D

@onready var player: Node2D = $Player
@onready var cutscene_anim: AnimationPlayer = $CutsceneUI/CutsceneAnim

# Agora procura o CanvasModulate onde quer que ele esteja (dentro do Player ou fora)
var canvas_modulate: CanvasModulate

func _ready() -> void:
	# Encontra o CanvasModulate automaticamente (funciona 100 %)
	canvas_modulate = $Player.find_child("CanvasModulate*", true, false) as CanvasModulate
	
	if canvas_modulate == null:
		push_error("CanvasModulate não encontrado dentro do Player!")
		return
	
	start_intro_cutscene()

func start_intro_cutscene() -> void:
	get_tree().paused = true
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	# Força preto total no começo
	canvas_modulate.color = Color(0, 0, 0, 1)
	
	cutscene_anim.play("inicio_cutscene")
	cutscene_anim.animation_finished.connect(_on_cutscene_end, CONNECT_ONE_SHOT)

func _on_cutscene_end(_anim_name: StringName) -> void:
	get_tree().paused = false
	player.process_mode = Node.PROCESS_MODE_INHERIT
	print("Cutscene concluída — jogador livre!")
