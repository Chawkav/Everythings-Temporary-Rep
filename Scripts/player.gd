extends CharacterBody2D

class_name Player

@export var speed: float = 120
@onready var sprite = $Body
@onready var anim_player = $MovementPlayer

@export var movement = true

var last_direction = "down"

func _process(_delta):
	if movement:
		var direction = Vector2.ZERO

		# Prioritize downward movement over upward movement
		if Input.is_action_pressed("down"):
			direction.y += 1
			last_direction = "down"
		elif Input.is_action_pressed("up"):
			direction.y -= 1
			last_direction = "up"

		# Prioritize right movement over left movement
		if Input.is_action_pressed("right"):
			direction.x += 1
			last_direction = "right"
		elif Input.is_action_pressed("left"):
			direction.x -= 1
			last_direction = "left"

		# Move the player with collision handling
		velocity = direction.normalized() * speed
		move_and_slide()

		# Handle animations
		if direction != Vector2.ZERO:
			if direction.y > 0:
				anim_player.play("Front walk")
			elif direction.y < 0:
				anim_player.play("Back walk")
			elif direction.x > 0:
				anim_player.play("Right walk")
			elif direction.x < 0:
				anim_player.play("Left walk")
		else:
			play_idle_animation()

	else:
		play_idle_animation()

func play_idle_animation():
	# Play the idle animation based on the last direction moved
	match last_direction:
		"up":
			anim_player.play("Back")
		"down":
			anim_player.play("Front")
		"left":
			anim_player.play("Left")
		"right":
			anim_player.play("Right")
