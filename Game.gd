extends Node2D

@onready var Info = find_child("Info")
@onready var PlyrName = Info.find_child("PlyrName")
@onready var PlyrChoice = Info.find_child("PlyrChoice")
@onready var PlyrInfo = Info.find_child("PlyrInfo")
@onready var PlyrPrev = Info.find_child("PlyrPrev")
@onready var PlyrPrevLabel = Info.find_child("PlyrPrevLabel")
@onready var PlyrAttacking = Info.find_child("PlyrAttacking")
@onready var PlyrHp = Info.find_child("PlyrHp")
@onready var PlyrAtkIcon = Info.find_child("PlyrAtkIcon")
@onready var OpntChoice = Info.find_child("OpntChoice")
@onready var OpntInfo = Info.find_child("OpntInfo")
@onready var OpntPrev = Info.find_child("OpntPrev")
@onready var OpntPrevLabel = Info.find_child("OpntPrevLabel")
@onready var OpntName = Info.find_child("OpntName")
@onready var OpntAttacking = Info.find_child("OpntAttacking")
@onready var OpntHp = Info.find_child("OpntHp")
@onready var OpntAtkIcon = Info.find_child("OpntAtkIcon")
@onready var Turn = Info.find_child("Turn")
@onready var Outcome = Info.find_child("Outcome")

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

var playerName
var opponentName
var playerChoice
var playerPrevChoice
var playerHp
var opponentChoice
var opponentPrevChoice
var opponentHp
var outcome

var endturn = false
var gameOver = false

func loadMatch(id):
	if !isPaused && !gameOver:
		emit_signal("load_match", id)
		print("load match")
		await get_tree().create_timer(2).timeout
		loadMatch(id)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func getOutcome(pAttacking, pChoice, oChoice):
	var defenderName = strFallback(opponentName if pAttacking else playerName)
	if pChoice == oChoice:
		return defenderName + '\n Blocked!'
	else:
		var damage = '1'
		if (pAttacking && pChoice == '1') || (!pAttacking && oChoice == '1'):
			damage = '2'
		return defenderName + '\n Took ' + damage + '\n Damage'
		
func checkDeaths():
	if playerHp <= 0:
		gameOver = true
		outcome = "You \n Lose!"
		return true
	if opponentHp <= 0:
		gameOver = true
		outcome = "You \n Win!"
		return true
	return false

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
	playerName = player.name
	opponentName = opponent.name
	#End turn
	if turnNumber != matchData.turn:
		turnNumber = matchData.turn
		outcome = getOutcome(playerAttacking, playerChoice, opponent.prevChoice)
		opponentChoice = opponent.prevChoice
		opponentLockedIn = false
		endturn = true
	elif endturn:
		if !checkDeaths():
			opponentChoice = '?'
			playerChoice = '?'
			playerPrevChoice = player.prevChoice
			opponentPrevChoice = opponent.prevChoice
		lockedIn = false
		endturn = false
	playerAttacking = matchData.attacker == userId

func startGame(uId, mId):
	userId = uId
	matchId = mId
	playerHp = 5
	opponentHp = 5
	playerChoice = '?'
	opponentChoice = '?'
	isPaused = false
	loadMatch(matchId)

func strFallback(val):
	return val if val else ''
	
func boolFallback(val):
	return true if val else false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !isPaused:
		PlyrName.text = strFallback(playerName)
		OpntName.text = strFallback(opponentName)
		PlyrHp.hp = playerHp
		OpntHp.hp = opponentHp
		PlyrChoice.text = playerChoice
		OpntChoice.text = opponentChoice
		PlyrInfo.text = '' if !lockedIn || endturn else 'Locked In'
		OpntInfo.text = '' if endturn else ('Choosing' if !opponentLockedIn else 'Locked In')
		PlyrPrevLabel.visible = boolFallback(playerPrevChoice)
		PlyrPrev.text = strFallback(playerPrevChoice)
		OpntPrevLabel.visible = boolFallback(opponentPrevChoice)
		OpntPrev.text = strFallback(opponentPrevChoice)
		PlyrAttacking.text = 'Attacking' if playerAttacking else 'Defending'
		PlyrAttacking.set("theme_override_colors/font_color", Color(1,0,0) if !playerAttacking else Color(0,1,0))
		OpntAttacking.text = 'Attacking' if !playerAttacking else 'Defending'
		OpntAttacking.set("theme_override_colors/font_color", Color(1,0,0) if playerAttacking else Color(0,1,0))
		PlyrAtkIcon.frame = 1 if playerAttacking else 0
		OpntAtkIcon.frame = 1 if !playerAttacking else 0
		Turn.text = 'Turn ' + str(turnNumber)
		Outcome.text = strFallback(outcome)
		
func _on_lock_in_pressed():
	if !lockedIn && matchId && userId && playerChoice && !gameOver && !endturn:
		if playerChoice == '1' ||  playerChoice == '0':
			lockedIn = true
			emit_signal("lock_in", matchId, userId, playerChoice)

func _on_one_pressed():
	if !lockedIn && !gameOver && !endturn:
		playerChoice = '1'

func _on_zero_pressed():
	if !lockedIn && !gameOver && !endturn:
		playerChoice = '0'

func _on_net_code_lock_in_response():
	pass # Replace with function body.
