extends Control

@onready var slots_grid = $InventoryPanel/SlotsGrid
@onready var selected_icon = $SelectedItemPanel/SelectedItemIcon  # se o nó é SelectedItemIcon mesmo
@onready var selected_name = $SelectedItemPanel/SelectedItemName  # atenção para "Selected", não "Select"
@onready var selected_description = $SelectedItemPanel/SelectedItemDescription


var is_open = false
var selected_index = 0

func is_inventory_open() -> bool:
	return is_open

func _ready():
	hide()
	_update_selection_visual()
	# --- TESTE: adicionar item ---
	#var test_texture = preload("res://Assets/Textures/pixelated_key.png")  # troque pelo caminho real
	#add_item(test_texture, "Item de teste")
	
func add_item(item: ItemData):
	for i in range(slots_grid.get_child_count()):
		var slot = slots_grid.get_child(i)
		if slot.item_texture == null:
			slot.item_texture = item.item_texture
			slot.item_description = item.item_description
			slot.item_name = item.item_name
			slot.update_slot()
			return



func _process(_delta):
	if Input.is_action_just_pressed("inventory_toggle"):
		is_open = !is_open
		if is_open:
			show()
		else:
			hide()

	if not is_open:
		return

	_handle_navigation()
	_update_selection_visual()

func _handle_navigation():
	var prev_index = selected_index
	var columns = slots_grid.columns
	var total_slots = slots_grid.get_child_count()

	if Input.is_action_just_pressed("inv_left"):
		selected_index = max(selected_index - 1, 0)
	elif Input.is_action_just_pressed("inv_right"):
		selected_index = min(selected_index + 1, total_slots - 1)
	elif Input.is_action_just_pressed("inv_up"):
		selected_index = max(selected_index - columns, 0)
	elif Input.is_action_just_pressed("inv_down"):
		selected_index = min(selected_index + columns, total_slots - 1)

	if prev_index != selected_index:
		_update_selected_item_info()

func _update_selection_visual():
	for i in range(slots_grid.get_child_count()):
		var slot = slots_grid.get_child(i)
		if i == selected_index:
			slot.modulate = Color(1, 1, 1) # branco normal
			slot.add_theme_color_override("font_color", Color(1, 1, 1))
			slot.add_theme_color_override("font_hover_color", Color(1, 1, 1))
			slot.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
			slot.self_modulate = Color(1.2, 1.2, 1.2) # levemente destacado
		else:
			slot.self_modulate = Color(0.8, 0.8, 0.8) # opaco

func _update_selected_item_info():
	var selected_slot = slots_grid.get_child(selected_index)
	if selected_slot.item_texture:
		selected_icon.texture = selected_slot.item_texture
	else:
		selected_icon.texture = null
	selected_description.text = selected_slot.item_description if selected_slot.item_description != "" else "Sem descrição."
	selected_name.text = selected_slot.item_name if selected_slot.item_name != "" else "Sem nome"
