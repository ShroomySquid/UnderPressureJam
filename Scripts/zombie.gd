extends CharacterBody2D

@onready var ray_container = $RayContainer
@onready var ray_nbr = 20
@onready var ray_range = 200
@onready var ray_separation = 5
@onready var cardinals = {"left": Vector2i(-1, 0), "right": Vector2i(1, 0), "up": Vector2i(0, -1), "down": Vector2i(0, 1)}
@onready var nav_agent = $NavigationAgent2D
@onready var type = "zombie"
@onready var default_route = [Vector2i(0, 0), Vector2i(0, 0)]
@onready var going_back = true

var SPEED = 2000.0
var direction

func _ready():
	_set_route()
	_generate_rays()

func _process(delta):
	var collide
	for rays in ray_container.get_children():
		collide = rays.get_collider()
		if collide != null && collide is CharacterBody2D && collide.type == "player":
			nav_agent.target_position = collide.global_position
	direction = to_local(nav_agent.get_next_path_position()).normalized()
	#print(direction)
	#print(nav_agent.target_position)
	#print(position)
	velocity = direction * SPEED * delta
	move_and_slide()

func _generate_rays():
	var new_ray = RayCast2D.new()
	set_ray(new_ray, 0)
	ray_container.add_child(new_ray)
	for i in ray_nbr:
		new_ray = RayCast2D.new()
		set_ray(new_ray, i)
		ray_container.add_child(new_ray)
		new_ray = RayCast2D.new()
		set_ray(new_ray, -i)
		ray_container.add_child(new_ray)

func set_ray(new_ray, i):
	new_ray.target_position.y = 0 + (i * ray_separation)
	if i == 0:
		new_ray.target_position.x = ray_range
	else:
		new_ray.target_position.x = sqrt(pow(ray_range, 2) - pow(new_ray.target_position.y, 2))
	new_ray.set_collision_mask_value(2, true)
	new_ray.set_collision_mask_value(3, true)

func _remove_rays():
	while (ray_container.get_child_count() > 0):
		ray_container.get_child(0).queue_free()
		ray_container.remove_child(ray_container.get_child(0))

func _set_route():
	if going_back: 
		nav_agent.target_position = to_local(default_route[0])
	else:
		nav_agent.target_position = to_local(default_route[1])
	going_back = !going_back
	print(nav_agent.target_position)

func _on_area_2d_area_entered(area):
	print(area)

func _on_area_2d_area_exited(area):
	print(area)
