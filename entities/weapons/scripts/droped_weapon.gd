extends RigidBody2D

var DUST_PARTICLE = GlobalParticles.emitters.DUST.instance()

export var weapon_name = ""
var show_popup = false
var remove = false

func _ready():
	$Sprite.texture = load(weapons_map.weapon_list[weapon_name])

func _physics_process(delta):
	set_popup_position()
	if !show_popup:
		$Popup.hide()
	else:
		$Popup.show()
		

func show_popup():
	show_popup = true

func hide_popup():
	show_popup = false

func set_popup_position():
	var sprite_position = $".".position
	sprite_position.x -= 25
	sprite_position.y -= 40
	$Popup.set_position(sprite_position)

func _on_PickupRange_body_entered(body):
	pass

sync func pickup():
	$Sprite.hide()
	emit_dust()


func _on_timer_timeout():
	self.queue_free()

func emit_dust():
	$".".add_child(DUST_PARTICLE)
	var timer = Timer.new()
	timer.wait_time = .5
	timer.connect("timeout", self, "_on_timer_timeout")
	add_child(timer)
	timer.start()
