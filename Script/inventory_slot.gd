extends TextureButton

@export var item_name: String = ""
@export var item_description: String = ""
@export var item_texture: Texture2D
@export var stack_count: int = 1

@onready var icon: TextureRect = $ItemIcon

signal mouse_entered_slot(slot_index)
signal mouse_clicked_slot(slot_index)

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	update_slot()
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("pressed", Callable(self, "_on_pressed"))

func update_slot():
	if item_texture:
		icon.texture = item_texture
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false

func _on_mouse_entered():
	emit_signal("mouse_entered_slot", get_slot_index())

func _on_pressed():
	emit_signal("mouse_clicked_slot", get_slot_index())

func get_slot_index() -> int:
	return get_parent().get_children().find(self)
