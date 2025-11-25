extends Node2D

# se quiser, exporta o nome da animacao
@export var reality_animation_name: String = "RealidadeQuebrando"

func _ready() -> void:
	# NÃO chamar play() aqui — assim a cena fica inativa até o caixão chamar play_reality()
	pass

func play_reality() -> void:
	var spr := get_node_or_null("AnimatedSprite2D")
	if spr and spr is AnimatedSprite2D:
		if spr.frames and reality_animation_name in spr.frames.get_animation_names():
			spr.animation = reality_animation_name
			spr.frame = 0
			spr.play()
			return
	# tenta AnimationPlayer caso exista
	var ap := get_node_or_null("AnimationPlayer")
	if ap and ap is AnimationPlayer and ap.has_animation(reality_animation_name):
		ap.play(reality_animation_name)
		return
	push_warning("RealidadeQuebrandoScene: não encontrei a animação '%s' nem AnimatedSprite2D/AnimationPlayer apropriado." % reality_animation_name)
