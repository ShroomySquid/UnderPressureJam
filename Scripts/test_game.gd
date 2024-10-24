extends Node2D

@onready var human1 = $Human
@onready var human2 = $Human2
@onready var human_array = [human1, human2]
@onready var human_index = 1
@onready var selected_human = human_array[human_index]

@onready var walk_grid = $WalkingRange
@onready var floor_grid = $Floor
@onready var walkable_cell = Vector2i(0, 0)

func _ready():	
	add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)

func _process(_delta):
	if Input.is_action_just_pressed("LeftClick"):
		var mouse_pos = walk_grid.local_to_map(get_viewport().get_mouse_position())
		if walk_grid.get_cell_atlas_coords(mouse_pos) == walkable_cell:
			add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, false)
			selected_human.set_new_pos(mouse_pos)
			add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)
	if Input.is_action_just_pressed("swap"):
		if (human_array.size() <= 1):
			return
		human_index += 1
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, false)
		if (human_index >= human_array.size()):
			human_index = 0
		selected_human = human_array[human_index]
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)

func _on_end_turn_pressed():
	human1.current_mouvement = human1.max_mouvement
	human2.current_mouvement = human2.max_mouvement

func remove_walking_tile():
	pass

func add_walking_tile(coord, walk_range, add):
	var i = -walk_range
	while (i <= walk_range):
		var end_row = walk_range - abs(i)
		var a = -end_row
		while (a <= end_row):
			var cur_cell = Vector2i(coord.x + i, coord.y + a)
			if add && floor_grid.get_cell_atlas_coords(cur_cell) == Vector2i(1, 0) && (i | a):
				walk_grid.set_cell(cur_cell, 0, walkable_cell, 0)
			else:
				walk_grid.set_cell(cur_cell, 0, Vector2i(-1, -1), 0)
			a += 1
		i += 1
