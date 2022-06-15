extends Control

func _ready():
	if !GlobalSettings.data["save_login"].empty():
		$StripNoise/VBoxContainer/Username.text = GlobalSettings.data["save_login"]["user"]
		$StripNoise/VBoxContainer/Password.text = GlobalSettings.data["save_login"]["pass"]
		$StripNoise/VBoxContainer/HBoxContainer/Saveinfo.pressed = true
		
		#Auto connect
		#Gateway.connect_to_server(GlobalSettings.data["save_login"]["user"], GlobalSettings.data["save_login"]["pass"], false)
	else:
		$StripNoise/VBoxContainer/HBoxContainer/Saveinfo.pressed = false

func _on_Login_pressed():
	var username_input = $StripNoise/VBoxContainer/Username.text
	var password_input = $StripNoise/VBoxContainer/Password.text
	
	if username_input == "" or password_input == "":
		print("Please provide valid username and password.")
	else:
		$StripNoise/VBoxContainer/Login.disabled = true
		Gateway.connect_to_server(username_input, password_input, false)

func _on_Create_pressed():
	var username_input = $StripNoise/VBoxContainer/Username.text
	var password_input = $StripNoise/VBoxContainer/Password.text
	
	if username_input == "" or password_input == "":
		print("Please provide valid username and password.")
	elif password_input.length() < 7:
		print("Password must be at least 7 characters")
	else:
		$StripNoise/VBoxContainer/Create.disabled = true
		Gateway.connect_to_server(username_input, password_input, true)

func _on_Saveinfo_pressed():
	match $StripNoise/VBoxContainer/HBoxContainer/Saveinfo.pressed:
		true:
			GlobalSettings.data["save_login"] = {
				"user": $StripNoise/VBoxContainer/Username.text,
				"pass": $StripNoise/VBoxContainer/Password.text
			}
			GlobalSettings.save_data()
		false:
			GlobalSettings.data["save_login"] = {}
			GlobalSettings.save_data()

func _on_Offline_pressed():
	Gateway.offline_mode = true
	$SceneTransition.transition_to("res://scenes/menus/MainMenu.tscn")
