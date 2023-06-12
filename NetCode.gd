extends Node2D

const uuid_util = preload('res://uuid.gd')

signal register_response
signal users_response
signal challenge_user_response
signal accept_challenge_response

signal load_match_response
signal lock_in_response

var serverHost = "http://localhost:3000"

var clientId = ''

func _ready():
	clientId = uuid_util.v4()
	
func GET(url, callback):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(callback)
	var headers = ["Referer: " + clientId]
	http_request.request(url, headers)
	await get_tree().create_timer(30).timeout
	http_request.queue_free()

# Lobby

func _on_lobby_register(name):
	if name:
		GET(serverHost + '/lobby/register/' + name, _on_register_response)
	
func _on_register_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if (json && json.has("data") && len(json.data) > 0):
		emit_signal("register_response", json.data)
	
func _on_lobby_load_users():
	GET(serverHost + '/lobby/users', _on_load_users_response)

func _on_load_users_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if (json && json.has("data") && len(json.data) > 0):
		emit_signal("users_response", json.data)

func _on_lobby_challenge_user(userId, challengerId):
	if userId && challengerId:
		GET(serverHost + '/lobby/challenge/' + userId + '/' + challengerId ,
		_on_challenge_user_response)

func _on_challenge_user_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	emit_signal("challenge_user_response") # not being used

func _on_lobby_accept_challenge(userId, challengerId):
	if userId && challengerId:
		GET(serverHost + '/lobby/accept/' + userId + '/' + challengerId ,
		_on_accept_challenge_response)

func _on_accept_challenge_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	emit_signal("accept_challenge_response") # not being used

# Match

func _on_game_load_match(matchId):
	if matchId:
		GET(serverHost + '/match/' + matchId, _on_load_match_response)

func _on_load_match_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if (json && json.has("data") && len(json.data) > 0):
		emit_signal("load_match_response", json.data)

func _on_game_lock_in(matchId, userId, choice):
	if userId && matchId && choice:
		GET(serverHost + '/match/lock_in/' + matchId + '/' + userId + '/' + choice,
		_on_lock_in_response)

func _on_lock_in_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	emit_signal("lock_in_response") # not being used
