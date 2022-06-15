extends Control

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$SceneTransition.transition_to("res://scenes/menus/MainMenu.tscn")

func _on_Button_pressed():
	Gateway.requestValidate(true)
