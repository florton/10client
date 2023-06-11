extends Node2D

@onready var Menu = find_child("Menu")
@onready var Game = find_child("Game")

# Called when the node enters the scene tree for the first time.
func _ready():
	Menu.visible = true
	Game.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_pressed():
	Menu.visible = false
	Game.visible = true
	Game.startGame()
