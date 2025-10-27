extends TextureButton

@export var item_name: String = ""
@export var item_description: String = ""
@export var item_texture: Texture2D
@export var stack_count: int = 1

@onready var icon: TextureRect = $ItemIcon

func _ready():
	update_slot()

func update_slot():
	if item_texture:
		icon.texture = item_texture
		icon.visible = true
	else:
		icon.texture = null
		icon.visible = false
