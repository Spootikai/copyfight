extends Control

var mulligan = false

func _physics_process(_delta):
	var local_user = Gateway.username.to_lower()

	if !ServerData.game_state.empty():
		$PhaseLabel.text = ServerData.game_state.phase
		$TurnLabel.text = ServerData.game_state.turn.to_upper()
		
		
		var action_button = $TextureRect/ActionButton
		
		if ServerData.game_state.phase == "M":
			if !mulligan:
				action_button.text = "Okay"
				action_button.disabled = false
			else:
				action_button.text = "Wait"
				action_button.disabled = true
		else:
			if !ServerData.game_state.action.empty() and ServerData.game_state.action[0] == local_user:
				action_button.text = "Pass"
				action_button.disabled = false
			else:
				action_button.text = "Wait"
				action_button.disabled = true

		for player in ServerData.game_state.players:
			if player == local_user:
				$PlayerLocal/Label.text = str(ServerData.game_state.players[local_user].HP)
				$PlayerLocal/Resources.text = str(ServerData.game_state.players[local_user].resources)
			else:
				$PlayerRemote/Label.text = str(ServerData.game_state.players[player].HP)
				$PlayerRemote/Resources.text = str(ServerData.game_state.players[player].resources)

func _on_Game_actionButton():
	mulligan = true
