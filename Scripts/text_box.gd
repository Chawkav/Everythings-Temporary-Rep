extends CanvasLayer

# This is the dialogue structure for the entire game
@export var Dialogue = {
	"Dog Morning": {
		"PlayerLine1": {"text": "Hey, who's a good boy?", "animation": "Flat Face", "speaker": "Player", "text_rate": 0.05},
		"DogLine1": {"text": "Umm, me?", "animation": "Normal Dog Face", "speaker": "Dog", "text_rate": 0.15},
		"PlayerLine2": {"text": "You want breakfast?", "animation": "Happy Face", "speaker": "Player", "text_rate": 0.045},
		"DogLine2": {"text": "YES YES HURRY UP!", "animation": "Happy Dog Face", "speaker": "Dog", "text_rate": 0.02},
	},
	"Finds Item": {
		"PlayerLine1": {"text": "Woah, this things so cool", "animation": "Confused Face", "speaker": "Player", "text_rate": 0.04},
		"SystemLine1": {"text": "You picked up ___", "animation": "", "speaker": "System", "text_rate": 0.06},
	},
	"Check Radio": {
		"PlayerLine1": {"text": "This old thing hasn't been on in years.", "animation": "Flat Face", "speaker": "Player", "text_rate": 0.05}
	},
	"Check Baseball": {
		"PlayerLine1": {"text": "I miss playing with this bat,", "animation": "Flat Face", "speaker": "Player", "text_rate": 0.05},
		"PlayerLine2": {"text": "We'd be out for hours just flying balls down field.", "animation": "Flat Face", "speaker": "Player", "text_rate": 0.05},
		"PlayerLine3": {"text": "I miss you.", "animation": "Sad Face", "speaker": "Player", "text_rate": 0.095},
	}
}

# Function to queue up the text, animation, and speaker
func queue_text(next_text, animation, speaker, text_rate = null):
	# Ensure that the text_rate key is stored correctly in the dictionary
	var queue_item = {"text": next_text, "animation": animation, "speaker": speaker}
	if text_rate != null:
		queue_item["text_rate"] = text_rate
	text_queue.push_back(queue_item)

# Function to queue up multiple lines with animation and speaker handling
func queue_multiple_text(Category: String, start_key: String, end_key: String):
	if Dialogue.has(Category):
		var keys = Dialogue[Category].keys()
		var start_index = keys.find(start_key)
		var end_index = keys.find(end_key)

		if start_index != -1 and end_index != -1:
			for i in range(start_index, end_index + 1):
				var current_line = Dialogue[Category][keys[i]]
				# Check if the current line has a "text_rate" key, and pass it to queue_text
				var line_text_rate = null
				if current_line.has("text_rate"):
					line_text_rate = current_line["text_rate"]
				queue_text(current_line["text"], current_line["animation"], current_line["speaker"], line_text_rate)

var CHAR_READ_RATE = 0.045
var next_text_to_add = ""
var tween : Tween
var instanced_scene = null
var time_elapsed = 0.0
var original_y = 580
var current_state = State.READY
var text_queue = []

@export var Text: String = "Finds Item"
@export var StartLine: String = "PlayerLine1"
@export var EndLine: String = "SystemLine1"
@export var checking = false

@onready var textbox_container = $TextboxContainer
@onready var start_symbol = $TextboxContainer/Panel/MarginContainer/HBoxContainer/Start
@onready var label = %Label
@onready var end_symbol = $End
@onready var animation_player = $PortraitAnimator

@onready var player_portrait = $"Player Portrait"
@onready var dog_portrait = $"Dog Portrait"
@warning_ignore("shadowed_global_identifier")
@onready var Player = $"../Player"

enum State {
	READY,
	READING,
	FINISHED
} 

func _ready():
	hide_textbox()
	portrait_invis()
	tween = create_tween() # Initialize the tween once here

func hide_textbox():
	start_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	end_symbol.text = ""
	Player.movement = true
	var _can_move = true

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()
	Player.movement = false
	var _can_move = false

func display_text():
	label.visible_characters = 0
	var next_text = text_queue.pop_front()
	label.text = next_text["text"]
	# Play the associated animation for this text
	animation_player.play(next_text["animation"], -1)
	# Set visibility of portraits based on the speaker
	handle_portraits(next_text["speaker"])
	change_state(State.READING)
	show_textbox()

	tween = create_tween() # Create a new tween here

	# Use the text_rate from the dialogue line if it exists, otherwise fall back to the default CHAR_READ_RATE
	var line_char_rate : float
	if next_text.has("text_rate") and next_text["text_rate"] != null:
		line_char_rate = next_text["text_rate"]
	else:
		line_char_rate = CHAR_READ_RATE

	# Set the duration of the tween based on the length of the text and the rate at which it should be revealed
	var tween_duration = len(next_text["text"]) * line_char_rate
	tween.tween_property(label, "visible_characters", len(next_text["text"]), tween_duration)

	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	Callable(self, "_on_tween_finished")
	tween.finished.connect(Callable(self, "_on_tween_finished"))
	next_text_to_add = next_text["text"]

func _on_tween_finished():
	end_symbol.text = "v"
	change_state(State.FINISHED)

func _process(_delta):
	if checking == true:
		if Input.is_action_just_pressed("Interact") and textbox_container.visible == false: #Checks to see if you can open dialogue
			queue_multiple_text(Text, StartLine, EndLine)
		match current_state:
			State.READY:
				end_symbol.visible = false
				if text_queue.size() > 0:
					display_text()
			State.READING:
				# Keep the animation playing while text is being read
				pass
			State.FINISHED:
				time_elapsed += _delta
				var float_offset = sin(time_elapsed * 4.0) * 8  # Adjust speed & height
				end_symbol.position.y =  original_y + float_offset  # Apply the effect

				end_symbol.text = "v"
				end_symbol.visible = true
				animation_player.stop() # Stop the animation after the text finishes
				# If Interact is pressed and the text is finished, move back to ready state
				if Input.is_action_just_pressed("Interact"):
					if text_queue.size() == 0:
						hide_textbox()
						# Hide the portrait after the last line of text
						portrait_invis()
						checking = false
					change_state(State.READY)

# Function to handle character portrait visibility
func handle_portraits(speaker: String):
	# Set the correct portrait to visible based on the speaker
	if speaker == "Player":
		player_portrait.visible = true
		dog_portrait.visible = false
	elif speaker == "Dog":
		player_portrait.visible = false
		dog_portrait.visible = true
	else:
		player_portrait.visible = false
		dog_portrait.visible = false

func portrait_invis():
	player_portrait.visible = false
	dog_portrait.visible = false

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			pass
		State.READING:
			pass
		State.FINISHED:
			animation_player.stop()
