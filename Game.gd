extends Node2D

# Info
@onready var Info = find_child("Info")
@onready var PlyrName = find_child("PlyrName")
@onready var PlyrChoice = find_child("PlyrChoice")
@onready var PlyrTurn = find_child("PlyrTurn")
@onready var PlyrHp = find_child("PlyrHp")
@onready var PlyrAtkIcon = find_child("PlyrAtkIcon")
@onready var OpntChoice = find_child("OpntChoice")
@onready var OpntInfo = find_child("OpntInfo")
@onready var OpntName = find_child("OpntName")
@onready var OpntTurn = find_child("OpntTurn")
@onready var OpntHp = find_child("OpntHp")
@onready var OpntAtkIcon = find_child("OpntAtkIcon")

var paused = true
var playerHp
var opponentHp
var playerChoice
var opponentChoice
var opponentText

func startGame():
	playerHp = 5
	opponentHp = 5
	playerChoice = '?'
	opponentChoice = '?'
	opponentText = 'choosing'
	paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	PlyrName.text = "Davy Jones"
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (!paused):
		PlyrHp.hp = playerHp
		OpntHp.hp = opponentHp
		OpntInfo.text = opponentText
		PlyrChoice.text = playerChoice
		OpntChoice.text = opponentChoice
		
func _on_lock_in_pressed():
	opponentHp -= 1

func _on_one_pressed():
	playerChoice = '1'

func _on_zero_pressed():
	playerChoice = '0'
