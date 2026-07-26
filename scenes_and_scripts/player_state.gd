extends VBoxContainer

@export var title: String

@onready var title_label: Label = $TitleLabel
@onready var label: Label = $Label

func _ready() -> void:
	title_label.text = title

func change_label(coins: int, lap: int):
	label.text = "Coins: " + str(coins) + "\n" + "Lap: " + str(lap) + "/3"
	animate_label()
	
func animate_label():
	var tween = create_tween()
	tween.tween_property(label, "offset_transform_scale", Vector2(1.1, 1.1), 0.2)
	tween.tween_property(label, "offset_transform_scale", Vector2.ONE, 0.2)
