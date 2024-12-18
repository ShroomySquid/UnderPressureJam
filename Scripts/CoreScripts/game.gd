extends Node2D

@onready var is_paused := false
@onready var menu = $CanvasLayer/MenuContainer
@onready var setting_btn = $CanvasLayer/MenuContainer/SettingBtn
@onready var resume_btn = $CanvasLayer/MenuContainer/ResumeBtn
@onready var end_msg = $CanvasLayer/MenuContainer/EndMsg
@onready var settings = $CanvasLayer/Settings
@onready var zombie_container = $ZombieContainer
@onready var map = $Level1
@onready var zombie = preload("res://Scenes/PhysicsScenes/zombie.tscn")
@onready var camera = $Camera2D
@onready var dead_zombies = 0
@onready var zombie_nbr = 2

func _ready():
	randomize()
	create_some_zombies()
	menu.hide()
	settings.hide()

func _process(_delta):
	if Input.is_action_just_pressed("esc"):
		pause_trigger()
	if Input.is_action_just_pressed("scroll_up") && camera.zoom.x < 3:
		print(camera.zoom)
		camera.zoom *= 1.1
	if Input.is_action_just_pressed("scroll_down") && camera.zoom.x > 0.5:
		print(camera.zoom)
		camera.zoom *= 0.9

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
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/CoreScenes/game.tscn")
	
func create_some_zombies():
	var i = 0
	var new_zomb
	var begin
	var end
	while (i < zombie_nbr):
		new_zomb = zombie.instantiate()
		begin = map.zombie_point_container.get_child(randi() % 2).global_position
		end = map.zombie_point_container.get_child(randi() % 2).global_position
		while (end == begin):
			end = map.zombie_point_container.get_child(randi() % 2).global_position
		new_zomb.position = begin
		zombie_container.add_child(new_zomb)
		new_zomb.default_route[0] = begin
		new_zomb.default_route[1] = end
		new_zomb.set_route()
		new_zomb.zombie_death.connect(count_dead_zombies)
		i += 1

func count_dead_zombies():
	dead_zombies += 1
	if dead_zombies >= zombie_nbr:
		win()

func win():
	end_msg.text = "Victory!"
	end_game()

	
func end_game():
	Engine.time_scale = 0
	end_msg.show()
	resume_btn.hide()
	setting_btn.hide()
	menu.show()

func _on_level_1_player_death():
	end_msg.text = "Defeat..."
	end_game()
