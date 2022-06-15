extends Node

var token : String = ""

var network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 31403

func connect_to_server():
	print("Attempting to connect to game server "+ip)
	network.create_client(ip, port)
	get_tree().set_network_peer(network)

	network.connect("connection_failed", self, "_on_connection_failed")
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("server_disconnected", self, "_on_server_disconnected")

func _on_connection_failed():
	print("Failed to connect")
	network.close_connection()
	var _err = get_tree().change_scene("res://scenes/menus/LoginMenu.tscn")

func _on_connection_succeeded():
	print("Successfully connected")

func _on_server_disconnected():
	print("Server Disconnected")
	
	get_node("TimerLatency").queue_free()
	
	network.close_connection()
	var _err = get_tree().change_scene("res://scenes/menus/ConnectMenu.tscn")
	Game = null

# Server Authentication
remote func fetchToken():
	rpc_id(1, "returnToken", token)
remote func returnTokenVerification(result):
	match result:
		true:
			print("Token: Success")
			
			rpc_id(1, "fetchServerTime", OS.get_system_time_msecs())
			
			# Start the latency timer
			var sync_timer = Timer.new()
			sync_timer.name = "TimerLatency"
			sync_timer.wait_time = 0.5
			sync_timer.autostart = true
			sync_timer.connect("timeout", self, "determineLatency")
			self.add_child(sync_timer)
			
			# Join the game
			var _err = get_tree().change_scene("res://scenes/game/Game.tscn")
		false:
			print("Token: Failed to verify.")

# Error handling
remote func getError(err):
	print("SERVER ERR: "+err)

#######################################################################################
###               A  C  T  U  A  L                N  E  T  C  O  D  E               ###
#######################################################################################
onready var Game = null

func loadedGame():
	rpc_id(1, "loadedGame")

# Update data
remote func updateGameState(s_game_state):
	ServerData.updateGameState(s_game_state)
remote func updateCombatQueue(s_combat_queue):
	ServerData.updateCombatQueue(s_combat_queue)

# Client input
func requestPlayCard(uuid : int, lane : int):
	rpc_id(1, "requestPlayCard", uuid, lane)
func requestMulligan(uuid_list : Array):
	rpc_id(1, "requestMulligan", uuid_list)
func requestPass():
	rpc_id(1, "requestPass")
func requestLaneActivate(active_list : Array):
	rpc_id(1, "requestLaneActivate", active_list)
func requestPosition(uuid : int, new_position : Vector2):
	rpc_id(1, "requestPosition", uuid, new_position)
#######################################################################################
# # #      S  E  R  V  E  R      S  Y  N  C  H  R  O  N  I  Z  A  T  I  O  N      # # #
#######################################################################################
var client_clock = 0 
var decimal_collector: float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

remote func returnServerTime(server_time, client_time):
	latency = (OS.get_system_time_msecs() - client_time)/2
	client_clock = server_time + latency
func determineLatency():
	rpc_id(1, "determineLatency", OS.get_system_time_msecs())

remote func returnLatency(client_time):
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1, -1, -1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		
		delta_latency = (total_latency/latency_array.size()) - latency
		latency = total_latency/latency_array.size()
		print("New latency: ", latency)
		print("Delta latency: ", delta_latency)
		latency_array.clear()

# Process
func _process(delta):
	# Server time synchronization
	var delta_ms = delta*1000
	
	client_clock += int(delta_ms) + delta_latency
	delta_latency = 0
	decimal_collector += (delta_ms) - int(delta_ms)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00
