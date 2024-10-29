extends CharacterBody2D

@onready var dude = "player"
@onready var animations = $IdleAnimation

const SPEED = 7500.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED * delta
	move_and_slide()
	run_animation()
	
func run_animation():
	animations.play("Idle")
