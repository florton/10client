extends Node2D

signal register_response
signal users_response
signal challenge_user_response
signal accept_challenge_response

var serverHost = "http://localhost:3000"

func _ready():
	pass
	
func GET(url, callback):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(callback)
	http_request.request(url)
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
	emit_signal("challenge_user_response")

func _on_lobby_accept_challenge(userId, challengerId):
	if userId && challengerId:
		GET(serverHost + '/lobby/accept/' + userId + '/' + challengerId ,
		_on_accept_challenge_response)

func _on_accept_challenge_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	emit_signal("accept_challenge_response")
