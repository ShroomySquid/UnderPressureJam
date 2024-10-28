extends CharacterBody2D

@onready var type = "player"

const SPEED = 10000.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED * delta
	move_and_slide()
