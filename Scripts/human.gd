extends Node2D

@onready var max_mouv := 5
@onready var cur_mouv := 5
@onready var cur_position := Vector2i(1, 1)

func _ready():
	pass # Replace with function body. 

func _process(_delta):
	pass
	
func set_new_pos(coord):
	cur_position = coord
	global_position = Vector2i(coord.x * 32 + 16, coord.y * 32 + 16)
