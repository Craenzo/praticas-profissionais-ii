# Cutscene.gd
extends Node

@export var dialog_scene: PackedScene                     # arrasta tua cena de diálogo aqui (opcional)
@export var dialog_lines: Array = ["Oi.", "Vamos lá."]   # falas curtas padrão (2 falas)
@export var fade_in_time: float = 1.0
@export var visible_hold_time: float = 0.3
@export var fade_back_time: float = 2.0
@export var max_player_find_frames: int = 60             # quantas frames tentar achar o player

var _player: Node = null
var _canvas_modulate: CanvasModulate = null
var _saved_canvas_color: Color = Color(1,1,1,1)


func _init_and_maybe_start() -> void:
	_player = _find_player()
	var tries := 0
	while not _player and tries < max_player_find_frames:
		await get_tree().process_frame
		_player = _find_player()
		tries += 1

	if not _player:
		push_warning("Cutscene: não encontrei o Player na cena. Coloque o Player no grupo 'player' ou verifique o nome do node.")
		return

	_canvas_modulate = _find_canvas_modulate(_player)
	if _canvas_modulate:
		_saved_canvas_color = _canvas_modulate.color
	else:
		push_warning("Cutscene: CanvasModulate não encontrado dentro do Player. Ajuste a cena do Player ou coloque um CanvasModulate como filho do CharacterBody2D.")

	# roda somente se for new game (assumindo GameState autoload)
	if Engine.has_singleton("GameState") or ("GameState" in globals()):
		# tenta acessar GameState - se não existir, roda na boa (útil pra testes)
		if typeof(GameState) == TYPE_OBJECT and GameState.has_method("get"):
			# nada aqui, só evitando erro se GameState existir
			pass

	# se existir GameState e for new game, roda. Se não existir GameState, rodará assim mesmo.
	var should_run := true
	if "GameState" in globals():
		should_run = GameState.is_new_game

	if should_run:
		_run_cutscene()
	else:
		queue_free()  # não precisa ficar na cena se já não for new game

# ------------ implementação ------------------
func _run_cutscene() -> void:
	# bloqueia player
	_disable_player_controls(true)

	# 1) começa totalmente preto => depois abre pra visão total (neutral = Color(1,1,1,1))
	if _canvas_modulate:
		_canvas_modulate.color = Color(0,0,0,1)  # tudo preto
		var tw = create_tween()
		# tween pra neutro (visão total)
		tw.tween_property(_canvas_modulate, "color", Color(1,1,1,1), fade_in_time)
		await tw.finished
	else:
		# se não tem canvas, só espera o tempo de fade_in
		await get_tree().create_timer(fade_in_time).timeout

	await get_tree().create_timer(visible_hold_time).timeout

	# 2) instancia diálogo se tiver
	if dialog_scene:
		var dlg = dialog_scene.instantiate()
		add_child(dlg)
		# tenta API comum: start(lines) e sinal dialog_finished
		if dlg.has_method("start"):
			dlg.start(dialog_lines)
			if dlg.has_signal("dialog_finished"):
				# espera o sinal
				await dlg.dialog_finished
			else:
				# fallback: espera tempo proporcional
				await get_tree().create_timer(max(visible_hold_time, 1.2)).timeout
		else:
			# fallback simples: mostra por um tempo e remove
			await get_tree().create_timer(max(visible_hold_time, 1.2)).timeout

		if is_instance_valid(dlg):
			dlg.queue_free()
	else:
		# sem diálogo, apenas espera um tiquinho
		await get_tree().create_timer(visible_hold_time).timeout

	# 3) fade de volta para cor original (que limita visão)
	if _canvas_modulate:
		var back = create_tween()
		back.tween_property(_canvas_modulate, "color", _saved_canvas_color, fade_back_time)
		await back.finished
	else:
		await get_tree().create_timer(fade_back_time).timeout

	# 4) reativa player e marca que não é mais new game
	_disable_player_controls(false)
	if "GameState" in globals():
		GameState.is_new_game = false

	# fim da cutscene: remove-se
	queue_free()

# ------------ utilitários --------------------
func _disable_player_controls(disable: bool) -> void:
	if not _player:
		return
	if _player.has_method("set_controls_enabled"):
		_player.set_controls_enabled(not not (not disable == false)) # chamada direta
		# (chamamos com bool diretamente)
		_player.set_controls_enabled(not disable) if _player.has_method("set_controls_enabled") else null
		return

	# fallbacks
	if disable:
		if _player.has_method("set_physics_process"):
			_player.set_physics_process(false)
		_player.set_process_input(false)
		# desativa colisões se houver CollisionShape2D filhos
		for c in _player.get_children():
			if c is CollisionShape2D:
				c.disabled = true
	else:
		if _player.has_method("set_physics_process"):
			_player.set_physics_process(true)
		_player.set_process_input(true)
		for c in _player.get_children():
			if c is CollisionShape2D:
				c.disabled = false

func _find_player() -> Node:
	# 1) procura por grupo 'player'
	var arr := get_tree().get_nodes_in_group("player")
	if arr.size() > 0:
		return arr[0]

	# 2) procura por node chamado "Player" (nó root do player geralmente)
	if has_node("/root/Node/Player"):
		return get_node("/root/Node/Player")  # tentativa rápida (pode falhar conforme estrutura)

	# 3) procura em toda cena por CharacterBody2D que contenha CanvasModulate (heurística)
	for n in get_tree().get_root().get_children():
		var found = _search_for_player_in_tree(n)
		if found:
			return found
	return null

func _search_for_player_in_tree(node: Node) -> Node:
	if node is CharacterBody2D:
		# tem CanvasModulate filho?
		for ch in node.get_children():
			if ch is CanvasModulate:
				return node
	# recursão
	for ch in node.get_children():
		var f = _search_for_player_in_tree(ch)
		if f:
			return f
	return null

func _find_canvas_modulate(player_node: Node) -> CanvasModulate:
	if not player_node:
		return null
	# procura filho direto
	var cm := player_node.get_node_or_null("CanvasModulate")
	if cm and cm is CanvasModulate:
		return cm
	# procura recursivamente
	for ch in player_node.get_children():
		if ch is CanvasModulate:
			return ch
		var deeper := _find_canvas_modulate(ch)
		if deeper:
			return deeper
	return null
