extends CharacterBody2D

@onready var dude = "player"
@onready var animations = $PlayerAnimation
@onready var fist_animations = $FistAnimation
@onready var health = 5
@onready var attack_ray = $AttackRay
@onready var is_attacking = false

const SPEED = 7500.0

signal dead_player

func _ready():
	fist_animations.hide()

func _physics_process(delta):
	if (is_attacking):
		return
	var direction = Input.get_vector("left", "right", "up", "down")
	if (direction):
		_set_ray_dir(direction)
	if Input.is_action_just_pressed("action"):
		is_attacking = true
		var collide = attack_ray.get_collider()
		if collide != null && collide is CharacterBody2D && collide.dude == "zombie":
			collide.get_hit()
		_attack_animation()
		await get_tree().create_timer(0.5).timeout
		fist_animations.hide()
		is_attacking = false
	velocity = direction * SPEED * delta
	move_and_slide()
	if direction:
		_run_animation()
	else:
		_idle_animation()

func _set_ray_dir(dir):
	attack_ray.target_position.x = dir.x * 30
	attack_ray.target_position.y = dir.y * 30

func _run_animation():
	animations.play("run")

func _idle_animation():
	animations.play("Idle")

func _attack_animation():
	fist_animations.show()
	animations.play("attack")
	fist_animations.play("attack")

func get_hit():
	health -= 1
	if health <= 0:
		dead_player.emit()
	for i in 5:
		animations.hide()
		await get_tree().create_timer(0.1).timeout
		animations.show()
		await get_tree().create_timer(0.1).timeout
