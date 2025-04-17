extends StaticBody2D

@onready var Door = $Door
@onready var anim_player = $DoorAnimator
@onready var Hall = $"../Hall"
@onready var Room = $"../Room"
@onready var DoorColl = $"../Room/Door Coll"
@onready var interaction_area: InteractionArea = $InteractionArea

func _ready():
	Hall.visible = false
	Room.visible = true
	DoorColl.disabled = false
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	DoorColl.disabled = true #Let player walk through door
	anim_player.play("Bedroom Door")
	await get_tree().create_timer(5).timeout
	anim_player.play_backwards()
	await get_tree().process_frame
	DoorColl.disabled = false

func _on_door_coll_body_entered(_body: Node2D) -> void:
	Hall.visible = true
	await get_tree().physics_frame  # Waits until the next physics frame
	DoorColl.disabled = false
