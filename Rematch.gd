extends Node2D

@onready var SentLabel = find_child("Sent")

var sent = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	SentLabel.visible = sent
	
