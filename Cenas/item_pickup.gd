extends Area2D

@export var item_data: ItemData # aqui você vai colocar o ChavePixelada.tres

@onready var label = $InteractLabel
@onready var sprite = $Sprite2D

var player_in_area = false

func _ready():
	if item_data:
		sprite.texture = item_data.item_texture  # pega a textura do recurso
	label.visible = false  # começa invisível

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = true
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = false
		label.visible = false

func _on_area_entered(area):
	if area.is_in_group("player") or (area.get_parent() and area.get_parent().is_in_group("player")):
		player_in_area = true
		label.visible = true

func _on_area_exited(area):
	if area.is_in_group("player") or (area.get_parent() and area.get_parent().is_in_group("player")):
		player_in_area = false
		label.visible = false

func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if item_data:
			var inventory = get_tree().get_first_node_in_group("inventory_ui")
			if inventory:
				inventory.add_item(item_data)  # passa o resource inteiro
				queue_free()  # remove o item do mapa
