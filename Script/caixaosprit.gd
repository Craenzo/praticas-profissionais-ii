extends AnimatedSprite2D

@export var animation_name := "default"
@export var blocker_path := NodePath("../Blocker") # caminho relativo do sprite para o StaticBody2D
@export var remove_blocker_on := "start" # "start" ou "end"

var _interacted := false
var _blocker: StaticBody2D = null
var _area_ref: Node = null

func _ready() -> void:
	# encontra o blocker (StaticBody2D) pela path exportada
	_blocker = get_node_or_null(blocker_path)
	if _blocker:
		_blocker.disabled = false
	else:
		push_warning("CaixaoSprite: blocker não encontrado em '%s'." % str(blocker_path))

	# encontra ancestor que emite os sinais (AreaInteracao) e conecta
	_area_ref = _find_area_with_signal()
	if _area_ref:
		if not _area_ref.is_connected("interacted", Callable(self, "_on_area_interacao_interacted")):
			_area_ref.connect("interacted", Callable(self, "_on_area_interacao_interacted"))
	else:
		push_warning("CaixaoSprite: não encontrou AreaInteracao ancestor com sinais.")

func _find_area_with_signal() -> Node:
	var n := get_parent()
	while n:
		if n.has_signal("interacted"):
			return n
		n = n.get_parent()
	return null

func _on_area_interacao_interacted() -> void:
	if _interacted:
		return
	_interacted = true

	if remove_blocker_on == "start" and _blocker:
		_blocker.set_deferred("disabled", true)

	var sf := _get_sprite_frames() as SpriteFrames
	if sf and animation_name in sf.get_animation_names():
		animation = animation_name
		play()
		if not is_connected("animation_finished", Callable(self, "_on_animation_finished")):
			connect("animation_finished", Callable(self, "_on_animation_finished"))
	else:
		push_error("CaixaoSprite: animação '%s' não existe." % animation_name)

func _on_animation_finished() -> void:
	if remove_blocker_on == "end" and _blocker:
		_blocker.set_deferred("disabled", true)
	queue_free()

func _get_sprite_frames():
	for p in get_property_list():
		var n := String(p.name)
		if n == "sprite_frames" or n == "frames":
			return get(n)
	return null
