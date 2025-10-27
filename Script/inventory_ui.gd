extends Control

@onready var slots_grid = $InventoryPanel/SlotsGrid
@onready var selected_icon = $SelectedItemPanel/SelectedItemIcon  # se o nó é SelectedItemIcon mesmo
@onready var selected_name = $SelectedItemPanel/SelectedItemName  # atenção para "Selected", não "Select"
@onready var selected_description = $SelectedItemPanel/SelectedItemDescription


var is_open = false
var selected_index = 0

var dragging_item: Texture2D = null   # textura do item que está flutuando
var dragging_name: String = ""
var dragging_description: String = ""
var dragging_stack: int = 1
var dragging_icon: TextureRect = null # ícone visual do item flutuante
var using_mouse_drag: bool = false


func is_inventory_open() -> bool:
	return is_open

func _ready():
	hide()
	_update_selection_visual()
	
	# Ícone flutuante
	dragging_icon = TextureRect.new()
	dragging_icon.modulate = Color(1, 1, 1, 0.8)
	dragging_icon.visible = false
	dragging_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	dragging_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH  # novo! ajuda a limitar proporção
	add_child(dragging_icon)
	
	# Define o tamanho depois de adicionar
	dragging_icon.custom_minimum_size = Vector2(74, 74)  # mesmo tamanho do ItemIcon
	
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

func toggle_drag():
	var slot = slots_grid.get_child(selected_index)
	
	# se já está arrastando, tenta colocar no slot
	if dragging_item:
		if slot.item_texture == null:
			# slot vazio: coloca o item
			slot.item_texture = dragging_item
			slot.item_name = dragging_name
			slot.item_description = dragging_description
			slot.stack_count = dragging_stack
			slot.update_slot()
			_stop_drag()
		else:
			# slot cheio: troca de lugar
			var temp_texture = slot.item_texture
			var temp_name = slot.item_name
			var temp_desc = slot.item_description
			var temp_stack = slot.stack_count
			
			slot.item_texture = dragging_item
			slot.item_name = dragging_name
			slot.item_description = dragging_description
			slot.stack_count = dragging_stack
			slot.update_slot()
			
			# novo item flutuante é o que estava no slot
			dragging_item = temp_texture
			dragging_name = temp_name
			dragging_description = temp_desc
			dragging_stack = temp_stack
			dragging_icon.texture = dragging_item
			dragging_icon.visible = true
	else:
		# começa o drag
		if slot.item_texture:
			dragging_item = slot.item_texture
			dragging_name = slot.item_name
			dragging_description = slot.item_description
			dragging_stack = slot.stack_count
			dragging_icon.texture = dragging_item
			dragging_icon.visible = true
			
			# limpa o slot
			slot.item_texture = null
			slot.item_name = ""
			slot.item_description = ""
			slot.stack_count = 0
			slot.update_slot()

func _stop_drag():
	dragging_item = null
	dragging_name = ""
	dragging_description = ""
	dragging_stack = 1
	dragging_icon.visible = false


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
	
	# move ícone flutuante para o slot selecionado
	if Input.is_action_just_pressed("ui_accept"):  
		toggle_drag()

	if dragging_item:
		if using_mouse_drag:
			# Modo mouse: segue o cursor
			dragging_icon.global_position = get_viewport().get_mouse_position() + Vector2(-15, -40)
		else:
			# Modo teclado: segue o slot selecionado
			var slot = slots_grid.get_child(selected_index)
			var base_pos = slot.get_global_position() - dragging_icon.get_parent().get_global_position()
			dragging_icon.global_position = base_pos + Vector2(25, -20)


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

func _input(event):
	if not is_open:
		return

	# clique esquerdo — comportamento estilo "pick up on click"
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# verifica se clicou em um slot
		for i in range(slots_grid.get_child_count()):
			var slot = slots_grid.get_child(i)
			# event.position está em coordenadas de janela (viewport)
			if slot.get_global_rect().has_point(event.position):
				# atualiza seleção visual e índice
				selected_index = i
				_update_selection_visual()
				# alterna o estado do drag (pegar/soltar)
				toggle_drag()
				# se após toggle nós estivermos segurando um item, marcamos modo mouse
				using_mouse_drag = dragging_item != null
				break
