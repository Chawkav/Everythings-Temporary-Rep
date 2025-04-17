extends StaticBody2D

func fade_out(duration: float):
	var start_time = Time.get_ticks_msec()
	var end_time = start_time + int(duration * 1000)
	while Time.get_ticks_msec() < end_time:
		var elapsed = (Time.get_ticks_msec() - start_time) / 1000.0
		modulate.a = 1.0 - (elapsed / duration)
		await get_tree().process_frame  # Wait for next frame
	modulate.a = 0  # Ensure full transparency
	queue_free()  # Optional: Remove sprite
