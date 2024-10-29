extends Node2D

@onready var zombie_point_container = $ZombieContainer

signal player_death

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_player_dead_player():
	player_death.emit()
