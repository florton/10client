extends Node2D

@onready var Menu = find_child("Menu")
@onready var Lobby = find_child("Lobby")
@onready var Game = find_child("Game")

# Called when the node enters the scene tree for the first time.
func _ready():
	Menu.visible = true
	Lobby.visible = false
	Game.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	Menu.visible = false
	Lobby.visible = true
#	Game.startGame()
