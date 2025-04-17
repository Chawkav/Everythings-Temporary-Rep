extends Sprite2D  # Works for Sprite2D, StaticBody2D, etc.

@onready var player = $"../../Player"
@onready var DoorColl = %BedDoorColl

func _process(_delta):
	# If player is below the object, render them in front
	if player.position.y > position.y:
		z_index = player.z_index - 1
	else:
		z_index = player.z_index + 1

func fade_out(duration: float):
	var start_time = Time.get_ticks_msec()
	var end_time = start_time + int(duration * 1000)
	while Time.get_ticks_msec() < end_time:
		var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
		modulate.a = 1.0 - (elapsed / duration)
		await get_tree().process_frame  # Wait for next frame
	modulate.a = 0  # Ensure full transparency
	queue_free()  # Optional: Remove sprite

func _on_door_coll_body_entered(_body: Node2D) -> void:
	await get_tree().process_frame  # Wait for next frame
	DoorColl.disabled = false
	fade_out(0.5)
