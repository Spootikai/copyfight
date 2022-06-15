extends Node2D

onready var local_user = Gateway.username.to_lower()

onready var Game = get_node("/root/Game")
onready var User = get_parent()

onready var card_scale = Vector2(0.3, 0.5)
onready var card_dimension = Vector2(1000, 1400)

onready var mulligan_list = []

func _process(_delta):
	validateHand()
	
	var vp = get_viewport()
	
	if ServerData.game_state.phase == "M":
		var card_size = card_dimension.x * card_scale.x
		
		if mulligan_list.empty():
			for card in get_children():
				mulligan_list.append({
					"mulligan": false,
					"uuid": int(card.name)
				})
		if User.name == local_user:
			if Input.is_action_just_pressed("click"):
				for card in get_children():
					if card.is_hovered:
						toggleMulligan(int(card.name))
			
		for index in mulligan_list.size():
			var card = self.find_node(str(mulligan_list[index].uuid), true, false)
			if is_instance_valid(card):
				card.get_node("MulliganLabel").visible = mulligan_list[index].mulligan
		
		for card_index in get_child_count():
			var card = get_child(card_index)
			var start = (vp.size.x - (get_child_count() * card_size)) / 2
			if is_instance_valid(card):
				card.scale = Vector2(card_scale.x, card_scale.x)
				if User.name == local_user:
					card.hand_position = Vector2(start + (card_size * card_index), vp.size.y / 2) + Vector2(card_size * 0.5, 0)
				else:
					card.hand_position = Vector2(start + (card_size * card_index), 0) + Vector2(card_size * 0.5, 100)

	else:
		# Animate the cards in hand n shit
		var hand_pointer = 1
		# Reduce the working count of cards if one is being selected
		var effective_count = get_child_count()
		if is_instance_valid(Game.card_selected) and Game.card_selected.get_parent().name == self.name:
			effective_count = clamp(effective_count - 1, 1, effective_count)

		for child_index in get_child_count():
			var card = get_child(child_index)

			var card_size = card_dimension.x * card_scale.x
			var region_max =  vp.size.x / 2
			var region = clamp(card_size * effective_count, card_size, region_max) # Size of the region that cards can take up in hand

			# Locally owned or remote hand
			if User.name == local_user:
				# Position cards
				if Game.card_selected == card:
					# Make "selected" cards follow the mouse
					card.hand_position = get_global_mouse_position()
				else:
					# Position cards in the hand
					var start = Vector2((vp.size.x / 2) - (region / 2), 0)
					var xx = hand_pointer * (region / effective_count) - (card_dimension.x * card_scale.x * 0.5)

					card.hand_position = start + Vector2(xx, vp.size.y)
					hand_pointer += 1
				
					# Raise the entire hand when the player hovers over a card and isnt selecting a card
					var rise_amount = vp.size.y * 0.0625
					if Game.card_hovered != null and Game.card_selected == null:
						card.hand_position = Vector2(card.hand_position.x, vp.size.y - rise_amount)
				
				# Increase the scale and z_index of the hovered card to increase visibility
				if Game.card_hovered == card:
					card.z_index = 100
					card.scale = Vector2(card_scale.y, card_scale.y)
					
					if Game.card_selected != card:
						# Raise hovered cards so they appear against the bottom of the screen
						card.hand_position = Vector2(card.hand_position.x, vp.size.y - ((card_dimension.y / 2) * card.scale.y))
				else:
					card.z_index = -child_index
					card.scale = Vector2(card_scale.x, card_scale.x)
			else:
				# Move enemy hand slightly upwards to increase visibility
				var hide_amount = vp.size.y * 0.075
				# Position enemy cards in hand stationarily
				var start = Vector2((vp.size.x / 2) - (region / 2), 0)
				var xx = (hand_pointer * (region / get_child_count())) - (card_dimension.x * card_scale.x * 0.5)
				
				card.hand_position = start + Vector2(xx, -hide_amount)
				hand_pointer += 1
				
				# Keep the same scale/z_index for all enemy cards
				card.z_index = child_index
				card.scale = Vector2(card_scale.x, card_scale.x)

func toggleMulligan(uuid : int):
	for index in mulligan_list.size():
		if mulligan_list[index].uuid == uuid:
			mulligan_list[index].mulligan = !mulligan_list[index].mulligan

func validateHand():
	# Validate the hand if it exists, if not clear it
	if ServerData.game_state.hand.has(User.name):
		# Check every card in this user's hand
		for index in ServerData.game_state.hand[User.name].size():
			var uuid = ServerData.game_state.hand[User.name][index].unique
			var card = findCard(uuid)
			
			# If the card hasnt been instanced, instance it
			if card == null:
				createCard(uuid)
		# Process all children
		for child_index in get_child_count():
			var child = get_child(child_index)
			var uuid = Toolbox.index_from_uuid(int(child.name))
			if uuid == null:
				# Cull excess non-matching children
				child.queue_free()
	else:
		for child in get_children():
			child.queue_free()

func findCard(uuid: int):
	for card in get_children():
		if int(card.name) == uuid:
			return card
	return null

const card_instance = preload("res://scenes/game/CardInstance.tscn")
func createCard(uuid):
	var card_index = Toolbox.index_from_uuid(uuid)
	var new_card = card_instance.instance()
	self.add_child(new_card)
	
	new_card.name = str(uuid)
	
	# Reveal all local cards and all revealed remote cards
	if User.name == local_user:
		new_card.get_node("Revealed").visible = true
	else:
		new_card.get_node("Revealed").visible = ServerData.game_state.hand[User.name][card_index].revealed
	
	# All revealed cards need to be formatted (THIS CAN BE MOVED TO CARD INSTANCE)
	if new_card.get_node("Revealed").visible:
		new_card.format_card(ServerData.game_state.hand[User.name][card_index].id)
