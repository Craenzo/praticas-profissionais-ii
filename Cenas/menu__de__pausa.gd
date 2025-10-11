extends CanvasLayer


@onready var continue_btn: TextureButton = $ColorRect/menu_holder/continue_btn
@onready var quit_btn_2: TextureButton = $ColorRect/menu_holder/quit_btn
@onready var animacao: AnimationPlayer = $Animacao


func _ready() -> void:
	visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = true
		#animator.play("puasa_animation")
		get_tree().paused = true
		continue_btn.grab_focus()
	


func _on_continue_btn_pressed() -> void:
#	animator.play("continue_animation_2")
	get_tree().paused = false
	#await animator.animation_finished
	visible = false
	
	


func _on_quit_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/menu.tscn")
