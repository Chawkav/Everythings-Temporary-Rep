extends Area2D

@export var Entering : String

@onready var parent = $".."

func _on_body_entered(body: Node2D) -> void:
	parent.get_node(Entering).visible = true
