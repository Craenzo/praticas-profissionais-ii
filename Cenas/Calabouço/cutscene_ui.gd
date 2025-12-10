extends CanvasLayer

@export var type_speed: float = 0.04

@onready var labels = [
	$Dialogos/Label,
	$Dialogos/Label2,
	$Dialogos/Label3
]

var current_label_index = 0

func typewrite_text(text: String) -> void:
	if current_label_index >= labels.size():
		return
	
	var label = labels[current_label_index]
	label.text = ""
	label.visible_ratio = 0.0
	label.text = text
	
	for i in text.length():
		label.visible_ratio = float(i + 1) / text.length()
		await get_tree().create_timer(type_speed).timeout
	
	current_label_index += 1
