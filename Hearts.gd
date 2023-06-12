extends Node2D

var hp = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var i = 0
	for node in get_children():
		node.frame = 0 if i < hp else 1
		i+=1
