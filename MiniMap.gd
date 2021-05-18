extends MarginContainer

onready var player_marker = $MarginContainer/Grid/player_marker
var direction = "right"

func _ready():
	pass
	
func _process(delta):
	player_marker.rotation = get_node("/root/game/world/player/weapon").rotation + PI/2
#	if (mouse_direction.x <= player_position.x) and direction == "right":
#		entitie_data.movement.direction = "left"
#		$".".scale.x = -1
#	elif (mouse_direction.x >= player_position.x) and direction == "left":
#		entitie_data.movement.direction = "right"
#		$".".scale.x = -1
