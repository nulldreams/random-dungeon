extends RigidBody2D

const CAST_VELOCITY = Vector2(400, 0)
export var life_time = 2
export var arrow_damage = 10
export var caster = ""
export var dev = false

var DUST_PARTICLE = GlobalParticles.emitters.DUST.instance()
var velocity = Vector2.ZERO
var angle = null

onready var life_timer = $LifeTimer

func _ready():
	set_as_toplevel(true)
	_lunch_arrow()

func _lunch_arrow():
	apply_impulse(Vector2(), Vector2(CAST_VELOCITY).rotated(rotation))
	angle = Vector2(CAST_VELOCITY).rotated(rotation)
	life_timer.wait_time = life_time
	life_timer.start()

func SelfDestruct():
	emit_dust()
	queue_free()

func _on_LifeTimer_timeout():
	SelfDestruct()

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		var knockback_range = angle * 5000 # * Vector2(-1, -1)
		body.hit(angle, knockback_range)
		queue_free()

func emit_dust():
	DUST_PARTICLE.position = position
	if !dev:
		$"/root/game/world".add_child(DUST_PARTICLE)
	else:
		$"/root/test_room".add_child(DUST_PARTICLE)
