extends CharacterBody2D

@onready var ray_container = $RayContainer
@onready var ray_nbr = 10
@onready var ray_range = 200
@onready var ray_separation = 5
@onready var cardinals = {"left": Vector2i(-1, 0), "right": Vector2i(1, 0), "up": Vector2i(0, -1), "down": Vector2i(0, 1)}

func _ready():
	_generate_rays()
	#await get_tree().create_timer(10.0).timeout
	#_remove_rays()
	#pass

func _process(_delta):
	pass

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
	new_ray.target_position.y = 0 + (i * 10)
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
