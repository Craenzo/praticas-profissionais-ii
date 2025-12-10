extends NinePatchRect

@onready var text := $Text
@onready var timer := $Timer
var msg_queue: Array = [
	"...",
	"Onde estou?",
	"O que é esse lugar?"
]

func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		show_message()

func show_message() -> void:
	# se o timer está rodando, revela tudo e volta
	if not timer.is_stopped():
		text.set_visible_characters(text.get_total_character_count())
		return

	if msg_queue.size() == 0:
		hide()
		return

	var _msg: String = msg_queue.pop_front()
	text.bbcode_text = _msg
	text.set_visible_characters(0)
	print(msg_queue)
	timer.start()

func _on_timer_timeout() -> void:
	var v: int = text.get_visible_characters()  # <-- tipagem adicionada aqui
	v += 1
	text.set_visible_characters(v)
	if v >= text.get_total_character_count():
		timer.stop()
