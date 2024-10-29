extends CharacterBody2D

@onready var zombie_sprite = $ZombieSprite
@onready var ray_container = $RayContainer
@onready var ray_nbr = 20
@onready var ray_range = 200
@onready var ray_separation = 40
@onready var cardinals = {"left": Vector2i(-1, 0), "right": Vector2i(1, 0), "up": Vector2i(0, -1), "down": Vector2i(0, 1)}
@onready var nav_agent = $NavigationAgent2D
@onready var dude = "zombie"
@onready var default_route = [Vector2i(0, 0), Vector2i(0, 0)]
@onready var going_back = true
@onready var is_chasing = false
@onready var player_in_range = false
@onready var health = 1
@onready var animation = $ZombieAnimation
@onready var is_attacking = false

var SPEED = 1800.0
var direction

signal zombie_death

func _ready():
	set_route()

func _process(delta):
	if (is_attacking):
		return
	animation.play("walk")
	var player
	var collide
	var remain = position - nav_agent.target_position
	if (abs(remain.x) + abs(remain.y) < 2 && !is_chasing):
		set_route()
	for rays in ray_container.get_children():
		collide = rays.get_collider()
		if collide != null && collide is CharacterBody2D && collide.dude == "player":
			player = collide
			is_chasing = true
			SPEED = 3500.0
			nav_agent.target_position = collide.global_position
	direction = to_local(nav_agent.get_next_path_position()).normalized()
	_remove_rays()
	_generate_rays(direction)
	if (abs(remain.x) < 32 && abs(remain.y) < 32 && is_chasing):
		is_attacking = true
		await get_tree().create_timer(1).timeout
		is_attacking = false
	velocity = direction * SPEED * delta
	move_and_slide()

func _generate_rays(dir):
	var y = 0.0
	var x = 0.0
	var y2 = 0.0
	var x2 = 0.0
	var new_ray = RayCast2D.new()
	_set_ray(new_ray, dir.x, dir.y)
	var i = 0.0
	while (i < ray_nbr):
		new_ray = RayCast2D.new()
		if dir.x >= 0.5:
			y = dir.y + (i / ray_separation)
			x = sqrt(1 - pow(y, 2))
			y2 = dir.y - (i / ray_separation)
			x2 = sqrt(1 - pow(y2, 2))
		elif dir.x <= -0.5:
			y = dir.y + (i / ray_separation)
			x = -sqrt(1 - pow(y, 2))
			y2 = dir.y - (i / ray_separation)
			x2 = -sqrt(1 - pow(y2, 2))
		elif dir.y >= 0.5:
			x = dir.x + (i / ray_separation)
			y = sqrt(1 - pow(x, 2))
			x2 = dir.x - (i / ray_separation)
			y2 = sqrt(1 - pow(x2, 2))
		elif dir.y <= -0.5:
			x = dir.x + (i / ray_separation)
			y = -sqrt(1 - pow(x, 2))
			x2 = dir.x - (i / ray_separation)
			y2 = -sqrt(1 - pow(x2, 2))
		_set_ray(new_ray, x, y)
		new_ray = RayCast2D.new()
		_set_ray(new_ray, x2, y2)
		i += 1.0


func _set_ray(new_ray, x, y):
	new_ray.target_position.y = y * ray_range
	new_ray.target_position.x = x * ray_range
	new_ray.set_collision_mask_value(1, false)
	new_ray.set_collision_mask_value(5, true)
	ray_container.add_child(new_ray)

func _remove_rays():
	while (ray_container.get_child_count() > 0):
		ray_container.get_child(0).queue_free()
		ray_container.remove_child(ray_container.get_child(0))

func set_route():
	SPEED = 1800.0
	if going_back: 
		nav_agent.target_position = default_route[0]
	else:
		nav_agent.target_position = default_route[1]
	going_back = !going_back

func _on_area_2d_body_exited(body):
	if dude in body && body.type == "player":
		is_chasing = false

func get_hit():
	health -= 1
	if health <= 0:
		queue_free()
		zombie_death.emit()
	for i in 5:
		zombie_sprite.hide()
		await get_tree().create_timer(0.1).timeout
		zombie_sprite.show()
		await get_tree().create_timer(0.1).timeout
