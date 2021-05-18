extends KinematicBody2D

export var type = 'tree'
export var flip_h = false

func _ready():
	$AnimatedSprite.flip_h = flip_h
