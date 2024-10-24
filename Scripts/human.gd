extends Node2D

@onready var max_mouv := 5
@onready var cur_mouv := 5

func _ready():
	pass # Replace with function body. 

func _process(_delta):
	pass
	
func set_new_pos(coord):
	global_position = Vector2i(coord.x * 32 + 16, coord.y * 32 + 16)
