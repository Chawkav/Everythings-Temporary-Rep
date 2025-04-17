extends Sprite2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var Textbox = $"../../../TextBox"

func _ready():
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	Textbox.Text = "Finds Item"
	Textbox.StartLine = "PlayerLine1"
	Textbox.EndLine = "SystemLine1"
	Textbox.checking = true
