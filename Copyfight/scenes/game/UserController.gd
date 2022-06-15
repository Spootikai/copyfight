extends Node2D

onready var Hand = $HandController
onready var Game = self.get_parent()

func _setup(username : String):
	self.name = username
