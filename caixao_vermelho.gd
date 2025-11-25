extends AnimatedSprite2D

@export var animation_name: String = "caixaovermelho"

const REALIDADE_ANIM: String = "realidadequebrando"
@onready var realidade_node: Node = get_node_or_null("../RealidadeQuebrando")

var _destroyed: bool = false
var _area_ref: Node = null
var _blocker_shape: CollisionShape2D = null

func _ready() -> void:
	# conecta AreaInteracao no ancestor
	_area_ref = _find_area_with_signal()
	if _area_ref:
		if not _area_ref.is_connected("interaction_available", Callable(self, "_on_area_interacao_interaction_available")):
			_area_ref.connect("interaction_available", Callable(self, "_on_area_interacao_interaction_available"))
		if not _area_ref.is_connected("interaction_unavailable", Callable(self, "_on_area_interacao_interaction_unavailable")):
			_area_ref.connect("interaction_unavailable", Callable(self, "_on_area_interacao_interaction_unavailable"))
		if not _area_ref.is_connected("interacted", Callable(self, "_on_area_interacao_interacted")):
			_area_ref.connect("interacted", Callable(self, "_on_area_interacao_interacted"))
	else:
		push_warning("CaixaoTerciario: não encontrou AreaInteracao ancestor com sinais. Verifique hierarquia.")

	# procura o CollisionShape2D bloqueador (Blocker/CollisionShape2D)
	_blocker_shape = get_node_or_null("Blocker/CollisionShape2D")
	if _blocker_shape == null:
		_blocker_shape = find_blocker_recursive(self)
	if _blocker_shape:
		_blocker_shape.disabled = false
	else:
		push_warning("CaixaoTerciario: blocker (Blocker/CollisionShape2D) não encontrado.")

	# conecta o signal de fim de animação (se ainda não conectado)
	if not is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		connect("animation_finished", Callable(self, "_on_animation_finished"))


func _find_area_with_signal() -> Node:
	var n := get_parent()
	while n:
		if n.has_signal("interaction_available"):
			return n
		n = n.get_parent()
	return null


# procura recursivamente por um CollisionShape2D cujo nome contenha "block" (fallback)
func find_blocker_recursive(node: Node) -> CollisionShape2D:
	for c in node.get_children():
		if c is CollisionShape2D and String(c.name).to_lower().find("block") != -1:
			return c
		var child_blocker := find_blocker_recursive(c)
		if child_blocker:
			return child_blocker
	return null


func _on_area_interacao_interaction_available() -> void:
	# nada aqui por enquanto
	return


func _on_area_interacao_interaction_unavailable() -> void:
	if _destroyed:
		return
	stop()
	frame = 0


func _on_area_interacao_interacted() -> void:
	if _destroyed:
		return

	# desativa colisão para permitir o jogador passar
	if _blocker_shape:
		_blocker_shape.disabled = true
	else:
		push_warning("CaixaoTerciario: não foi possível desativar colisão (blocker ausente).")

	# toca animação do caixão
	var sf := _get_sprite_frames() as SpriteFrames
	if sf and animation_name in sf.get_animation_names():
		animation = animation_name
		frame = 0
		play()
		_destroyed = true

		# desconecta para evitar re-chamadas
		if _area_ref and _area_ref.is_connected("interacted", Callable(self, "_on_area_interacao_interacted")):
			_area_ref.disconnect("interacted", Callable(self, "_on_area_interacao_interacted"))
	else:
		push_error("CaixaoTerciario: SpriteFrames ausente ou a animação '%s' não existe." % animation_name)


func _on_animation_finished() -> void:
	# só reage se a animação que acabou for a do caixão
	if animation != animation_name:
		return

	# mantém o último frame do caixão
	stop()
	var sf := _get_sprite_frames() as SpriteFrames
	if sf and animation in sf.get_animation_names():
		var last_index := sf.get_frame_count(animation) - 1
		if last_index >= 0:
			frame = last_index

	# inicia a animação 'realidadequebrando' no node irmão
	if realidade_node:
		if realidade_node is AnimatedSprite2D:
			var rsprite := realidade_node as AnimatedSprite2D
			var rsf := rsprite.sprite_frames
			if rsf and REALIDADE_ANIM in rsf.get_animation_names():
				rsprite.animation = REALIDADE_ANIM
				rsprite.frame = 0
				rsprite.play()
			else:
				# tenta tocar por nome mesmo assim (fallback)
				rsprite.play(REALIDADE_ANIM)
		elif realidade_node is AnimationPlayer:
			# cast seguro e execução
			var ap := realidade_node as AnimationPlayer
			ap.play(REALIDADE_ANIM)
		else:
			push_warning("CaixaoTerciario: ../RealidadeQuebrando existe, mas não é AnimatedSprite2D nem AnimationPlayer.")
	else:
		push_warning("CaixaoTerciario: ../RealidadeQuebrando não encontrado.")


# helper para pegar SpriteFrames desse AnimatedSprite2D
func _get_sprite_frames():
	for p in get_property_list():
		var n := String(p.name)
		if n == "sprite_frames" or n == "frames":
			return get(n)
	return null
