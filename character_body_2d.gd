extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim = $AnimatedSprite2D 

var base_y = 0.0
var walk_cycle = 0.0

func _ready():
	base_y = anim.position.y
	anim.play("frente")
	anim.speed_scale = 1.0  

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# Movimento
	velocity = input_vector * speed
	move_and_slide()
	
	
	if input_vector.y > 0:  
		anim.play("frente") 
		walk_cycle += delta * 18.0
		anim.position.y = base_y + sin(walk_cycle) * 1.5 
	elif input_vector.y < 0:  
		anim.play("costas")
		anim.position.y = base_y + sin(walk_cycle) * 1.5 
		walk_cycle += delta * 18.0
	elif input_vector.x > 0:  
		anim.play("direita")
		anim.position.y = base_y + sin(walk_cycle) * 1.5
		walk_cycle += delta * 18.0
	elif input_vector.x < 0:  
		anim.play("esquerda")
		anim.position.y = base_y + sin(walk_cycle) * 1.5
		walk_cycle += delta * 18.0
	else:
		# parado
		anim.stop()
		anim.frame = 0
		anim.position.y = base_y
		walk_cycle = 0.0
