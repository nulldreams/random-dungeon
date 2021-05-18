extends KinematicBody2D
var ARROW_PROJECTILE = preload("res://entities/weapons/scenes/arrow.tscn")
onready var arrow_item_position = $arrow_position
export var dev = false
export var current_weapon = ""
var game_started = false
var mouse_pos
var player_direction = "right"
var can_interact = false
var droped_item = {
	"name": null,
	"node": null
}

var movement = {
	"motion": Vector2.ZERO,
	"acceleration": 100,
	"max_speed": 80
}
onready var entitie_data = {
	"equipment": {
		"weapon": current_weapon
	},
	"actions": {
		"attacking": false,
		"hurt": false,
	},
	"movement": {
		"motion": Vector2.ZERO,
		"acceleration": 500,
		"max_speed": 170,
		"direction": "right",
		"mouse_direction": Vector2(100, 100)
	},
	"position": Vector2.ZERO,
	"axis": Vector2.ZERO
}

slave var slave_position = Vector2.ZERO
slave var slave_entitie_data = entitie_data

func get_animation_direction(direction: Vector2):
	$weapon.look_at(get_global_mouse_position())
	var mouse_direction = get_global_mouse_position().normalized()
	var norm_direction = direction.normalized()
	var player_position = position.normalized()
	if (mouse_direction.x <= player_position.x) and entitie_data.movement.direction == "right":
		entitie_data.movement.direction = "left"
		$".".scale.x = -1
	elif (mouse_direction.x >= player_position.x) and entitie_data.movement.direction == "left":
		entitie_data.movement.direction = "right"
		$".".scale.x = -1

func turn_weapon():
	$weapon.position.x *= -1
	$weapon.scale.x *= -1

func get_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	axis.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	var normalized = axis.normalized()
	return normalized

func apply_friction(amount):
	if entitie_data.movement.motion.length() > amount:
		entitie_data.movement.motion -= entitie_data.movement.motion.normalized() * amount
	else:
		entitie_data.movement.motion = Vector2.ZERO

func apply_movement(acceleration):
	entitie_data.movement.motion += acceleration
	entitie_data.movement.motion = entitie_data.movement.motion.clamped(entitie_data.movement.max_speed)
#	footdust.position = position
#	footdust.scale = Vector2(.8,.8)
#	$'/root/game/arena'.add_child(footdust)

func _ready():
	$weapon.weapon_owner = self
	$weapon.weapon_texture = current_weapon
	if !dev:
		$Camera2D.offset = Vector2(1000, 500)
		$Camera2D.zoom = Vector2(10, 10)

func _physics_process(delta):
	if !game_started and !dev: return
	var axis = Vector2.ZERO
	axis = get_axis()
	get_animation_direction(axis)
	if axis == Vector2.ZERO:
		apply_friction((entitie_data.movement.acceleration/2) * delta)
	else:
		apply_movement(axis * entitie_data.movement.acceleration * delta)
	entitie_data.equipment.weapon = current_weapon
	entitie_data.axis = axis
	entitie_data.position = position
	SimpleStateMachine.check_state(entitie_data.movement.motion, $".", entitie_data)
	entitie_data.movement.motion = move_and_slide(entitie_data.movement.motion)

func init(nickname, start_position, is_slave):
	$Name.text = nickname
	global_position = start_position

func _on_HitBox_area_shape_entered(area_id, area, area_shape, self_shape):
	pass

func _input(event):
	if event.is_action_pressed("attack"):
		entitie_data.actions.attacking = true
		if current_weapon == "bow":
			spawn_arrow()
		$AttackDuration.start()
	if event.is_action_pressed("interact") and can_interact and droped_item:
		change_weapon(droped_item)

func spawn_arrow():
	var arrow_item = ARROW_PROJECTILE.instance()
	var mouse_direction = get_global_mouse_position()
	arrow_item.rotation = get_angle_to(mouse_direction) + rotation
	arrow_item.position = position
	print(arrow_item.position)
	arrow_item.caster = name
	arrow_item.dev = dev
	if !dev:
		$"/root/game/world".add_child(arrow_item)
	else:
		$"/root/test_room".add_child(arrow_item)

func _on_AttackDuration_timeout():
	if entitie_data.actions.attacking:
		entitie_data.actions.attacking = false

func _on_player_sword_body_entered(body):
	if not is_network_master():
		return
	if body.name != name:
		var knockbak_direction = (global_position - body.global_position).normalized()
		var knockback_range = knockbak_direction * 20000
		body.rpc("hit", null, knockback_range * Vector2(-1, -1))

sync func hit(angle, knockback):
	if angle:
		var arrow_texture = load("res://entities/weapons/assets/bows/arrow/arrow.png")
		var sprite = Sprite.new()
		sprite.look_at(angle)
		sprite.set_offset(Vector2(-9, -2))
		sprite.set_texture(arrow_texture)
		apply_movement(knockback)
		arrow_item_position.add_child(sprite)
		entitie_data.actions.hurt = true
		$HurtDuration.start()
	else:
		apply_movement(knockback)
		entitie_data.actions.hurt = true
		$HurtDuration.start()

func change_weapon(weapon):
	current_weapon = weapon.name
	weapon.node.rpc("pickup")

func _on_HurtDuration_timeout():
	entitie_data.actions.hurt = false

func _on_PickupRange_body_entered(body):
	if not body.is_in_group("droped_items"):
		return
	body.show_popup()
	can_interact = true
	droped_item.name = body.weapon_name
	droped_item.node = body

func _on_PickupRange_body_exited(body):
	if not body.is_in_group("droped_items"):
		return
	can_interact = false
	body.hide_popup()

func t(time):
	return get_tree().create_timer(time)

func _on_ZoomToPlayer_timeout():
	if dev: return
	$Camera2D.offset = Vector2.ZERO
	while $Camera2D.zoom != Vector2(1, 1):
		var smooth = 3
		var new_zoom = Vector2($Camera2D.zoom.x-smooth, $Camera2D.zoom.y-smooth)
		$Camera2D.zoom = new_zoom
		yield(t(.1), "timeout")
	game_started = true
