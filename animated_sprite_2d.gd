extends AnimatedSprite2D

@export var animation_name: String = "caixaovermelho"
@export var realidade_scene_path: String = "res://path/to/RealidadeQuebrando.tscn" # trocar pelo caminho real

var _destroyed: bool = false
var _area_ref: Node = null
var _blocker_shape: CollisionShape2D = null

func _ready() -> void:
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

	_blocker_shape = get_node_or_null("Blocker/CollisionShape2D")
	if _blocker_shape == null:
		_blocker_shape = find_blocker_recursive(self)
	if _blocker_shape:
		_blocker_shape.disabled = false
	else:
		push_warning("CaixaoTerciario: blocker (Blocker/CollisionShape2D) não encontrado.")

func _find_area_with_signal() -> Node:
	var n := get_parent()
	while n:
		if n.has_signal("interaction_available"):
			return n
		n = n.get_parent()
	return null

func find_blocker_recursive(node: Node) -> CollisionShape2D:
	for c in node.get_children():
		if c is CollisionShape2D and String(c.name).to_lower().find("block") != -1:
			return c
		var child_blocker := find_blocker_recursive(c)
		if child_blocker:
			return child_blocker
	return null

func _on_area_interacao_interaction_available() -> void:
	return

func _on_area_interacao_interaction_unavailable() -> void:
	if _destroyed:
		return
	stop()
	frame = 0

func _on_area_interacao_interacted() -> void:
	if _destroyed:
		return
	if _blocker_shape:
		_blocker_shape.disabled = true
	else:
		push_warning("CaixaoTerciario: não foi possível desativar colisão (blocker ausente).")

	var sf := _get_sprite_frames() as SpriteFrames
	if sf and animation_name in sf.get_animation_names():
		animation = animation_name
		frame = 0
		play()
		_destroyed = true
		if _area_ref and _area_ref.is_connected("interacted", Callable(self, "_on_area_interacao_interacted")):
			_area_ref.disconnect("interacted", Callable(self, "_on_area_interacao_interacted"))
		if not is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			connect("animation_finished", Callable(self, "_on_animation_finished"))
	else:
		push_error("CaixaoTerciario: SpriteFrames ausente ou a animação '%s' não existe." % animation_name)

func _on_animation_finished() -> void:
	# Para a animação e fixa no último frame (não remove o nó)
	stop()
	var sf := _get_sprite_frames() as SpriteFrames
	if sf and animation != "" and animation in sf.get_animation_names():
		var last_index := sf.get_frame_count(animation) - 1
		if last_index >= 0:
			frame = last_index

	# --- agora instancia/ativa a cena da "RealidadeQuebrando" ---
	if realidade_scene_path == "":
		push_warning("CaixaoTerciario: realidade_scene_path vazio. Não foi possível instanciar RealidadeQuebrando.")
		return

	var sc := null
	# tenta carregar com preload dinâmico
	var ok := true
	var packed := null
	# cuidado com erros de carga: uso de load() ao inves de preload pra permitir path editável no inspector
	packed = ResourceLoader.load(realidade_scene_path)
	if not packed:
		push_error("CaixaoTerciario: não foi possível carregar a cena em '%s'." % realidade_scene_path)
		return

	sc = packed.instantiate()
	if not sc:
		push_error("CaixaoTerciario: falha ao instanciar RealidadeQuebrando.")
		return

	# adiciona no mesmo pai do caixão (ou usa get_tree().root se quiser global)
	var parent_node = get_parent() if get_parent() != null else get_tree().current_scene
	parent_node.add_child(sc)
	# posiciona no mesmo lugar (se a cena for Node2D)
	if sc is Node2D:
		sc.global_position = (self.global_position if self is Node2D else Vector2.ZERO)

	# tenta ativar a animação na cena instanciada:
	# 1) se ela ter método play_reality() chama ele
	if sc.has_method("play_reality"):
		sc.call("play_reality")
		return

	# 2) tenta procurar por um AnimatedSprite2D filho e tocar a animação "RealidadeQuebrando"
	var spr := sc.get_node_or_null("AnimatedSprite2D")
	if spr and spr is AnimatedSprite2D:
		if spr.has_animation("RealidadeQuebrando") or "RealidadeQuebrando" in (spr.frames.get_animation_names() if spr.frames else []):
			spr.animation = "RealidadeQuebrando"
			spr.frame = 0
			spr.play()
			return

	# 3) tenta AnimationPlayer
	var ap := sc.get_node_or_null("AnimationPlayer")
	if ap and ap is AnimationPlayer and ap.has_animation("RealidadeQuebrando"):
		ap.play("RealidadeQuebrando")
		return

	# fallback: não encontrou forma óbvia de tocar a animação
	push_warning("CaixaoTerciario: instanciada RealidadeQuebrando mas não achei como iniciar a animação automaticamente. Adicione método 'play_reality' na cena alvo ou um AnimatedSprite2D/AnimationPlayer com a animação 'RealidadeQuebrando'.")

func _get_sprite_frames():
	for p in get_property_list():
		var n := String(p.name)
		if n == "sprite_frames" or n == "frames":
			return get(n)
	return null
