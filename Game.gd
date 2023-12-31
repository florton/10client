extends Node2D

@onready var Info = find_child("Info")

@onready var Choices = Info.find_child("Choices")
@onready var PlyrChoice = Choices.find_child("PlyrChoice")
@onready var PlyrPrev = Choices.find_child("PlyrPrev")
@onready var PlyrPrevPrev = Choices.find_child("PlyrPrevPrev")
@onready var OpntChoice = Choices.find_child("OpntChoice")
@onready var OpntPrev = Choices.find_child("OpntPrev")
@onready var OpntPrevPrev = Choices.find_child("OpntPrevPrev")

@onready var Rematch = find_child("Rematch")
@onready var PlyrName = Info.find_child("PlyrName")
@onready var PlyrInfo = Info.find_child("PlyrInfo")
@onready var PlyrIcon = Info.find_child("PlyrIcon")
@onready var PlyrAttacking = Info.find_child("PlyrAttacking")
@onready var PlyrHp = Info.find_child("PlyrHp")
@onready var PlyrAtkIcon = Info.find_child("PlyrAtkIcon")
@onready var OpntInfo = Info.find_child("OpntInfo")
@onready var OpntIcon = Info.find_child("OpntIcon")
@onready var OpntName = Info.find_child("OpntName")
@onready var OpntAttacking = Info.find_child("OpntAttacking")
@onready var OpntHp = Info.find_child("OpntHp")
@onready var OpntAtkIcon = Info.find_child("OpntAtkIcon")
@onready var Turn = Info.find_child("Turn")
@onready var Outcome = Info.find_child("Outcome")
@onready var wheel = Info.find_child("Wheel")
@onready var anim = Info.find_child("main animation")

signal load_match
signal lock_in
signal challenge_user
signal await_match

var rng = RandomNumberGenerator.new()
const playerColor = Color(0, 0.69411766529083, 1)
const opponentColor = Color(0.76470589637756, 0, 0)

var isPaused = true
var iconanim

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
var playerPrevPrevChoice
var playerHp
var opponentChoice
var opponentPrevChoice
var opponentPrevPrevChoice
var opponentHp
var outcome

var endturn = false
var gameOver = false

func loadMatch():
	if !isPaused && !gameOver:
		emit_signal("load_match", matchId)
		print("load match")
		await get_tree().create_timer(2).timeout
		loadMatch()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	PlyrIcon.frame = rng.randi_range(0, 15)
	OpntIcon.frame = rng.randi_range(0, 15)

func getOutcome(pAttacking, pChoice, oChoice):
	var defenderName = strFallback(opponentName if pAttacking else "You")
	if pChoice == oChoice:
		if pAttacking:
			anim.play("op b")
		else:
			anim.play("player b")
		return defenderName + '\n Blocked!'
		
	else:
		var damage = '1'
		if pAttacking:
			anim.play("op h")
		else:
			anim.play("player h")
		if (pAttacking && pChoice == '1') || (!pAttacking && oChoice == '1'):
			damage = '2'
		return defenderName + '\n Took ' + damage + ' Damage'
		
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
			playerPrevPrevChoice = playerPrevChoice
			playerPrevChoice = player.prevChoice
			opponentPrevPrevChoice = opponentPrevChoice
			opponentPrevChoice = opponent.prevChoice
		else:
			Rematch.visible = true
		lockedIn = false
		endturn = false
	playerAttacking = matchData.attacker == userId

func startGame(uId, mId):
	Rematch.visible = false
	Rematch.sent = false
	userId = uId
	matchId = mId
	playerHp = 5
	opponentHp = 5
	playerChoice = '?'
	opponentChoice = '?'
	isPaused = false
	gameOver = false
	turnNumber = 0
	outcome = ""
	loadMatch()

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
		PlyrInfo.text = '' if !lockedIn || endturn else 'Locked In'
		OpntInfo.text = '' if endturn else ('Choosing' if !opponentLockedIn else 'Locked In')
		PlyrAttacking.text = 'Attacking' if playerAttacking else 'Defending'
		PlyrAttacking.set("theme_override_colors/font_color", Color(.6,.6,1) if !playerAttacking else Color(1,0,0))
		OpntAttacking.text = 'Attacking' if !playerAttacking else 'Defending'
		OpntAttacking.set("theme_override_colors/font_color", Color(1,0,0) if playerAttacking else Color(0.2,1,0.2))
		PlyrAtkIcon.frame = 1 if playerAttacking else 0
		wheel.flip_h = false if playerAttacking else true
		OpntAtkIcon.frame = 1 if !playerAttacking else 0
		Turn.text = 'Turn ' + str(turnNumber)
		Outcome.text = strFallback(outcome)
		PlyrChoice.text = strFallback(playerChoice)
		OpntChoice.text = strFallback(opponentChoice)
		PlyrPrev.text = strFallback(playerPrevChoice)
		PlyrPrevPrev.text = strFallback(playerPrevPrevChoice)
		OpntPrev.text = strFallback(opponentPrevChoice)
		OpntPrevPrev.text = strFallback(opponentPrevPrevChoice)
		PlyrChoice.set("theme_override_colors/font_color", playerColor if playerAttacking else opponentColor)
		PlyrPrev.set("theme_override_colors/font_color", playerColor if playerAttacking else opponentColor)
		PlyrPrevPrev.set("theme_override_colors/font_color", playerColor if playerAttacking else opponentColor)
		OpntChoice.set("theme_override_colors/font_color",playerColor if !playerAttacking else opponentColor)
		OpntPrev.set("theme_override_colors/font_color",playerColor if !playerAttacking else opponentColor)
		OpntPrevPrev.set("theme_override_colors/font_color",playerColor if !playerAttacking else opponentColor)
		
		
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
		
func _on_rematch_button_pressed():
	Rematch.sent = true
	emit_signal("challenge_user", userId, opponentId)
	emit_signal("await_match")

func _on_net_code_lock_in_response():
	pass # Replace with function body.


