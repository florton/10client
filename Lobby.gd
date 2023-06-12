extends Node2D

@onready var Users = find_child("Users")
@onready var Username = find_child("Username")

signal register
signal load_users
signal challenge_user
signal accept_challenge
signal start_match

var userId = null
var users = []

var isPaused = false

func loadUsers():
	if !isPaused:
		emit_signal("load_users")
		print("load users")
		await get_tree().create_timer(3).timeout
		loadUsers()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	loadUsers()

func _on_register_pressed():
	if (len(Username.text) > 0 && userId == null):
		emit_signal("register", Username.text)

func _on_challenge_pressed():
	var selection = Users.get_selected_items()
	if len(selection) > 0:
		var challengerId = users[selection[0]].id
		emit_signal("challenge_user", userId, challengerId)

func _on_accept_pressed():
	var selection = Users.get_selected_items()
	if len(selection) > 0:
		var challengerId = users[selection[0]].id
		emit_signal("accept_challenge", userId, challengerId)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_net_code_users_response(usersResp):
	users = usersResp
	var selection = Users.get_selected_items()
	Users.clear()
	var you = null
	for user in users:
		if userId && user.id == userId:
			you = user
			if user.match != null:
				isPaused = true
				emit_signal("start_match", userId, user.match)
	for user in users:
		var info = ''
		if user.id == userId:
			info = " (you)"
		if userId in user.challenges:
			info = " [Challenge Sent]"
		if you && user.id in you.challenges:
			info = " <Challenged You>"
		if user.match != null:
			info = " [In a Match]"
		Users.add_item(user.name + info)
	if len(selection) > 0:
		Users.select(selection[0])

func _on_net_code_register_response(id):
	userId = id

func _on_net_code_challenge_user_response():
	pass # Replace with function body.

func _on_net_code_accept_challenge_response():
	pass # Replace with function body.

