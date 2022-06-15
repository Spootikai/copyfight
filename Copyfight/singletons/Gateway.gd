extends Node

var user_data = {}
# Example user_data:
# "F": {"binchoo": {"S": 1, "D": "TheNateMan", "T": "2"}}
# F = friend
#   S: 0 = offline, 1 = online, 2 = in-game, 3 = away
#   D: Display name
#   T: 0 = unadded, 1 = friend request, 2 = friend
# L = card library
#   {}
# R = rating maybe?

var offline_mode = false

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()

var ip = "127.0.0.1"
var port = 31404
var certificate = load("res://resources/X509Certificate.crt")

var username : String
var password : String
var create : bool

func _process(_delta):
	if get_custom_multiplayer() == null:
		return
	if !custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()

func connect_to_server(_username, _password, _create):
	if !offline_mode:
		network = NetworkedMultiplayerENet.new()
		gateway_api = MultiplayerAPI.new()

		network.set_dtls_enabled(true)
		network.set_dtls_verify_enabled(false) # SET TO TRUE WHEN USING SIGNED CERTIFICATE
		network.set_dtls_certificate(certificate)

		username = _username
		password = _password
		create = _create
		
		network.create_client(ip, port)
		set_custom_multiplayer(gateway_api)
		custom_multiplayer.set_root_node(self)
		custom_multiplayer.set_network_peer(network)
		
		network.connect("server_disconnected", self, "_on_server_disconnected")
		network.connect("connection_failed", self, "_on_connection_failed")
		network.connect("connection_succeeded", self, "_on_connection_succeeded")
		
func _on_server_disconnected():
	print("Gateway disconnected")
	offline_mode = true
func _on_connection_failed():
	print("Failed to connect to gateway")
	offline_mode = true
	if get_tree().get_current_scene().name == "LoginMenu":
		get_node("/root/LoginMenu/StripNoise/VBoxContainer/Login").disabled = false
func _on_connection_succeeded():
	print("Successfully connected to gateway server")
	match create:
		true:
			requestCreateAccount()
		false:
			requestValidate(get_tree().get_current_scene().name == "ConnectMenu")

func requestValidate(token_true):
	rpc_id(1, "requestValidate", username, password.sha256_text(), token_true)
remote func returnValidate(result, token_true, token):
	print("Validation recieved: ", result)
	match result:
		true:
			if get_tree().get_current_scene().name == "LoginMenu":
				get_tree().get_current_scene().get_node("SceneTransition").transition_to("res://scenes/menus/MainMenu.tscn")
				
			if token_true:
				Server.token = token
				Server.connect_to_server()
		false:
			network.disconnect("connection_failed", self, "_on_connection_failed")
			network.disconnect("connection_succeeded", self, "_on_connection_succeeded")
			
			if get_tree().get_current_scene().name == "LoginMenu":
				get_node("/root/LoginMenu/StripNoise/VBoxContainer/Login").disabled = false

func requestCreateAccount():
	rpc_id(1, "requestCreateAccount", username, password.sha256_text())
remote func returnCreateAccount(message):
	get_node("/root/LoginMenu/StripNoise/VBoxContainer/Create").disabled = false
	match message:
		1:
			print("Couldn't create account, try again")
		2:
			print("Username already exists, please use a different name or log-in")
		3:
			get_node("/root/LoginMenu/StripNoise/VBoxContainer/Username").text = ""
			get_node("/root/LoginMenu/StripNoise/VBoxContainer/Password").text = ""

func setUser(target_user, state):
	rpc_id(1, "setUser", username, target_user, state)
func fetchUserData(_username):
	rpc_id(1, "fetchUserData", _username)
remote func returnUserData(s_user_data):
	user_data = s_user_data
