extends CharacterBody2D

@export var speed: float = 200.0
@onready var anim = $AnimatedSprite2D 

var base_y = 0.0
var walk_cycle = 0.0

var blink_timer = 0.0
var blink_interval = 4.0 

var current_dir = "front"  


func _ready():
	base_y = anim.position.y
	anim.play("front")
	anim.speed_scale = 1.0  

func _physics_process(delta):
	var inventory = get_tree().get_first_node_in_group("inventory_ui")
	if inventory and inventory.is_inventory_open():
		velocity = Vector2.ZERO
		return  # sai da função e o personagem não se move

	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	# Movimento
	velocity = input_vector * speed
	move_and_slide()
	
	if input_vector.y > 0:  
		anim.play("front") 
		walk_cycle += delta * 18.0
		anim.position.y = base_y + sin(walk_cycle) * 1.5 
		current_dir = "front"
	elif input_vector.y < 0:  
		anim.play("back")
		walk_cycle += delta * 18.0
		anim.position.y = base_y + sin(walk_cycle) * 1.5 
		current_dir = "back"
	elif input_vector.x > 0:  
		anim.play("right")
		walk_cycle += delta * 18.0
		anim.position.y = base_y + sin(walk_cycle) * 1.5
		current_dir = "right"
	elif input_vector.x < 0:  
		anim.play("left")
		walk_cycle += delta * 18.0
		anim.position.y = base_y + sin(walk_cycle) * 1.5
		current_dir = "left"
	else:
		# parado -> piscar apenas se estiver olhando para frente
		blink_timer += delta
		if current_dir == "front" and blink_timer >= blink_interval:
			anim.play("standing")  # só pisca se estiver de frente
			if anim.frame == anim.sprite_frames.get_frame_count("standing") - 1:
				anim.stop()
				anim.frame = 0
				blink_timer = 0.0
		else:
			anim.stop()
			anim.frame = 0
			anim.position.y = base_y
			walk_cycle = 0.0




 
