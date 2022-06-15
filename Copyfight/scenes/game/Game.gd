extends Node2D

var lane_count : int

var card_hovered
var card_selected

var entity_hovered
var entity_selected

var lane_hovered : int

signal actionButton

func _ready():
	Server.loadedGame()
	Server.Game = self
	
	$Blindfold.visible = true

var local_user = Gateway.username.to_lower()

func _on_ActionButton_pressed():
	emit_signal("actionButton")
	if !ServerData.game_state.empty():
		match ServerData.game_state.phase:
			"M":
				var uuid_list = $ContainerUser.get_node(local_user).get_node("HandController").mulligan_list
				Server.requestMulligan(uuid_list)
			"A":
				Server.requestLaneActivate($ControllerLane.active_lanes)
		Server.requestPass()

const particle_click = preload("res://scenes/particles/ParticleClick.tscn")
onready var game_loaded = false
func _process(_delta):
	if Input.is_action_just_pressed("click"):
		if entity_hovered == null and card_hovered == null:
			var new_particle_click = particle_click.instance()
			self.add_child(new_particle_click)
			new_particle_click.position = get_global_mouse_position()
	
	if !ServerData.game_state.empty():
		# Validate game state
		lane_count = ServerData.game_state.lanes.size()
		validateGameEntities()
		validateGamePlayers()
		
		# Remove the blindfold once loaded
		# Replace this with a threaded loading script
		$Blindfold.visible = (ServerData.game_state.phase == "X")
		
		# Pseudo press the Action Button 
		if Input.is_action_just_pressed("action_pass"):
			_on_ActionButton_pressed()
		
		# Selecting and hovering over cards
		if card_selected == null:
			# Detect which card is being hovered
			card_hovered = null
			
			var user_instance = $ContainerUser.find_node(local_user, true, false)
			var local_hand = user_instance.get_node("HandController").get_children()
			
			for card in local_hand:
				if card.is_hovered:
					card_hovered = card
					break

			# Detect if a hovered card is being selected
			if card_hovered != null:
				if Input.is_action_just_pressed("click"):
					card_selected = card_hovered
		else:
			# Detect if a selected card is being released
			if Input.is_action_just_released("click"):
				match ServerData.game_state.phase:
					"A": # Main phase
						var vp = get_viewport()
						var bbx_playarea = Rect2(Vector2(0, 0), Vector2(vp.size.x, vp.size.y*0.6))
						
						if bbx_playarea.has_point(get_global_mouse_position()):
							if is_instance_valid(card_selected):
								# Play the card 
								Server.requestPlayCard(int(card_selected.name), lane_hovered)

				# De-select the card
				card_selected = null

		# Selecting and hovering entities
		if entity_selected == null:
			# Detect which entity is being hovered
			entity_hovered = null

			var highest_z = null
			for entity in $ControllerEntity.get_children():
				if entity.controller == local_user:
					if entity.is_hovered:
						if highest_z != null:
							if entity.z_index > highest_z:
								entity_hovered = entity
								highest_z = entity.z_index
						else:
							entity_hovered = entity
							highest_z = entity.z_index
					
			# Detect if a hovered entity is being selected
			if entity_hovered != null:
				if Input.is_action_just_pressed("click"):
					entity_selected = entity_hovered
		else:
			# Detect if a selected card is being released
			if Input.is_action_just_released("click"):
				match ServerData.game_state.phase:
					"A": # Main phase
						Server.requestPosition(int(entity_selected.name), Vector2(lane_hovered, 0))
						pass

				# De-select the entity
				entity_selected = null

# Adds/removes any instances entities which should or should not be there
func validateGameEntities():
	# Create entities which exist on the server
	for uuid in ServerData.game_state.entities.keys():
		var entity_instanced = false
		
		for entity in $ControllerEntity.get_children():
			# Check and make sure that the child's UUID matches a UUID on the server
			if int(entity.name) == uuid:
				entity_instanced = true
				
		if !entity_instanced:
			createEntity(uuid)
	
	# Process all instanced entities
	for entity in $ControllerEntity.get_children():
		var entity_validated = false
		# Check every UUID on the server to validate this entity
		for uuid in ServerData.game_state.entities.keys():
			if int(entity.name) == uuid:
				entity_validated = true

		# Cull excess non-matching entities
		if !entity_validated:
			entity.queue_free()

func validateGamePlayers():
	for username in ServerData.game_state.players.keys(): 
		# Warning: will create any number of controllers if the usernames arent identical
		# Check if each player has a controller assigned to them
		var found_controller : bool = false
		for child in $ContainerUser.get_children():
			if child.name == username:
				found_controller = true
		if !found_controller:
			createUserController(username)

const entity_instance = preload("res://scenes/game/EntityInstance.tscn")
func createEntity(uuid):
	var new_entity = entity_instance.instance()
	$ControllerEntity.add_child(new_entity)
	
	# Apply the entity data
	var data = ServerData.game_state.entities[uuid]
	new_entity._setup(data["I"], data["C"], data["P"])
	new_entity.name = str(uuid)

const user_controller_instance = preload("res://scenes/game/UserController.tscn")
func createUserController(username : String):
	var new_user_controller = user_controller_instance.instance()
	new_user_controller._setup(username)
	$ContainerUser.add_child(new_user_controller)
