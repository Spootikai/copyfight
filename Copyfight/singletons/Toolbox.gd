extends Node

func card_from_uuid(uuid: int):
	for player in ServerData.hand.keys():
		for index in ServerData.hand[player].size():
			if uuid == ServerData.hand[player][index].unique:
				return ServerData.hand[player][index]
	return null

func index_from_uuid(uuid : int):
	for player in ServerData.game_state.hand.keys():
		for index in ServerData.game_state.hand[player].size():
			var card = ServerData.game_state.hand[player][index]
			if card.unique == uuid:
				return index
	return null

# Checks if the card UUID is local or not
func card_is_local(uuid : int):
	var local_user = Gateway.username.to_lower()
	if ServerData.game_state.hand.has(local_user):
		for index in ServerData.game_state.hand[local_user].size():
			if ServerData.game_state.hand[local_user][index].unique == uuid:
				return true
	return false

func player_is_local(username : String):
	var local_user = Gateway.username.to_lower()
	if username == local_user:
		return true
	return false
