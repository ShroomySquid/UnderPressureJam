extends Node2D

@onready var human1 = $Human
@onready var human2 = $Human2
@onready var human_array = [human1, human2]
@onready var human_index = 1
@onready var selected_human = human_array[human_index]

@onready var walk_grid = $WalkingRange
@onready var walk_path = $WalkingPath
@onready var floor_grid = $Floor
@onready var walkable_cell = Vector2i(0, 0)
@onready var end_path = $WalkingEnd

var mouse_pos
var last_mouse_pos

func _ready():
	var i := 0
	var starting_pos = Vector2i(4, 4)
	while (i < human_array.size()):
		human_array[i].set_new_pos(starting_pos)
		starting_pos.x += 5
		starting_pos.y += 5
		i += 1
	add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)

func _process(_delta):
	mouse_pos = walk_grid.local_to_map(get_viewport().get_mouse_position())
	if walk_grid.get_cell_atlas_coords(mouse_pos) == walkable_cell && last_mouse_pos != mouse_pos:
		if last_mouse_pos:
			end_path.set_cell(last_mouse_pos, 0, Vector2i(-1, -1), 0)
		end_path.set_cell(mouse_pos, 0, walkable_cell, 0)
		last_mouse_pos = mouse_pos
		calculate_path(selected_human.cur_position, mouse_pos)
	elif last_mouse_pos && last_mouse_pos != mouse_pos:
		end_path.set_cell(last_mouse_pos, 0, Vector2i(-1, -1), 0)
	if Input.is_action_just_pressed("LeftClick") && walk_grid.get_cell_atlas_coords(mouse_pos) == walkable_cell:
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, false)
		selected_human.set_new_pos(mouse_pos)
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)
	if Input.is_action_just_pressed("swap") && human_array.size() > 1:
		human_index += 1
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, false)
		if (human_index >= human_array.size()):
			human_index = 0
		selected_human = human_array[human_index]
		add_walking_tile(walk_grid.local_to_map(selected_human.position), selected_human.cur_mouv, true)

func _on_end_turn_pressed():
	human1.current_mouvement = human1.max_mouvement
	human2.current_mouvement = human2.max_mouvement

func calculate_path(initial_pos, last_pos):
	var tile_to_set = initial_pos
	var to_move = initial_pos - last_pos
	var dir_is_x = abs(to_move.x) > abs(to_move.y)
	var dir_left = to_move.x < 0
	var dir_up = to_move.y < 0
	while (to_move != Vector2i(0, 0)):
		if dir_is_x:
			if dir_left:
				walk_path.set_cell(tile_to_set, 0, Vector2i(4, 2), 0)
			pass
		to_move = tile_to_set - last_pos
		dir_is_x = abs(to_move.x) > abs(to_move.y)
			
	print(to_move)

func add_walking_tile(coord, walk_range, add):
	var i = -walk_range
	var a = 0
	var end_row = 0
	while (i <= walk_range):
		end_row = walk_range - abs(i)
		a = -end_row
		while (a <= end_row):
			var cur_cell = Vector2i(coord.x + i, coord.y + a)
			if add && floor_grid.get_cell_atlas_coords(cur_cell) == Vector2i(1, 0) && (i | a):
				walk_grid.set_cell(cur_cell, 0, walkable_cell, 0)
			else:
				walk_grid.set_cell(cur_cell, 0, Vector2i(-1, -1), 0)
			a += 1
		i += 1
