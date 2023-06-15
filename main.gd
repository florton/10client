extends Node2D

@onready var Menu = find_child("Menu")
@onready var Lobby = find_child("Lobby")
@onready var Game = find_child("Game")
@onready var QuickPlay = find_child("QuickPlay")

func showScene(group):
	for s in get_children():
		s.visible = s.is_in_group(group) || s.is_in_group("ignore")

# Called when the node enters the scene tree for the first time.
func _ready():
	showScene("menu")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_lobby_pressed():
	showScene("lobby")

func _on_lobby_start_match(userId, matchId):
	showScene("game")
	Game.startGame(userId, matchId)

func _on_quickplay_pressed():
	showScene("quickplay")
	Lobby.quickPlay()
