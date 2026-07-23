extends VBoxContainer

@export var title: String

@onready var title_label: Label = $TitleLabel
@onready var label: Label = $Label

func _ready() -> void:
	change_title(title)

func change_title(title: String):
	title_label.text = title

func change_lable(coins: int, lap: int):
	label.text = "Coins: " + str(coins) + "\n" + "Lap: " + str(lap) + "/3"
	animate_label()
	
func animate_label():
	var tween = create_tween()
	tween.tween_property(label, "offset_transform_scale", 1.1, 0.2)
	tween.tween_property(label, "offset_transform_scale", 1.0, 0.2)
