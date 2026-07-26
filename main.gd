extends Node2D

signal lap_completed

enum Car {
	BLACK,
	BLUE,
	PURPLE,
	GREEN
}

var current_player_turn = Car.BLACK

var player_state = {
	Car.BLACK: {
		"pos": 0,
		"coins": 0,
		"cards": [],
		"lap": 0,
	},
	Car.BLUE: {
		"pos": 0,
		"coins": 0,
		"cards": [],
		"lap": 0,
	},
	Car.PURPLE: {
		"pos": 0,
		"coins": 0,
		"cards": [],
		"lap": 0,
	},
	Car.GREEN: {
		"pos": 0,
		"coins": 0,
		"cards": [],
		"lap": 0,
	},
}
var car_textures = []
@onready var car_black: Sprite2D = $CarBlack
@onready var car_blue: Sprite2D = $CarBlue
@onready var car_purple: Sprite2D = $CarPurple
@onready var car_green: Sprite2D = $CarGreen

@onready var black_player_state: VBoxContainer = $CanvasLayer2/GridContainer/BlackPlayerState
@onready var blue_player_state: VBoxContainer = $CanvasLayer2/GridContainer/BluePlayerState
@onready var purple_player_state: VBoxContainer = $CanvasLayer2/GridContainer/PurplePlayerState
@onready var green_player_state: VBoxContainer = $CanvasLayer2/GridContainer/GreenPlayerState

@onready var main_track_markers: Node = $MainTrackPoints
@onready var turn_texture: TextureRect = $TurnTrackerUI/TextureRect

var tiles: Array[Marker2D] = []

var actions = {
	"Banana": "throw a 3 spaces infront or behind, moves player back three spaces",
	"Airhorn": "shields you from any attacks!",
	"Star": "next turn invincible",
	"Bullet Bill": "go to first place!",
	"Thunder Cloud": "All players discare your mystery cards",
	"Squid": "every player on next turn must roll and flip a coin, if heads, move, if tials, remain",
	"BomBom": "throw bomb 2 spaces infront or behind",
	"Skeleton Key":  "use any shortcut",
	"Red Koopa Shell": "player infront of you skips their turn",
	"Golden Mushroom": "x2 on your next roll",
	"Green Koopa Shell": "only use on visible player, player moves back 1 space",
	"Hammer-bros": "throw 3-5 spaces ahead to stun your opponent, player skips next turn",
	"Mushroom": "you may roll again!",
	"Ghost": "steal an item from nearest player",
	"Boomerang": "can either be thrown backwards or forwards, on hit player next turn lower dice roll by 1"
}

var roll: int

@onready var _dice_sprite: Sprite2D = $DiceSprite

func _ready() -> void:
	for child in main_track_markers.get_children():
		tiles.append(child)
	
	car_textures.append_array([car_black.texture, car_blue.texture, car_purple.texture, car_green.texture])
	
	lap_completed.connect(func():
		match current_player_turn:
			Car.BLACK:
				black_player_state.change_label(player_state[current_player_turn]["coins"], 
				player_state[current_player_turn]["lap"])
			Car.BLUE:
				blue_player_state.change_label(player_state[current_player_turn]["coins"], 
				player_state[current_player_turn]["lap"])
			Car.PURPLE:
				purple_player_state.change_label(player_state[current_player_turn]["coins"], 
				player_state[current_player_turn]["lap"])
			Car.GREEN:
				green_player_state.change_label(player_state[current_player_turn]["coins"], 
				player_state[current_player_turn]["lap"])
	)
	
	load_coins_to_every_other_tile()
	
	

func _on_flip_button_pressed() -> void:
	pass # Replace with function body.


func _on_draw_card_button_pressed() -> void:
	pass # Replace with function body.

var dice_textures = ["res://assets/dice/dieRed1.png", "res://assets/dice/dieRed2.png", "res://assets/dice/dieRed3.png",
"res://assets/dice/dieRed4.png", "res://assets/dice/dieRed5.png", "res://assets/dice/dieRed6.png"]

func _on_roll_button_pressed() -> void:
	roll = randi_range(0, 5)
	_dice_sprite.texture = load(dice_textures[roll])
	var pos = player_state[current_player_turn]["pos"]
	
	if player_state[current_player_turn]["pos"] == 0:
		player_state[current_player_turn]["pos"] += roll
	else:
		player_state[current_player_turn]["pos"] = pos + roll + 1

	var has_passed_start = player_state[current_player_turn]["pos"] > tiles.size() - 2
	if has_passed_start:
		var tiles_left = (tiles.size()-1) - pos
		var tiles_past_start = roll - tiles_left
		player_state[current_player_turn]["pos"] = tiles_past_start
		player_state[current_player_turn]["lap"] += 1
		lap_completed.emit()
	
	# shows the visual change in position 
	var tween = create_tween()
	match current_player_turn:
		Car.BLACK:
			tween.tween_property(car_black, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
		Car.BLUE:
			tween.tween_property(car_blue, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
		Car.PURPLE:
			tween.tween_property(car_purple, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
		Car.GREEN:
			tween.tween_property(car_green, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
	
	next_turn()
	
func next_turn():
	var turn_order = current_player_turn + 1
	
	if turn_order > Car.size() - 1:
		current_player_turn = 0 as Car
		turn_texture.texture = car_textures[0]
		return
	
	current_player_turn = turn_order as Car
	turn_texture.texture = car_textures[turn_order]
	
func load_coins_to_every_other_tile() -> void:
	var count = 0
	for tile in tiles:
		if count % 2 == 0:
			var shortcut_coin = load("res://scenes_and_scripts/coin.tscn") as PackedScene
			var coin_instance = shortcut_coin.instantiate()
			get_node("ShorcutCoins").add_child(coin_instance)
			coin_instance.global_position = tile.global_position
		count += 1
	
	
	
	
	
