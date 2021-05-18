extends Node2D

export (NodePath) var NextLevel
export var level = 0
export var DOOR_COORDINATES = ""

func _on_next_level_body_entered(body):
	if body.is_in_group("player"):
		$YSort/next_level/door.play("open")

func _on_level_area_entered(area):
	var level_label = get_tree().get_root().get_node('/root/game/GUI').get_node("level")
	level_label.text = "Level: " + String(level)
