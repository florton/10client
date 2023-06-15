extends Node2D

@onready var Menu = find_child("Menu")
@onready var Lobby = find_child("Lobby")
@onready var Game = find_child("Game")
@onready var QuickPlay = find_child("QuickPlay")

var scenes = []

func showScene(scene):
	for s in scenes:
		s.visible = s == scene

# Called when the node enters the scene tree for the first time.
func _ready():
	scenes = [Menu, Lobby, Game, QuickPlay]
	showScene(Menu)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_lobby_pressed():
	showScene(Lobby)

func _on_lobby_start_match(userId, matchId):
	print('here')
	showScene(Game)
	Game.startGame(userId, matchId)

func _on_quickplay_pressed():
	showScene(QuickPlay)
	Lobby.quickPlay()
