extends Sprite2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var Textbox = $".."

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	Textbox.Text = "Check Radio"
	Textbox.StartLine = "PlayerLine1"
	Textbox.EndLine = "PlayerLine1"
	Textbox.checking = true
