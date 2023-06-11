extends Node2D

signal users_response

var serverHost = "http://localhost:3000"

func _ready():
	pass
	
#	$HTTPRequest.request_completed.connect(_on_request_completed)
#	$HTTPRequest.request("https://api.github.com/repos/godotengine/godot/releases/latest")

#func _on_request_completed(result, response_code, headers, body):
#	var json = JSON.parse_string(body.get_string_from_utf8())
#	print(json["name"])

func _on_lobby_register(name):
	$HTTPRequest.request_completed.connect(_on_register_response)
	$HTTPRequest.request(serverHost + '/lobby/register/' + name)
	
func _on_register_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	
func _on_lobby_load_users():
	$HTTPRequest.request_completed.connect(_on_load_users_response)
	$HTTPRequest.request(serverHost + '/lobby/users')

func _on_load_users_response(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if (json && json.has("data") && len(json.data) > 0):
		emit_signal("users_response", json.data)
