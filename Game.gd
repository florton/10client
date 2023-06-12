extends Node2D

@onready var Info = find_child("Info")
@onready var PlyrName = Info.find_child("PlyrName")
@onready var PlyrChoice = Info.find_child("PlyrChoice")
@onready var PlyrInfo = Info.find_child("PlyrInfo")
@onready var PlyrAttacking = Info.find_child("PlyrAttacking")
@onready var PlyrHp = Info.find_child("PlyrHp")
@onready var PlyrAtkIcon = Info.find_child("PlyrAtkIcon")
@onready var OpntChoice = Info.find_child("OpntChoice")
@onready var OpntInfo = Info.find_child("OpntInfo")
@onready var OpntName = Info.find_child("OpntName")
@onready var OpntAttacking = Info.find_child("OpntAttacking")
@onready var OpntHp = Info.find_child("OpntHp")
@onready var OpntAtkIcon = Info.find_child("OpntAtkIcon")
@onready var Turn = Info.find_child("Turn")

signal load_match
signal lock_in

var isPaused = true

var userId = null
var matchId = null
var opponentId = null

var lockedIn = false
var opponentLockedIn = false
var playerAttacking = false
var turnNumber = 0

var playerChoice
var playerHp
var opponentChoice
var opponentHp

var endturn = false

func loadMatch(id):
	if !isPaused:
		emit_signal("load_match", id)
		print("load match")
		await get_tree().create_timer(2).timeout
		loadMatch(id)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_net_code_load_match_response(matchData):
	if matchData && matchData.players:
		for player in matchData.players.values():
			if player.id != userId:
				opponentId = player.id
	var player = matchData.players[userId]
	var opponent = matchData.players[opponentId]
	playerHp = player.health
	opponentHp = opponent.health
	opponentLockedIn = opponent.choice
	playerAttacking = matchData.attacker == userId
	#End turn
	if turnNumber != matchData.turn:
		turnNumber = matchData.turn
		opponentChoice = opponent.prevChoice
		opponentLockedIn = false
		endturn = true
	elif endturn:
		opponentChoice = '?'
		playerChoice = '?'
		lockedIn = false
		endturn = false

func startGame(uId, mId):
	userId = uId
	matchId = mId
	playerHp = 5
	opponentHp = 5
	playerChoice = '?'
	opponentChoice = '?'
	isPaused = false
	loadMatch(matchId)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isPaused:
		PlyrHp.hp = playerHp
		OpntHp.hp = opponentHp
		PlyrChoice.text = playerChoice
		OpntChoice.text = opponentChoice
		PlyrInfo.text = '' if !lockedIn || endturn else 'Locked In'
		OpntInfo.text = '' if endturn else ('Choosing' if !opponentLockedIn else 'Locked In')
		PlyrAttacking.text = 'Attacking' if playerAttacking else 'Defending'
		PlyrAttacking.set("theme_override_colors/font_color", Color(1,0,0) if !playerAttacking else Color(0,1,0))
		OpntAttacking.text = 'Attacking' if !playerAttacking else 'Defending'
		OpntAttacking.set("theme_override_colors/font_color", Color(1,0,0) if playerAttacking else Color(0,1,0))
		PlyrAtkIcon.frame = 1 if playerAttacking else 0
		OpntAtkIcon.frame = 1 if !playerAttacking else 0
		Turn.text = 'Turn ' + str(turnNumber)
		
func _on_lock_in_pressed():
	if !lockedIn && matchId && userId && playerChoice:
		lockedIn = true
		emit_signal("lock_in", matchId, userId, playerChoice)

func _on_one_pressed():
	if !lockedIn:
		playerChoice = '1'

func _on_zero_pressed():
	if !lockedIn:
		playerChoice = '0'
