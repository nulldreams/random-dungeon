extends KinematicBody2D

export var open = false

func _process(delta):
	is_opened()

func open_chest():
	open = true

func is_opened():
	if open:
		$sprite.play("opening")
	else:
		$sprite.play("idle")


func _on_interact_zone_body_entered(body):
	if body.is_in_group("players"):
		$question.show()


func _on_interact_zone_body_exited(body):
	if body.is_in_group("players"):
		$question.hide()

func interact():
	open_chest()
