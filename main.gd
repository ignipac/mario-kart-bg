extends Node2D

signal lap_completed
signal player_won(winner: Car)

enum Car {
	BLACK,
	BLUE,
	PURPLE,
	GREEN
}

const LAST_LAP = 3

var current_player_turn = Car.BLACK
var piece_count = 0 # temp soultion to track when all pieces finish a lap
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
var car_areas = []
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
	car_areas.append_array([$CarBlack/CBlackArea2D, $CarBlue/CBlueArea2D, $CarPurple/CPurpleArea2D, $CarGreen/CGreenArea2D])
	

	lap_completed.connect(func():
		update_player_states()
		piece_count += 1
		print(piece_count)
		if piece_count == 4:
			add_coins_to_every_other_tile()
			piece_count = 0
		# does not work as intended as it's not unique to each piece
	)
	
	player_won.connect(func(winner):
		print("player won", Car.find_key(winner))
		get_node($WinnerUI.get_path()).show()
		$WinnerUI/WinnerPanel/Label.text = (Car.find_key(winner) as String).to_lower().capitalize() + " Wins!"
	)
	
	
	add_coins_to_every_other_tile()
	
	for c_area in car_areas:
		c_area.area_entered.connect(func(area: Area2D):
			var the_coin_picked_up = area.get_parent()
			if not the_coin_picked_up.has_method("fade_out"):
				return
			player_state[current_player_turn]["coins"] += 1
			the_coin_picked_up.fade_out()
			update_player_states()
			$CarBlack/CBlackArea2D/CollisionShape2D.call_deferred("set_disabled", true)
			$CarBlue/CBlueArea2D/CollisionShape2D.call_deferred("set_disabled", true)
			$CarPurple/CPurpleArea2D/CollisionShape2D.call_deferred("set_disabled", true)
			$CarGreen/CGreenArea2D/CollisionShape2D.call_deferred("set_disabled", true)
		)
	
	
func update_player_states():
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
		if player_state[current_player_turn]["lap"] > LAST_LAP:
			player_won.emit(current_player_turn)
		lap_completed.emit()
	
	# shows the visual change in position 
	var tween = create_tween()
	match current_player_turn:
		Car.BLACK:
			tween.tween_property(car_black, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
			tween.finished.connect(func():$CarBlack/CBlackArea2D/CollisionShape2D.disabled = false)
		Car.BLUE:
			tween.tween_property(car_blue, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
			tween.finished.connect(func():$CarBlue/CBlueArea2D/CollisionShape2D.disabled = false)
		Car.PURPLE:
			tween.tween_property(car_purple, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
			tween.finished.connect(func():$CarPurple/CPurpleArea2D/CollisionShape2D.disabled = false)
		Car.GREEN:
			tween.tween_property(car_green, "global_position", tiles[player_state[current_player_turn]["pos"]].global_position, 0.4)
			tween.finished.connect(func():$CarGreen/CGreenArea2D/CollisionShape2D.disabled = false)
	
	next_turn()
	
func next_turn():
	var turn_order = current_player_turn + 1
	
	if turn_order > Car.size() - 1:
		current_player_turn = 0 as Car
		turn_texture.texture = car_textures[0]
		return
	
	current_player_turn = turn_order as Car
	turn_texture.texture = car_textures[turn_order]

# could refill the tiles with coins, rather reset the ones picked up
func add_coins_to_every_other_tile() -> void:
	for idx in range(tiles.size() - 1):
		if idx % 2 == 0:
			if tiles[idx].get_child_count() > 1: # prevent doubling coins
				continue
			var shortcut_coin = load("res://scenes_and_scripts/shortcut_coin.tscn") as PackedScene
			var coin_instance = shortcut_coin.instantiate()
			tiles[idx].add_child(coin_instance)
			#coin_instance.global_position = tile.global_position

func use_major_shortcut():
	pass
	# TODO

func use_minor_shortcut():
	pass
	# TODO

func do_a_coin_flip():
	pass
	# TODO
	
func draw_a_card():
	pass
	# TODO
	
	
	
