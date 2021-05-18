extends Node

onready var starter_room = preload("res://rooms/starter_room.tscn")
onready var room_top_bottom = preload("res://rooms/room_top_bottom.tscn")
onready var room_top_left = preload("res://rooms/room_top_left.tscn")
onready var room_top_right_left = preload("res://rooms/room_top_right_left.tscn")
onready var room_top_right_bottom = preload("res://rooms/room_top_right_bottom.tscn")
onready var room_top_right_bottom_left = preload("res://rooms/room_top_right_bottom_left.tscn")
onready var room_left = preload("res://rooms/room_left.tscn")
onready var room_left_bottom = preload("res://rooms/room_left_bottom.tscn")
onready var room_right_left_bottom = preload("res://rooms/room_right_left_bottom.tscn")
onready var room_right_left = preload("res://rooms/room_right_left.tscn")
onready var room_top = preload("res://rooms/room_top.tscn")

onready var chest_room_left = preload("res://rooms/chest/chest_room_left.tscn")

onready var mid_rooms = [room_top_bottom, room_top_right_bottom, room_top]
onready var mid_rooms_left = [room_left, room_right_left]

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func random_rooms_with_top_and_left_door(last):
	var rooms = [room_top_right_left, room_top_left]
	if !last:
		rooms.append(room_top_right_bottom_left)
	var rand = rng.randi_range(0, rooms.size() - 1)
	return rooms[rand].instance()

func random_rooms_with_left_door(last):
	var rooms = [room_left]
	if !last:
		rooms.append(room_right_left)
		rooms.append(room_left_bottom)
		rooms.append(room_right_left_bottom)
	var rand = rng.randi_range(0, rooms.size() - 1)
	return random_chest(rooms)

func random_chest(rooms):
	rooms.append(chest_room_left)
	var rand = rng.randi_range(0, rooms.size() - 1)
	return rooms[rand].instance()

func random_rooms_with_top_door(last):
	var rooms = []
	if !last:
		rooms.append(room_top_right_bottom)
		rooms.append(room_top_right_bottom)
		rooms.append(room_top_bottom)
	else:
		rooms.append(room_top)
	var rand = rng.randi_range(0, rooms.size() - 1)
	return rooms[rand].instance()

func set_initial_room():
	var initial_room = starter_room.instance()
	initial_room.level = 0
	return { "scene": initial_room, "spawn_player": true }
	
func set_last_room(dungeons):
	var last_room = room_top.instance()
	last_room.level = dungeons.size() - 1
	return { "scene": last_room, "spawn_player": false }
