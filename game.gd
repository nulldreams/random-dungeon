extends Node2D

var cursor_aim = load("res://assets/v1.1 dungeon crawler 16x16 pixel pack/ui (new)/crosshair_3.png")
onready var player = preload("res://entities/player/player.tscn").instance()

onready var enemies = {
	"goblin": preload("res://entities/enemies/goblin/goblin.tscn"),
	"slime": preload("res://entities/enemies/slime/slime.tscn"),
	"bat": preload("res://entities/enemies/bat/bat.tscn")
}

var rng = RandomNumberGenerator.new()
export var dungeon_levels = 2
onready var columns = []

func fill_columns():
	for i in range(0, dungeon_levels):
		var column = []
		columns.append([])

func _ready():
	rng.randomize()
	fill_columns()
	generate_dungeon()
	Input.set_custom_mouse_cursor(cursor_aim)

func generate_dungeon():
	var initial_room_pos = Vector2.ZERO
	for i in range(0, columns.size()):
		var column = columns[i]
		var dungeons = fill_dungeon_rooms(i)
		initial_room_pos = Vector2.ZERO
		for j in range(0, dungeons.size()):
			var dungeon = dungeons[j]
			if !dungeon: 
				initial_room_pos.y += 192
				columns[i].append(null)
			else:
				initial_room_pos.x = i * 380
				dungeon.scene.position = initial_room_pos
				if j > 0:
					add_enemies(j + 10, dungeon.scene.position)
				$'/root/game/world'.add_child(dungeon.scene)
				spawn_player_if_can(dungeon.spawn_player)
				initial_room_pos.y += 192
				columns[i].append(parse_room_doors(dungeon.scene.DOOR_COORDINATES))

func add_enemies(multiplier, position):
	var local_enemies = [enemies.bat, enemies.slime, enemies.goblin]
	for i in range(0, 1 * multiplier):
		var enemy = local_enemies[rng.randi_range(0, local_enemies.size() - 1)].instance()
		position += Vector2(rng.randi_range(5, 20), rng.randi_range(5, 20))
		enemy.position = position
		$'/root/game/world'.add_child(enemy)
	

func parse_room_doors(door_cordinates):
	var doors = door_cordinates.split('_')
	return {
		"top": true if doors[0].to_lower() == "true" else false,
		"right": true if doors[1].to_lower() == "true" else false,
		"bottom": true if doors[2].to_lower() == "true" else false,
		"left": true if doors[3].to_lower() == "true" else false
	}

func fill_dungeon_rooms(column):
	var dungeons = []
	dungeons.resize(dungeon_levels)
	dungeons[0] = Rooms.set_initial_room()
	for i in range(dungeons.size()):
		var rand_room = rng.randi_range(0, Rooms.mid_rooms.size() - 1)
		if column > 0:
			if columns[column-1] and columns[column-1].size() - 1 >= i:
				var cousin_room_cordinates = columns[column-1][i]
				var above_room_cordinates = parse_room_doors(dungeons[i-1].scene.DOOR_COORDINATES) if dungeons[i-1] else null
				if cousin_room_cordinates:
					if !cousin_room_cordinates.right:
						if above_room_cordinates:
							if above_room_cordinates.bottom:
								dungeons[i] = chooseRoom(i, column, dungeons, "with_top_door")
						else:
							dungeons[i] = null
					else:
						if above_room_cordinates:
							print(above_room_cordinates.bottom, " ", column, " ", i)
							if above_room_cordinates.bottom:
								dungeons[i] = chooseRoom(i, column, dungeons, "with_top_and_left_door")
							else:
								dungeons[i] = chooseRoom(i, column, dungeons, "with_left_door")
						else:
							dungeons[i] = chooseRoom(i, column, dungeons, "with_left_door")
				else:
					if above_room_cordinates:
						if above_room_cordinates.bottom:
							dungeons[i] = chooseRoom(i, 0, dungeons, "with_top_door")
					else:
						dungeons[i] = null
		else:
			if i >= 1:
				if dungeons[i-1]:
					var room_cordinates = parse_room_doors(dungeons[i-1].scene.DOOR_COORDINATES)
					if room_cordinates.bottom:
						dungeons[i] = chooseRoom(i, 0, dungeons, "with_top_door")
					else:
						dungeons[i] = null
				else:
					dungeons[i] = null
	return dungeons

func chooseRoom(level, column_index, dungeons, room_type):
	var room 
	if room_type == "with_top_door":
		room = Rooms.random_rooms_with_top_door(level == dungeons.size()-1)
	elif room_type == "with_left_door":
		room = Rooms.random_rooms_with_left_door(column_index == dungeons.size()-1)
	elif room_type == "with_top_and_left_door":
		room = Rooms.random_rooms_with_top_and_left_door(column_index == dungeons.size()-1)
	room.level = level
	return { "scene": room, "spawn_player": false }

func spawn_player_if_can(spawn):
	if spawn:
		player.position = Vector2(100, 100)
		$'/root/game/world'.add_child(player)


func _on_Button_pressed():
	get_tree().reload_current_scene()
