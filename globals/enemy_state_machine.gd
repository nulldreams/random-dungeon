extends Node

enum {
	STATE_IDLE,
	STATE_RUNNING,
	STATE_ATTACKING,
	STATE_CHASING,
	STATE_HURT
}
var state = STATE_IDLE

func _ready():
	pass

remote func check_state(motion, enemy, actions):
	if motion == Vector2.ZERO:
		state = STATE_IDLE
	if motion != Vector2.ZERO:
		state = STATE_RUNNING
	if actions.chasing.active:
		state = STATE_CHASING
	if actions.attacking:
		state = STATE_ATTACKING
	if actions.hurt:
		state = STATE_HURT
	state_machine(enemy, actions)
	
func state_machine(enemy, actions):
	match state:
		STATE_IDLE:
			idle(enemy)
		STATE_RUNNING:
			running(enemy)
		STATE_ATTACKING:
			attacking(enemy)
		STATE_CHASING:
			chase(enemy, actions.chasing.target)

func attacking(enemy):
	change_animation(enemy, "attacking")

func idle(enemy):
	change_animation(enemy, "idle")

func running(enemy):
	change_animation(enemy, "running")

func chase(enemy, target):
	change_animation(enemy, "running")

func change_animation(enemy, animation):
	enemy.play(animation)
