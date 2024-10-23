extends Control

@onready var is_settings_on := false

func _ready():
	$Settings.hide()
	$Credits.hide()

func _process(_delta):
	pass

func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://Scenes/CoreScenes/game.tscn")

func _on_settings_btn_pressed():
	$MenuContainer.hide()
	$Settings.show()

func _on_settings_exit_settings():
	$MenuContainer.show()
	$Settings.hide()

func _on_credits_btn_pressed():
	$MenuContainer.hide()
	$Credits.show()

func _on_credits_back_to_menu():
	$MenuContainer.show()
	$Credits.hide()
