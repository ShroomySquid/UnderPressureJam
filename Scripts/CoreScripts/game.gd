extends Node2D

@onready var is_paused := false
@onready var menu = $CanvasLayer/MenuContainer
@onready var settings = $CanvasLayer/Settings
@onready var zombie_container = $ZombieContainer
@onready var test_map = $Test_map
@onready var zombie = preload("res://Scenes/PhysicsScenes/zombie.tscn")

func _ready():
	randomize()
	create_some_zombies()
	menu.hide()
	settings.hide()

func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		pause_trigger()

func pause_trigger():
	if (is_paused):
		if not settings.visible:
			menu.visible = !menu.visible
		else:
			settings.visible = false
		is_paused = false
		Engine.time_scale = 1
	else:
		menu.visible = !menu.visible
		Engine.time_scale = 0
		is_paused = true

func _on_pause_btn_pressed():
		pause_trigger()

func _on_resume_btn_pressed():
		pause_trigger()

func _on_setting_btn_pressed():
	menu.visible = !menu.visible
	settings.visible = !settings.visible

func _on_settings_exit_settings():
	menu.visible = !menu.visible
	settings.visible = !settings.visible

func _on_quit_btn_pressed():
	get_tree().quit()

func _on_retry_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/CoreScenes/game.tscn")
	
func create_some_zombies():
	var i = 0
	var new_zomb
	while (i < 2):
		new_zomb = zombie.instantiate()
		#print(test_map.zombie_point_container.get_child(randi() % 20).global_position)
		#print(new_zomb.default_route[0])
		zombie_container.add_child(new_zomb)
		new_zomb.default_route[0] = to_local(test_map.zombie_point_container.get_child(randi() % 20).global_position)
		new_zomb.default_route[1] = to_local(test_map.zombie_point_container.get_child(randi() % 20).global_position)
		new_zomb.position = new_zomb.default_route[0]
		print(new_zomb.default_route[0])
		print(new_zomb.default_route[1])
		i += 1
