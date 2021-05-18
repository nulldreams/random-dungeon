extends KinematicBody2D

var ARROW_PROJECTILE = preload("res://entities/weapons/scenes/arrow.tscn")
var BLOOD_PROJECTILE = preload("res://effects/blood.tscn")
var hurt = false
var movement = {
	"motion": Vector2.ZERO,
	"acceleration": 200,
	"max_speed": 70
}
var actions = {
	"attacking": false,
	"hurt": false,
	"chasing": {
		"active": false,
		"target": null
	}
}
onready var arrow_item_position = $arrow_position
onready var random = RandomNumberGenerator.new()

func _ready():
	pass

func _process(delta):
	EnemyStateMachine.check_state(movement.motion, $Sprite, actions)
	if actions.chasing.active:
		get_direction()
		move_and_slide((actions.chasing.target.position - position) * (movement.acceleration/2) * delta)
	else:
		apply_friction(120 * delta)
	movement.motion = move_and_slide(movement.motion)

func get_direction():
	if actions.chasing.target.position.x < position.x:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false		

func apply_movement(acceleration):
	movement.motion += acceleration
	movement.motion = movement.motion.clamped(movement.max_speed)
	
func apply_friction(amount):
	if movement.motion.length() > amount:
		movement.motion -= movement.motion.normalized() * amount
	else:
		movement.motion = Vector2.ZERO
		
remote func hit(angle, knockback):
	if angle:
		var arrow_texture = load("res://entities/weapons/assets/bows/arrow/arrow.png")
		var sprite = Sprite.new()
#		blood_splat(angle)
		sprite.look_at(angle)
		sprite.set_offset(Vector2(-9, -2))
		sprite.set_texture(arrow_texture)
		apply_movement(knockback)
		arrow_item_position.add_child(sprite)
		hurt = true
		$HurtDuration.start()
	else:
		apply_movement(knockback)
		hurt = true
		$HurtDuration.start()

func blood_splat(direction):
	var blood_texture = BLOOD_PROJECTILE.instance()
	blood_texture.position = position
	blood_texture.modulate =  Color("#badc58")
	$'/root/test_room'.add_child(blood_texture)
func _on_detection_range_body_entered(body):
	if body.is_in_group("players"):
		actions.chasing.active = true
		actions.chasing.target = body

func _on_detection_range_body_exited(body):
	if body.is_in_group("players"):
		actions.chasing.active = false
		actions.chasing.target = null
