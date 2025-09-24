extends CharacterBody2D

@export var speed: float = 200.0
@onready var sprite = $Sprite2D  

# pré-carregando as texturas
var frente = preload("res://Catarina_Frente.png")
var costas = preload("res://Catarina_Costa.png")
var direita = preload("res://Catarina_Direita.png")
var esquerda = preload("res://Catarina_Esquerda.png")

func _ready():
	sprite.texture = frente

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# Movimento
	velocity = input_vector * speed
	move_and_slide()
	
	# Trocar sprite de acordo com a direção
	if input_vector.y < 0:
		sprite.texture = costas
	elif input_vector.y > 0:
		sprite.texture = frente
	elif input_vector.x > 0:
		sprite.texture = direita
	elif input_vector.x < 0:
		sprite.texture = esquerda
