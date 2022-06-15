extends Control

func _ready():
	var deck = {
		"author": "Spooticus",
		"title": "Base Deck",
		"card": {
			4: [
				"nrt_003",
				"nrt_004",
				"nrt_005",
				"nrt_006",
				"nrt_007",
				"nrt_008"
			],
			8: [
				"nrt_001",
				"nrt_002"
			]
		}
	}
	OS.set_clipboard(encodeDeck(deck))

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		$SceneTransition.transition_to("res://scenes/menus/MainMenu.tscn")

func encodeDeck(input : Dictionary):
	return Marshalls.variant_to_base64(to_json(input), true)
