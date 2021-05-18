extends Node2D

const height = 200
const width = 400

const GRAVITY = .3
const DAMPING = .999
var drops = []
var timer = 0

class Particle:
	var old; var new
	func _init(arg1, arg2): 
		old = Vector2(arg1, arg2)
		new = old
	func integrate():
		var velocity = velocity()
		old = new
		new *= velocity * DAMPING
	func velocity():
		return (new - old)
	func move(offset_x, offset_y):
		new += Vector2(offset_x, offset_y)
	func bounce():
		if (new.y > height):
			var velocity = velocity()
			old.y = height
			new.y = old.y - velocity.y * .3
		if new.x < 0 or new.x > width:
			new.x = 0
		return new

func _draw():
	for j in range(5):
		if drops.size() < 1000:
			var drop = Particle.new(width * .5, height)
			drop.modulate = Color(1, 0, 1)
			drop.move(randf() * 4-2, randf()*(-2)-15)
			drops.push_front(drop)
	for i in range(drops.size()):
		drops[i].move(0, GRAVITY)
		drops[i].integrate()
		draw_circle(drops[i].bounce(), 3, Color(randf(), randf(), randf()))
	timer += 1
	if drops.size() == 1000 and timer > 400:
		drops.clear()
		timer = 0
