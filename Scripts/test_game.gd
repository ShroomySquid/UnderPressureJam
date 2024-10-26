extends Node2D

@onready var human1 = $Human
@onready var human2 = $Human2
@onready var human_array = [human1, human2]
@onready var human_index = 1
@onready var cur_human = human_array[human_index]

@onready var walk_grid = $WalkingRange
@onready var walk_path = $WalkingPath
@onready var floor_grid = $Floor
@onready var walkable_cell = Vector2i(0, 0)
@onready var end_path = $WalkingEnd

@onready var cardinals = {"left": Vector2i(-1, 0), "right": Vector2i(1, 0), "up": Vector2i(0, -1), "down": Vector2i(0, 1)}

var mouse_pos
var last_mouse_pos
var mouse_atlas
var dis_to_move 

func _ready():
	#var space_state = get_world_2d().direct_space_state
	#var sight_check = space_state.intersect_ray()
	var starting_pos = Vector2i(4, 4)
	for human in human_array:
		human.set_new_pos(starting_pos)
		starting_pos.x += 5
		starting_pos.y += 5
	add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, true)

func _process(_delta):
	last_mouse_pos = mouse_pos
	mouse_pos = walk_grid.local_to_map(get_viewport().get_mouse_position())
	mouse_atlas = walk_grid.get_cell_atlas_coords(mouse_pos)
	if mouse_atlas == walkable_cell && last_mouse_pos != mouse_pos:
		if last_mouse_pos:
			end_path.set_cell(last_mouse_pos, 0, Vector2i(-1, -1), 0)
		end_path.set_cell(mouse_pos, 0, walkable_cell, 0)
		clear_path(cur_human.cur_position, cur_human.max_mouv)
		calculate_path(cur_human.cur_position, mouse_pos)
	if last_mouse_pos && mouse_atlas != walkable_cell:
		for human in human_array:
			clear_path(human.cur_position, human.max_mouv)
		end_path.set_cell(last_mouse_pos, 0, Vector2i(-1, -1), 0)
	if Input.is_action_just_pressed("LeftClick") && mouse_atlas == walkable_cell:
		add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, false)
		cur_human.set_new_pos(mouse_pos)
		cur_human.cur_mouv -= dis_to_move
		add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, true)
	if Input.is_action_just_pressed("swap") && human_array.size() > 1:
		human_index += 1
		add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, false)
		if (human_index >= human_array.size()):
			human_index = 0
		cur_human = human_array[human_index]
		add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, true)

func _on_end_turn_pressed():
	for human in human_array:
		human.cur_mouv = human.max_mouv
	add_walking_tile(walk_grid.local_to_map(cur_human.position), cur_human.cur_mouv, true)

func clear_path(coord, walk_range):
	var i = -walk_range
	var a = 0
	var end_row = 0
	while (i <= walk_range):
		end_row = walk_range - abs(i)
		a = -end_row
		while (a <= end_row):
			var cur_cell = Vector2i(coord.x + i, coord.y + a)
			walk_path.set_cell(cur_cell, 0, Vector2i(-1, -1), 0)
			a += 1
		i += 1

func calculate_path(initial_pos, last_pos):
	var to_move = last_pos - initial_pos
	var tile_to_set = initial_pos
	var dir;
	var tile;
	var last_dir = Vector2i(-1, -1)
	var before_last_dir = Vector2i(-1, -1)
	var last_tile = Vector2i(-1, -1)
	dis_to_move = (abs(to_move.x) + abs(to_move.y))
	while (to_move != Vector2i(0, 0)):
		dir = get_direction(to_move)
		tile = get_tile_path(dir)
		walk_path.set_cell(tile_to_set, 0, tile, 0)
		if (last_dir != Vector2i(-1, -1) && before_last_dir != Vector2i(-1, -1)):
			update_last_tile(before_last_dir, last_dir, last_tile)
		to_move -= dir
		if (last_dir != Vector2i(-1, -1)):
			before_last_dir = last_dir
		last_dir = dir
		last_tile = tile_to_set
		tile_to_set += dir
	dir = -dir
	tile = get_tile_path(dir)
	walk_path.set_cell(tile_to_set, 0, tile, 0)
	if (last_tile != initial_pos):
		update_last_tile(before_last_dir, last_dir, last_tile)

func get_direction(to_move):
	var dir_is_x = abs(to_move.x) > abs(to_move.y)
	var dir_left = to_move.x < 0
	var dir_up = to_move.y < 0
	if dir_is_x && dir_left:
		return (cardinals.left)
	elif dir_is_x && !dir_left:
		return (cardinals.right)
	elif !dir_is_x && dir_up:
		return (cardinals.up)
	elif !dir_is_x && !dir_up:
		return (cardinals.down)
	return (null)

func get_tile_path(coord):
	if coord == cardinals.right:
		return (Vector2i(2, 2))
	elif coord == cardinals.left:
		return (Vector2i(4, 2))
	elif coord == cardinals.up:
		return (Vector2i(1, 2))
	elif coord == cardinals.down:
		return (Vector2i(3, 2))
	return (null)

func update_last_tile(last_dir, dir, tile):
	if abs(last_dir) == abs(dir) && (last_dir == cardinals.up || last_dir == cardinals.down):
		walk_path.set_cell(tile, 0, Vector2i(0, 3), 0)
	elif abs(last_dir) == abs(dir) && (last_dir == cardinals.right || last_dir == cardinals.left):
		walk_path.set_cell(tile, 0, Vector2i(1, 3), 0)
	elif (last_dir == cardinals.down && dir == cardinals.right) || (last_dir == cardinals.left && dir == cardinals.up):
		walk_path.set_cell(tile, 0, Vector2i(2, 3), 0)
	elif (last_dir == cardinals.up && dir == cardinals.right) || (last_dir == cardinals.left && dir == cardinals.down):
		walk_path.set_cell(tile, 0, Vector2i(3, 3), 0)
	elif (last_dir == cardinals.up && dir == cardinals.left) || (last_dir == cardinals.right && dir == cardinals.down):
		walk_path.set_cell(tile, 0, Vector2i(4, 3), 0)
	elif (last_dir == cardinals.down && dir == cardinals.left) || (last_dir == cardinals.right && dir == cardinals.up):
		walk_path.set_cell(tile, 0, Vector2i(5, 3), 0)

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
