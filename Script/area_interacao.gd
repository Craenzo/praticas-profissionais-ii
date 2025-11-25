extends Area2D

signal interacted
signal interaction_available
signal interaction_unavailable

@export var interact_input_action := "Interagir"

var _player_inside: bool = false

func _ready() -> void:
	# conecta entradas/saídas (área/body) usando Callable no is_connected
	if not is_connected("area_entered", Callable(self, "_on_any_entered")):
		connect("area_entered", Callable(self, "_on_any_entered"))
	if not is_connected("area_exited", Callable(self, "_on_any_exited")):
		connect("area_exited", Callable(self, "_on_any_exited"))
	if not is_connected("body_entered", Callable(self, "_on_any_entered")):
		connect("body_entered", Callable(self, "_on_any_entered"))
	if not is_connected("body_exited", Callable(self, "_on_any_exited")):
		connect("body_exited", Callable(self, "_on_any_exited"))
	set_process(false) # só processa quando o player entrar

func _on_any_entered(other) -> void:
	if not _is_player(other):
		return
	_player_inside = true
	set_process(true)
	emit_signal("interaction_available")

func _on_any_exited(other) -> void:
	if not _is_player(other):
		return
	_player_inside = false
	set_process(false)
	emit_signal("interaction_unavailable")

func _process(_delta: float) -> void:
	if not _player_inside:
		return
	if Input.is_action_just_pressed(interact_input_action):
		emit_signal("interacted")

func _is_player(node: Node) -> bool:
	if node == null:
		return false
	if node.name == "Player" or node.is_in_group("player"):
		return true
	var n := node.get_parent()
	while n:
		if n.name == "Player" or n.is_in_group("player"):
			return true
		n = n.get_parent()
	return false
