extends VBoxContainer

signal back_to_menu

func _ready():
	pass # Replace with function body.

func _process(_delta):
	pass

func _on_menu_btn_pressed():
	back_to_menu.emit()
